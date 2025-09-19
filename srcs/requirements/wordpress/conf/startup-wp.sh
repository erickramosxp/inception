#!/bin/bash

until wait-for-it mariadb:3306 --quiet; do
    echo "Waiting for MariaDB to accept connections..."
    sleep 2
done

exec php-fpm8.2 -F
