FROM debian:12

RUN apt-get update \
    && apt-get install -y --no-install-recommends\
    php \
    php-mysql \
    php-xml \
    php-mbstring \
    php-curl \
    php8.2-fpm \
    sendmail \
    wget \
    ca-certificates \
	&& rm -rf /var/lib/apt/lists/* \
    && wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && wget https://wordpress.org/latest.tar.gz \
    && tar -xvf latest.tar.gz \
    && rm -rf latest.tar.gz \
    && mkdir -p /var/www/html/ \
    && mv wordpress/* /var/www/html \
    && chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;
    
WORKDIR /var/www/html

COPY --chown=www-data:www-data ./conf/wp-config.php /var/www/html/wp-config.php
COPY ./tools/wait-for-it.sh /bin/wait-for-it
COPY ./conf/startup-wp.sh /var/www/html/startup-wp.sh
COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

RUN chmod 755 /var/www/html/startup-wp.sh \
    && chmod 755 /bin/wait-for-it \
    && touch /var/log/php8.2-fpm.log \
    && chown www-data:www-data /var/log/php8.2-fpm.log \
    && chmod 664 /var/log/php8.2-fpm.log

USER www-data

EXPOSE 9000

ENTRYPOINT ["./startup-wp.sh"]

CMD ["php-fpm8.2", "-F"]