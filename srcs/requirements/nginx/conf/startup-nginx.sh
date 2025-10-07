#!/bin/bash

set -e

sed "s/\$SERVER_NAME/${SERVER_NAME}/g" /etc/nginx/sites-available/default.template > /etc/nginx/sites-available/default


echo "Starting Nginx..."

exec "$@"
