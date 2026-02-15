# Path to docker-compose file
COMPOSE_FILE = ./srcs/docker-compose.yml
# Path to environment variables file
ENV_FILE = ./srcs/.env

# Comandos Docker para facilitar
DOCKER_COMPOSE = docker compose -f $(COMPOSE_FILE)

# Persistent data directories (bind mounts)
# Usar $(HOME) torna o script mais flexível, mas mantive seu caminho fixo
WP_DATA = /home/dramos-j/data/wordpress
DB_DATA = /home/dramos-j/data/mariadb

# Default target
all: build up

# Build custom Docker images
build: create_dirs
	$(DOCKER_COMPOSE) build

# Start containers in background
up:
	$(DOCKER_COMPOSE) up -d

# Stop containers
down:
	$(DOCKER_COMPOSE) down

# Clean containers and orphans
clean:
	$(DOCKER_COMPOSE) down --remove-orphans

# Remove everything: containers, images, volumes AND local data folders
fclean: clean
	$(DOCKER_COMPOSE) down -v --rmi all --remove-orphans

# Rebuild everything from scratch
re: fclean all

# Create directories for persistent data
create_dirs:
	sudo mkdir -p $(WP_DATA)
	sudo mkdir -p $(DB_DATA)

.PHONY: all build up down clean fclean re create_dirs
