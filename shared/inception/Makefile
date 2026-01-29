# Caminho do arquivo docker-compose
COMPOSE_FILE = ./srcs/docker-compose.yml
# Caminho do arquivo de variáveis de ambiente
ENV_FILE = ./srcs/.env

# Inclui variáveis do .env como variáveis do Makefile
include ${ENV_FILE}
export $(shell sed 's/=.*//' ${ENV_FILE})

# Diretórios de dados persistentes (bind mounts)
WP_DATA = /home/dramos-j/data/wordpress
DB_DATA = /home/dramos-j/data/mariadb

# Alvo padrão: builda e sobe os containers
all: build up

# Builda as imagens Docker customizadas
build:
	docker compose -f ${COMPOSE_FILE} build

# Sobe os containers em background (depende de create_dirs)
up: create_dirs
	docker compose -f ${COMPOSE_FILE} up -d

# Para e remove os containers
down:
	docker compose -f ${COMPOSE_FILE} down

# Limpa containers, imagens e redes não utilizados
clean: down
	docker system prune -af

# Remove tudo, inclusive volumes e dados persistentes
fclean: clean
	sudo rm -rf /home/dramos-j/data
	docker volume rm $$(docker volume ls -q) 2>/dev/null || true

# Refaz tudo do zero
re: fclean all

# Cria diretórios de dados persistentes com permissão de root
create_dirs:
	sudo mkdir -p ${WP_DATA}
	sudo mkdir -p ${DB_DATA}

# Alvos que não correspondem a arquivos
.PHONY: all build up down clean fclean re create_dirs
