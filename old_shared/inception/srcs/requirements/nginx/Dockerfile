# Debian Bookworm (Debian 12)
FROM debian:bookworm-slim

# Update package lists
RUN apt update

# Install Nginx web server
RUN apt install -y --no-install-recommends nginx

# Install OpenSSL for certificate generation
RUN apt install -y --no-install-recommends openssl

# Clean up package cache to reduce image size
RUN apt clean && rm -rf /var/lib/apt/lists/*

# Create a self-signed SSL certificate for HTTPS
# -x509: creates a certificate instead of a certificate request
# -nodes: no password protection (no DES encryption)
# -days 365: certificate valid for 1 year
# -newkey rsa:2048: generates a new RSA key with 2048 bits
# -keyout: where to save the private key
# -out: where to save the certificate
# -subj: certificate subject information (avoids interactive prompts)
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/nginx-selfsigned.key \
    -out /etc/ssl/nginx-selfsigned.pem \
    -subj "/C=PT/ST=Porto/L=Porto/O=42/OU=42/CN=${DOMAIN_NAME}/UID=${USER}"

# Copy main Nginx configuration file
COPY ./conf/nginx.conf /etc/nginx/

# Copy server-specific configuration
COPY ./conf/dramos-j.42.fr.conf /etc/nginx/conf.d/

# Expose HTTPS port
EXPOSE 443

# Run Nginx in foreground mode (required for Docker)
ENTRYPOINT ["nginx", "-g", "daemon off;"]
