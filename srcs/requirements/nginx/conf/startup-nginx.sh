#!/bin/bash

MARKED=/etc/nginx/.initialized

set -e

if [ -f "$MARKED" ]; then
  exec "$@"
fi


if [ ! -f "$MARKED" ]; then

    mkdir -p /etc/nginx/ssl
  
#    openssl req -x509 -nodes -days 365 \
#        -newkey rsa:2048 \
#        -keyout "/etc/nginx/ssl/${SERVER_NAME}.key" \
#        -out "/etc/nginx/ssl/${SERVER_NAME}.crt" \
#        -subj "/C=BR/ST=Rio De Janeiro/L=Rio De Janeiro/O=42Rio/OU=Infra/CN=${SERVER_NAME}" \
#        -addext "subjectAltName=DNS:${SERVER_NAME}" \
#        -addext "keyUsage=digitalSignature,keyEncipherment" \
#        -addext "extendedKeyUsage=serverAuth,clientAuth"


    sed "s/\$SERVER_NAME/${SERVER_NAME}/g" /etc/nginx/sites-available/default.template > /etc/nginx/sites-available/default

    touch "$MARKED"
fi

exec "$@"
