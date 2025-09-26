.PHONY: up down build restart logs shell help

# Define the Docker Compose project name (optional, but good practice)
PROJECT_NAME := inception
COMPOSE_FILE=./srcs/docker-compose.yml
SERVICE?=wordpress

# Start all services in detached mode
# --build
up:
	@mkdir -p /home/$(USER)/data/db_data
	@mkdir -p /home/$(USER)/data/wp_data
	@docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) up -d 

# Stop and remove all services
down:
	@echo "Shutting down containers..."
	@docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) down
	@echo "Containers are now down."

    # Build or rebuild service images
build:
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

clean:
	@echo "[ - ] Shutting down containers and cleaning images..."
	@docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) down --rmi all -v
	


fclean: down
	@echo "[ - ] Shutting down containers and cleaning everything..."
	@docker compose -f $(COMPOSE_FILE) -p $(PROJECT_NAME) down --rmi all -v
	@echo "[✔  ] Containers, images and volumes removed"
	@echo "[ - ] Removing local data..."
	@bash -c "sudo rm -rf /home/$(USER)/data/db_data /home/$(USER)/data/wp_data"
	@echo "[✔  ] Removing local data..."

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
