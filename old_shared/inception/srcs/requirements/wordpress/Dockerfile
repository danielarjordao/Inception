# Debian Bookworm (Debian 12) with PHP 8.2
FROM debian:bookworm-slim

# WordPress version to download
ARG WP_VERSION=6.7.1

# Update package lists
RUN apt update

# Install PHP-FPM and extensions
RUN apt install -y --no-install-recommends \
	php8.2-fpm \
	php8.2-mysql \
	php8.2-gd

# Install tools needed for setup
RUN apt install -y --no-install-recommends \
	ca-certificates \
	wget \
	tar \
	rsync

# Install gosu to run commands as www-data user
RUN apt install -y --no-install-recommends gosu

# Install MariaDB client for wp-cli database management
RUN apt install -y --no-install-recommends mariadb-client

# Update SSL certificates
RUN update-ca-certificates

# Clean up package cache to reduce image size
RUN apt clean && rm -rf /var/lib/apt/lists/*

# Create WordPress directories
RUN mkdir -p /var/www/html
RUN mkdir -p /usr/src/wordpress

# Download WordPress
RUN wget https://wordpress.org/wordpress-${WP_VERSION}.tar.gz -O wordpress.tar.gz

# Extract WordPress to staging directory
RUN tar -xzf wordpress.tar.gz --strip-components=1 -C /usr/src/wordpress

# Remove downloaded archive
RUN rm wordpress.tar.gz

# Download WP-CLI (WordPress command line tool)
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# Make WP-CLI executable
RUN chmod +x wp-cli.phar

# Move WP-CLI to system path
RUN mv wp-cli.phar /usr/local/bin/wp

# Create WP-CLI cache directory for www-data user
RUN mkdir -p /home/www-data/.wp-cli/cache
RUN chown -R www-data:www-data /home/www-data/.wp-cli

# Copy PHP-FPM configuration
COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Set working directory
WORKDIR /var/www/html

# Copy initialization script
COPY ./tools/wp_exec.sh /usr/local/bin/wp_exec.sh

# Make initialization script executable
RUN chmod +x /usr/local/bin/wp_exec.sh

# Expose PHP-FPM port
EXPOSE 9000

# Run initialization script on container start
ENTRYPOINT ["/usr/local/bin/wp_exec.sh"]

# Start PHP-FPM in foreground mode
CMD ["php-fpm8.2", "-F"]
