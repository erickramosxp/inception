.PHONY: up down build restart logs shell help

# Define the Docker Compose project name (optional, but good practice)
PROJECT_NAME := inception
COMPOSE_FILE=./srcs/docker-compose.yml
SERVICE?=wordpress
ENV_FILE:=./srcs/.env
SERVER_NAME:=$(shell grep ^SERVER_NAME srcs/.env | cut -d '=' -f2)
CERTS_DIR="./srcs/requirements/nginx/certs"

# Start all services in detached mode
up: certs
	@mkdir -p /home/$(USER)/data/db_data
	@mkdir -p /home/$(USER)/data/wp_data
	@docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) up -d 

# Stop and remove all services
down:
	@echo "Shutting down containers..."
	@docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) down
	@echo "Containers are now down."

    # Build or rebuild service images
build: certs
	@docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) build

    # Restart all services
restart:
	@docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) restart

    # View logs for all services
logs:
	@docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) logs -f

    # Access a shell within a specific service container (e.g., 'web')
shell:
	@docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) exec -it -u root $(SERVICE) bash

env_check:
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "Error: file .env not found!"; \
		exit 1; \
	fi

certs: env_check
	@if [ ! -d $(CERTS_DIR) ]; then \
		if [ -z "$(SERVER_NAME)" ]; then \
			echo "Error: SERVER_NAME variable not defined!"; \
			exit 1; \
		else \
			mkdir -p $(CERTS_DIR); \
			openssl req -x509 -nodes -days 365 \
			-newkey rsa:2048 \
			-keyout "${CERTS_DIR}/${SERVER_NAME}.key" \
			-out "${CERTS_DIR}/${SERVER_NAME}.crt" \
			-subj "/C=BR/ST=Rio De Janeiro/L=Rio De Janeiro/O=42Rio/OU=Infra/CN=${SERVER_NAME}" \
			-addext "subjectAltName=DNS:${SERVER_NAME}" \
			-addext "keyUsage=digitalSignature,keyEncipherment" \
			-addext "extendedKeyUsage=serverAuth,clientAuth" > /dev/null 2>&1; \
		fi; \
	else \
		echo "Certificates already exist!"; \
	fi

clean:
	@echo "[ - ] Shutting down containers and cleaning images..."
	@docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) down --rmi all -v
	

fclean: down
	@echo "[ - ] Shutting down containers and cleaning everything..."
	@docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) down --rmi all -v
	@echo "[✔  ] Containers, images and volumes removed"
	@echo "[ - ] Removing local data..."
	@bash -c "sudo rm -rf /home/$(USER)/data/db_data /home/$(USER)/data/wp_data /home/$(USER)/data"
	@echo "[✔  ] Removing local data..."
	@rm -rf $(CERTS_DIR)

re: fclean up

    # Display available commands
help:
	@echo "Available commands:"
	@echo "  make up      - Start all services"
	@echo "  make down    - Stop and remove all services"
	@echo "  make build   - Build or rebuild service images"
	@echo "  make restart - Restart all services"
	@echo "  make logs    - View logs for all services"
	@echo "  make fclean  - Stop and remove all services, images, volumes and local data"
	@echo "  make shell   - Access a shell within the service by assigning the 'SERVICE' variable"
	@echo "  make help    - Display this help message"
