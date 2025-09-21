#!/bin/bash

MARKED=.initialized

set -e

until wait-for-it mariadb:3306 --quiet; do
    echo "Waiting for MariaDB to accept connections..."
    sleep 2
done


if [ ! -f "$MARKED" ]; then

    wp config set DB_NAME "${WORDPRESS_DB_NAME}" --type=constant > /dev/null 2>&1
    wp config set DB_USER "${WORDPRESS_DB_USER}" --type=constant > /dev/null 2>&1
    wp config set DB_PASSWORD "${WORDPRESS_DB_PASSWORD}" --type=constant > /dev/null 2>&1
    wp config set DB_HOST "${WORDPRESS_DB_HOST}" --type=constant > /dev/null 2>&1

    wp core install \
    --url="https://${WORDPRESS_URL}" \
    --title="Inception" \
    --admin_user="${WORDPRESS_ADMIN_USER}" \
    --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
    --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
    --locale="${WORDPRESS_LOCALE}" \
    > /dev/null 2>&1

    if [ -n "${WORDPRESS_LOCALE:-}" ] && [ ! -f "$WORDPRESS_LOCALE" ]; then
        wp language core install "$WORDPRESS_LOCALE"
        wp site switch-language "$WORDPRESS_LOCALE"
        wp config set WPLANG "$WORDPRESS_LOCALE"
    fi

    wp option update comment_moderation 0 
    wp option update comment_previously_approved 0
fi

touch "$MARKED"

exec php-fpm8.2 -F