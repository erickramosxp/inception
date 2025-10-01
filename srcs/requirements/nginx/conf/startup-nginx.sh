#!/bin/bash

MARKED=.initialized

set -e

# check_port() {
#   (echo > /dev/tcp/wordpress/9000) >/dev/null 2>&1
# }

# until check_port; do
#   echo "⏳ Aguardando o WordPress ficar pronto..."
#   sleep 5
# done

# echo "✅ WordPress está pronto!"

if [ ! -f "$MARKED" ]; then

    mkdir -p /etc/nginx/ssl

    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "/etc/nginx/ssl/${SERVER_NAME}.key" \
        -out "/etc/nginx/ssl/${SERVER_NAME}.crt" \
        -subj "/CN=${SERVER_NAME}"

    sed "s/\$SERVER_NAME/${SERVER_NAME}/g" /etc/nginx/sites-available/default.template > /etc/nginx/sites-available/default

    touch "$MARKED"
fi

exec "$@"