FROM debian:bookworm-slim

# Build arguments for SSL certificate customization
ARG DOMAIN_NAME
ARG USER

# Install nginx and openssl, then clean up apt cache
RUN apt update && apt install -y --no-install-recommends nginx openssl && \
    apt clean && rm -rf /var/lib/apt/lists/*

# Generate a self-signed SSL certificate using build arguments
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/nginx-selfsigned.key \
    -out /etc/ssl/nginx-selfsigned.pem \
    -subj "/C=PT/ST=Porto/L=Porto/O=42/OU=42/CN=${DOMAIN_NAME}/UID=${USER}"

# Copy main nginx configuration
COPY ./conf/nginx.conf /etc/nginx/
# Copy site/server configuration (filename should match your login or be generic)
COPY ./conf/dramos-j.42.fr.conf /etc/nginx/conf.d/

# Expose HTTPS port
EXPOSE 443

# Start nginx in foreground
ENTRYPOINT ["nginx", "-g", "daemon off;"]
