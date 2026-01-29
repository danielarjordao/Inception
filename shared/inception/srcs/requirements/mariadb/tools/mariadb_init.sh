#!/bin/bash

# Exit immediately if any command fails
set -e

# Read database password from Docker secret
DB_PASSWORD=$(cat /run/secrets/db_pass)

# Initialize MariaDB data directory if not already present
if [ ! -d /var/lib/mysql/mysql ]; then
	echo "MariaDB not initialized. Creating data directory..."

	# Set correct ownership for data directory
	chown -R mysql:mysql /var/lib/mysql

	# Restrict permissions to mysql user only
	chmod 700 /var/lib/mysql

	# Initialize MariaDB system tables
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql

	echo "MariaDB data directory initialized successfully."

	# Start MariaDB server in background for setup
	mysqld --user=mysql --datadir=/var/lib/mysql &
	MARIADB_PID=$!

	# Wait for MariaDB to be ready
	echo "Waiting for MariaDB to start..."
	sleep 10

	# Create database and user for WordPress
	echo "Creating database and user..."
	mariadb -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
	mariadb -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${DB_PASSWORD}';"
	mariadb -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"
	mariadb -e "FLUSH PRIVILEGES;"

	# Shut down temporary MariaDB server
	mysqladmin --user=root shutdown
	wait $MARIADB_PID

	echo "MariaDB setup completed successfully."
else
	echo "MariaDB data directory already exists. Skipping initialization."
fi

# Replace this script with mysqld as PID 1
# "$@" passes the CMD from Dockerfile (gosu mysql mysqld)
exec "$@"
