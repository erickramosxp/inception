FROM debian:12

RUN apt-get update \
	&& apt-get install mariadb-server -y \
	&& rm -rf /var/lib/apt/lists/*

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./conf/mariadb_init_script.sh /usr/local/bin/init-script.sh
RUN chmod +x /usr/local/bin/init-script.sh \
	&& chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf

LABEL description="MariaDB Server"

EXPOSE 3306

CMD ["bash", "/usr/local/bin/init-script.sh"]
