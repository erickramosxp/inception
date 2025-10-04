FROM debian:12

# USER root

RUN apt-get -y update \
    && apt-get -y install nginx \
    && apt-get -y install openssl \
    procps \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY ./conf/default /etc/nginx/sites-available/default.template
COPY ./conf/startup-nginx.sh /usr/local/bin/startup-nginx.sh

RUN chmod +x /usr/local/bin/startup-nginx.sh \
    && chown www-data:www-data /usr/local/bin/startup-nginx.sh \
    && touch /var/log/nginx.log \
    && chown -R www-data:www-data \
    /var/log/nginx.log \
    /etc/nginx

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/startup-nginx.sh"]

CMD ["nginx", "-g", "daemon off;"]
ENTRYPOINT ["/usr/local/bin/startup-nginx.sh"]

CMD ["nginx", "-g", "daemon off;"]