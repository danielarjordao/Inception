# Minimal base image
FROM debian:bookworm-slim

# Update repositories
RUN apt update

# Install MariaDB server
RUN apt install -y --no-install-recommends mariadb-server

# Install gosu to run as mysql user
RUN apt install -y --no-install-recommends gosu

# Clean apt cache for smaller image
RUN apt clean && rm -rf /var/lib/apt/lists/*

# Remove any pre-existing database data
RUN rm -rf /var/lib/mysql/*

# Copy custom MariaDB configuration
COPY conf/mariadb.cnf /etc/mysql/mariadb.conf.d/

# Set read permission for config
RUN chmod +r /etc/mysql/mariadb.conf.d/mariadb.cnf

# Create socket directory
RUN mkdir -p /run/mysqld

# Set correct permissions for socket
RUN chown -R mysql:mysql /run/mysqld

# Copy custom initialization script
COPY tools/mariadb_init.sh /usr/local/bin/

# Make the script executable
RUN chmod +x /usr/local/bin/mariadb_init.sh

# Expose MariaDB default port
EXPOSE 3306

# Custom entrypoint script
ENTRYPOINT ["/usr/local/bin/mariadb_init.sh"]

# Default command: start MariaDB as mysql user
CMD ["gosu", "mysql", "mysqld"]
