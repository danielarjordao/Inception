# Debian Bookworm (Debian 12)
FROM debian:bookworm-slim

# Update package lists
RUN apt update

# Install MariaDB server
RUN apt install -y --no-install-recommends mariadb-server

# Install gosu to run MariaDB under the mysql user
RUN apt install -y --no-install-recommends gosu

# Clean up package cache to reduce image size
RUN apt clean && rm -rf /var/lib/apt/lists/*

# Remove any pre-initialized data from the image
RUN rm -rf /var/lib/mysql/*

# Copy custom MariaDB configuration file
COPY conf/mariadb.cnf /etc/mysql/mariadb.conf.d/

# Set proper permissions for configuration file
RUN chmod +r /etc/mysql/mariadb.conf.d/mariadb.cnf

# Create directory for MariaDB socket
RUN mkdir -p /run/mysqld

# Set ownership of socket directory to mysql user
RUN chown -R mysql:mysql /run/mysqld

# Copy initialization script
COPY tools/mariadb_init.sh /usr/local/bin/

# Make initialization script executable
RUN chmod +x /usr/local/bin/mariadb_init.sh

# Expose MariaDB port to allow external connections
EXPOSE 3306

# Set the entrypoint to the custom initialization script
ENTRYPOINT ["/usr/local/bin/mariadb_init.sh"]

# Start MariaDB server as the mysql user using gosu
CMD ["gosu", "mysql", "mysqld"]
