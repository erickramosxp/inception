#!/bin/bash

FORBIDDEN_USERS=("admin" "Admin" "administrator" "Administrator")
SOCKET="/var/run/mysqld/mysqld.sock"
MYSQLCLI="mysql --protocol=socket --socket=$SOCKET -uroot"

set -e

ROOT_AUTH=""
if [ -n "${MYSQL_ROOT_PASSWORD:-}" ]; then
    ROOT_AUTH="-p${MYSQL_ROOT_PASSWORD}"
fi

# inicia servidor em background
mysqld_safe --datadir=/var/lib/mysql &

# aguarda o servidor iniciar
until mysqladmin ping --silent; do
  echo "⏳ Aguardando o MariaDB iniciar..."
  sleep 2
done

create_user_if_valid() {
  local user=$1
  local pass=$2
  local db=$3

  for forbidden in "${FORBIDDEN_USERS[@]}"; do
    if [[ "$user" == *"$forbidden"* ]]; then
      echo "ERRO: username: '$user' contains '$forbidden', not allowed!"
      exit 1
    fi
  done

  # cria usuário no banco
  ${MYSQLCLI} ${ROOT_AUTH} <<-EOSQL
    CREATE USER IF NOT EXISTS '${user}'@'%' IDENTIFIED BY '${pass}';
    GRANT ALL PRIVILEGES ON \`${db}\`.* TO '${user}'@'%';
    FLUSH PRIVILEGES;
EOSQL
  echo "[init] User '${user}' was create."
}

if [ -n "${MYSQL_DATABASE:-}" ]; then
    ${MYSQLCLI} <<-EOSQL
      CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
EOSQL
fi


if [ -n "${MYSQL_ROOT_PASSWORD:-}" ]; then
	${MYSQLCLI} <<-EOSQL
  	ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
  	FLUSH PRIVILEGES;
EOSQL
fi

# cria usuário, se variáveis existirem
if [ -n "${MYSQL_USER:-}" ] && [ -n "${MYSQL_PASSWORD:-}" ]; then
  create_user_if_valid "$MYSQL_USER" "$MYSQL_PASSWORD" "${MYSQL_DATABASE:-*}"
fi

mysqladmin --protocol=socket --socket=$SOCKET -uroot -p${MYSQL_ROOT_PASSWORD} shutdown

echo "[init] Finalizado, iniciando o servidor MariaDB..."
exec mysqld_safe --datadir=/var/lib/mysql
