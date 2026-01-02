COMPOSE_FILE = ./srcs/docker-compose.yml
ENV_FILE = ./srcs/.env

include ${ENV_FILE}
export $(shell sed 's/=.*//' ${ENV_FILE})

WP_DATA = /home/dramos-j/data/wordpress
DB_DATA = /home/dramos-j/data/mariadb

all: build up

build:
	docker compose -f ${COMPOSE_FILE} build

up: create_dirs
	docker compose -f ${COMPOSE_FILE} up -d

down:
	docker compose -f ${COMPOSE_FILE} down

clean: down
	docker system prune -af

fclean: clean
	sudo rm -rf /home/dramos-j/data
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true

re: fclean all

create_dirs:
	sudo mkdir -p ${WP_DATA}
	sudo mkdir -p ${DB_DATA}

.PHONY: all build up down clean fclean re create_dirs
