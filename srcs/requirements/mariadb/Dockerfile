FROM debian:12.0

ENV MYSQL_ROOT_PASSWORD=Senha123
ENV MYSQL_USER=teste123
ENV MYSQL_PASSWORD=teste123

RUN apt-get update \
	&& apt-get install mariadb-server -y \
	&& rm -rf /var/lib/apt/lists/*

COPY ./conf/mariadb_init_script.sh /usr/local/bin/init-script.sh
RUN chmod +x /usr/local/bin/init-script.sh

LABEL description="MariaDB Server"

EXPOSE 3306

CMD ["bash", "/usr/local/bin/init-script.sh"]
