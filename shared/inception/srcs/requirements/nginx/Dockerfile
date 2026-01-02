FROM debian:bookworm-slim

# Recebe variáveis do docker-compose para o SSL
ARG DOMAIN_NAME
ARG USER

RUN apt update && apt install -y --no-install-recommends nginx openssl && \
    apt clean && rm -rf /var/lib/apt/lists/*

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/nginx-selfsigned.key \
    -out /etc/ssl/nginx-selfsigned.pem \
    -subj "/C=PT/ST=Porto/L=Porto/O=42/OU=42/CN=${DOMAIN_NAME}/UID=${USER}"

COPY ./conf/nginx.conf /etc/nginx/
# Use o nome genérico ou garanta que o arquivo existe com seu login
COPY ./conf/dramos-j.42.fr.conf /etc/nginx/conf.d/

EXPOSE 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]
