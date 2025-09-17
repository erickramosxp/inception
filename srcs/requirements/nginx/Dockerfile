FROM debian:12

RUN apt-get -y update \
    && apt-get -y install nginx \
    && rm -rf /var/lib/apt/lists/*

COPY ./conf/default /etc/nginx/sites-available/default

EXPOSE 80


CMD ["nginx", "-g", "daemon off;"]