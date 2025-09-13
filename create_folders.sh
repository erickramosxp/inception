#!/bin/bash

mkdir -p secrets srcs/requirements/{mariadb/{conf,tools},nginx/{conf,tools},wordpress/{conf,tools},tools}

touch Makefile

touch secrets/credentials.txt secrets/db_password.txt secrets/db_root_password.txt

touch srcs/docker-compose.yml srcs/.env

touch srcs/requirements/mariadb/Dockerfile srcs/requirements/nginx/Dockerfile srcs/requirements/wordpress/Dockerfile

touch srcs/requirements/mariadb/.dockerignore srcs/requirements/nginx/.dockerignore srcs/requirements/wordpress/.dockerignore
