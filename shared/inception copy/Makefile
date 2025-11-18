NAME = inception

# Inicializa todos os serviços
all: up

# Construir e iniciar todos os serviços definidos no arquivo docker-compose.yml
up:
	@mkdir -p /home/dramos-j/data/wordpress
	@mkdir -p /home/dramos-j/data/mariadb
	docker compose -f srcs/docker-compose.yml up -d --build

# Parar e remover todos os serviços definidos no arquivo docker-compose.yml
down:
	docker compose -f srcs/docker-compose.yml down

# Reconstruir e reiniciar todos os serviços
re: down up

# Declaração de alvos que não correspondem a arquivos
.PHONY: all up down re
