FROM debian:12

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	mariadb-server \
	gosu \
	&& rm -rf /var/lib/apt/lists/*

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./conf/mariadb_init_script.sh /usr/local/bin/init-script.sh


RUN chmod +x /usr/local/bin/init-script.sh \
	&& chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf

LABEL description="MariaDB Server"

RUN mkdir -p /var/lib/mysql /var/run/mysqld /var/log/mysql/ \
	&& touch /var/log/mysql/error.log /var/log/mysql/mariadb-slow.log \
	&& chown -R mysql:mysql \
	/var/lib/mysql \
	/var/run/mysqld \
	/var/log/mysql/error.log \
	/var/log/mysql/mariadb-slow.log

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/init-script.sh"]

CMD ["mysqld", "--console"]
