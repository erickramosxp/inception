#!/bin/bash

FORBIDDEN_USERS=("admin" "Admin" "administrator" "Administrator")
MARKED=.initialized

set -e

echo "Check db connection..."

until wait-for-it mariadb:3306 --quiet; do
    echo "Waiting for MariaDB to accept connections..."
    sleep 2
done

echo "DB is ready!"

valid_user() {
  local user=$1

  for forbidden in "${FORBIDDEN_USERS[@]}"; do
    if [[ "$user" == *"$forbidden"* ]]; then
      echo "ERRO: username: '$user' contains '$forbidden', not allowed!"
      return 1
    fi
  done
    return 0
}




if [ ! -f "$MARKED" ]; then

    echo "Setting initial configuration..."

    wp config set DB_NAME "${WORDPRESS_DB_NAME}" --type=constant > /dev/null 2>&1
    wp config set DB_USER "${WORDPRESS_DB_USER}" --type=constant > /dev/null 2>&1
    wp config set DB_PASSWORD "${WORDPRESS_DB_PASSWORD}" --type=constant > /dev/null 2>&1
    wp config set DB_HOST "${WORDPRESS_DB_HOST}" --type=constant > /dev/null 2>&1

    echo "Setting admin user configuration..."

    if ! valid_user "${WORDPRESS_ADMIN_USER}" || ! valid_user "${WORDPRESS_USER}"; then
        exit 1
    fi
    wp core install \
    --url="https://${WORDPRESS_URL}" \
    --title="Inception" \
    --admin_user="${WORDPRESS_ADMIN_USER}" \
    --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
    --admin_email="${WORDPRESS_ADMIN_EMAIL}" \
    --locale="${WORDPRESS_LOCALE}" \
    > /dev/null 2>&1

    wp user create \
    "${WORDPRESS_USER}" \
    "${WORDPRESS_EMAIL}" \
    --user_pass="${WORDPRESS_PASSWORD}" \
    --role=subscriber

    echo "Setting comment configuration..."
    wp option update comment_moderation 0 
    wp option update comment_previously_approved 0
    
    echo "Setting inicialization flag..."
    touch "$MARKED"
fi

echo "Starting WordPress..."

exec php-fpm8.2 -F