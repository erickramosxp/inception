FROM debian:12

RUN apt-get -y update \
    && apt-get -y install nginx \
    && apt-get -y install openssl \
    && rm -rf /var/lib/apt/lists/*

COPY ./conf/default /etc/nginx/sites-available/default.template
COPY ./conf/startup-nginx.sh /usr/local/bin/startup-nginx.sh

RUN chmod +x /usr/local/bin/startup-nginx.sh

EXPOSE 443


CMD ["/usr/local/bin/startup-nginx.sh"]