FROM debian:12

RUN apt-get update \
    && apt-get install -y \
    php \
    php-mysql \
    php-xml \
    php-mbstring \
    php-curl \
    php-curl \
    wget \
	&& rm -rf /var/lib/apt/lists/*

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN wget https://wordpress.org/latest.tar.gz \
    && tar -xvf latest.tar.gz \
    && rm -rf latest.tar.gz \
    && mv wordpress /var/www/wordpress \
    && chown -R root:root /var/www/wordpress

WORKDIR /var/www/wordpress

COPY ./conf/wp-config.php /var/www/wordpress/wp-config.php

EXPOSE 9000

CMD ["php", "-S", "0.0.0.0:9000", "-t", "/var/www/wordpress"]