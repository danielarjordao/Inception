
# Path to docker-compose file
COMPOSE_FILE = ./srcs/docker-compose.yml
# Path to environment variables file
ENV_FILE = ./srcs/.env

# Include .env variables as Makefile variables
include ${ENV_FILE}
export $(shell sed 's/=.*//' ${ENV_FILE})

# Persistent data directories (bind mounts)
WP_DATA = /home/dramos-j/data/wordpress
DB_DATA = /home/dramos-j/data/mariadb

# Default target: build and start containers
all: build up

# Build custom Docker images
build:
	docker compose -f ${COMPOSE_FILE} build

# Start containers in background (depends on create_dirs)
up: create_dirs
	docker compose -f ${COMPOSE_FILE} up -d

# Stop and remove containers
down:
	docker compose -f ${COMPOSE_FILE} down

# Clean unused containers, images, and networks
clean: down
	docker system prune -af

# Remove everything, including volumes and persistent data
fclean: clean
	sudo rm -rf /home/dramos-j/data
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true

# Rebuild everything from scratch
re: fclean all

# Create directories for persistent data
create_dirs:
	sudo mkdir -p ${WP_DATA}
	sudo mkdir -p ${DB_DATA}

# Set phony targets, so they are not treated as files
.PHONY: all build up down clean fclean re create_dirs
