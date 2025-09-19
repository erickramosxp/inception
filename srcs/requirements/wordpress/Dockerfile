FROM debian:12

RUN apt-get update \
    && apt-get install -y \
    php \
    php-mysql \
    php-xml \
    php-mbstring \
    php-curl \
    php8.2-fpm \
    wget \
	&& rm -rf /var/lib/apt/lists/*

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# RUN adduser --system --no-create-home --group www-data

RUN wget https://wordpress.org/latest.tar.gz \
    && tar -xvf latest.tar.gz \
    && rm -rf latest.tar.gz \
    && mkdir -p /var/www/html/ \
    && mv wordpress/* /var/www/html \
    && chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

COPY ./conf/wp-config.php /var/www/html/wp-config.php
COPY ./tools/wait-for-it.sh /bin/wait-for-it
COPY ./conf/startup-wp.sh /var/www/html/startup-wp.sh

RUN chmod +x /var/www/html/startup-wp.sh \
    && chmod +x /bin/wait-for-it \
    && touch /var/log/php8.2-fpm.log \
    && chown www-data:www-data /var/log/php8.2-fpm.log \
    && chmod 664 /var/log/php8.2-fpm.log

USER www-data

EXPOSE 9000

CMD ["./startup-wp.sh"]
