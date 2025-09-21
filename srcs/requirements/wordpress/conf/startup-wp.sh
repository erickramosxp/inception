#!/bin/bash

MARKED=.initialized

set -e

echo "Check db connection..."

until wait-for-it mariadb:3306 --quiet; do
    echo "Waiting for MariaDB to accept connections..."
    sleep 2
done

echo "DB is ready!"

if [ ! -f "$MARKED" ]; then

    echo "Setting initial configuration..."

    wp config set DB_NAME "${WORDPRESS_DB_NAME}" --type=constant > /dev/null 2>&1
    wp config set DB_USER "${WORDPRESS_DB_USER}" --type=constant > /dev/null 2>&1
    wp config set DB_PASSWORD "${WORDPRESS_DB_PASSWORD}" --type=constant > /dev/null 2>&1
    wp config set DB_HOST "${WORDPRESS_DB_HOST}" --type=constant > /dev/null 2>&1

    echo "Setting admin user configuration..."
    wp core install \
    --url="https://${WORDPRESS_URL}" \
    --title="Inception" \
    --admin_user="${WORDPRESS_ADMIN_USER}" \
    --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
    --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
    --locale="${WORDPRESS_LOCALE}" \
    > /dev/null 2>&1

    echo "Setting comment configuration..."
    wp option update comment_moderation 0 
    wp option update comment_previously_approved 0
    
    echo "Setting inicialization flag..."
    touch "$MARKED"
fi

echo "Starting WordPress..."

exec php-fpm8.2 -F