#!/bin/bash

FORBIDDEN_USERS=("admin" "Admin" "administrator" "Administrator")
SOCKET="/var/run/mysqld/mysqld.sock"
MYSQLCLI="mysql --protocol=socket --socket=$SOCKET -uroot"
MARKER="/var/lib/mysql/.initialized"
MYSQL_ARGS="--user=root --password=${MYSQL_ROOT_PASSWORD}"
MAX_ATTEMPTS=30
ATTEMPT=0

set -e

# se já inicializou, só inicia o servidor
if [ -f "$MARKER" ]; then
  echo "[init] Already initialized previously, just starting MariaDB..."
  exec gosu mysql "$@"
fi

# inicia servidor em background
mysqld_safe --datadir=/var/lib/mysql --skip-networking --socket=$SOCKET &

# aguarda o servidor iniciar

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do

  if mysqladmin ping --socket=$SOCKET --silent; then
    echo "[init] MariaDB is ready for initial configuration!"
    break
  fi

  ATTEMPT=$((ATTEMPT + 1))
  echo "⏳ Connecting to mariadb, attempt $ATTEMPT/$MAX_ATTEMPTS..."
  sleep 2
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
  echo "❌ ERROR: MariaDB failed to start after $MAX_ATTEMPTS attempts"
  exit 1
fi


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
  mysql ${MYSQL_ARGS} --protocol=socket --socket=$SOCKET  <<-EOSQL
    CREATE USER IF NOT EXISTS '${user}'@'%' IDENTIFIED BY '${pass}';
    GRANT ALL PRIVILEGES ON \`${db}\`.* TO '${user}'@'%';
    FLUSH PRIVILEGES;
EOSQL
  echo "[init] User '${user}' was create."
}

if [ -n "${MYSQL_ROOT_PASSWORD:-}" ]; then
	${MYSQLCLI} <<-EOSQL
  	ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
  	FLUSH PRIVILEGES;
EOSQL
fi


if [ -n "${MYSQL_DATABASE:-}" ]; then
    mysql ${MYSQL_ARGS} --protocol=socket --socket=$SOCKET <<-EOSQL
      CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
EOSQL
fi


# cria usuário, se variáveis existirem
if [ -n "${MYSQL_USER:-}" ] && [ -n "${MYSQL_PASSWORD:-}" ]; then
  create_user_if_valid "$MYSQL_USER" "$MYSQL_PASSWORD" "${MYSQL_DATABASE:-*}"
fi

mysqladmin ${MYSQL_ARGS} --socket=$SOCKET shutdown

# marca que já inicializou
touch "$MARKER"

# ln -sf /dev/stdout /var/log/mysql/mariadb-slow.log
# ln -sf /dev/stderr /var/log/mysql/error.log

echo "[init] Done, starting the MariaDB server..."
exec gosu mysql "$@"
