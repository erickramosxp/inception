#!/bin/bash

FORBIDDEN_USERS=("admin" "Admin" "administrator" "Administrator")
SOCKET="/var/run/mysqld/mysqld.sock"
MYSQLCLI="mysql --protocol=socket --socket=$SOCKET -uroot"
MARKER="/var/lib/mysql/.initialized"
MYSQL_ARGS="--user=root --password=${MYSQL_ROOT_PASSWORD}"
MAX_ATTEMPTS=30
ATTEMPT=0

set -e

# if it has already started, just start the server
if [ -f "$MARKER" ]; then
  echo "[init] Already initialized previously, just starting MariaDB..."
  exec gosu mysql "$@"
fi

# starts temporary server in background
mysqld_safe --datadir=/var/lib/mysql --skip-networking --socket=$SOCKET &

# wait for the server to start

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do

  # ping mysql to see if it has already gone up
  if mysqladmin ping --socket=$SOCKET --silent; then
    echo "[init] MariaDB is ready for initial configuration!"
    break
  fi

  # count the attempts, if it reaches 30 it gives an error
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

  # checks if the user has admin in the name
  for forbidden in "${FORBIDDEN_USERS[@]}"; do
    if [[ "$user" == *"$forbidden"* ]]; then
      echo "ERRO: username: '$user' contains '$forbidden', not allowed!"
      exit 1
    fi
  done

  # create user in the bank
  mysql ${MYSQL_ARGS} --protocol=socket --socket=$SOCKET  <<-EOSQL
    CREATE USER IF NOT EXISTS '${user}'@'%' IDENTIFIED BY '${pass}';
    GRANT ALL PRIVILEGES ON \`${db}\`.* TO '${user}'@'%';
    FLUSH PRIVILEGES;
EOSQL
  echo "[init] User '${user}' was create."
}

# set root user password
if [ -n "${MYSQL_ROOT_PASSWORD:-}" ]; then
	${MYSQLCLI} <<-EOSQL
  	ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
  	FLUSH PRIVILEGES;
EOSQL
fi

#  create database
if [ -n "${MYSQL_DATABASE:-}" ]; then
    mysql ${MYSQL_ARGS} --protocol=socket --socket=$SOCKET <<-EOSQL
      CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
EOSQL
fi


# create user, if variables exist
if [ -n "${MYSQL_USER:-}" ] && [ -n "${MYSQL_PASSWORD:-}" ]; then
  create_user_if_valid "$MYSQL_USER" "$MYSQL_PASSWORD" "${MYSQL_DATABASE:-*}"
fi

# shut down the temporary server
mysqladmin ${MYSQL_ARGS} --socket=$SOCKET shutdown

# brand that has already initialized
touch "$MARKER"

echo "[init] Done, starting the MariaDB server..."
exec gosu mysql "$@"
