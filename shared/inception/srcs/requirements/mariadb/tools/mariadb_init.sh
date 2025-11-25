#!/bin/bash

# Exit immediately if a command fails
set -e

# Read database password from secret
DB_PASSWORD=$(cat /run/secrets/db_pass)

# Initialize MariaDB data directory
if [ ! -d /var/lib/mysql/mysql ]; then
	echo "MariaDB not initialized. Creating data directory..."

	# Set ownership of data directory
	chown -R mysql:mysql /var/lib/mysql

	# Set secure permissions (only mysql user can access)
	chmod 700 /var/lib/mysql

	# Initialize MariaDB system tables
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql

	echo "MariaDB data directory initialized successfully."

	# Start temporary MariaDB server in background
	mysqld --user=mysql --datadir=/var/lib/mysql &
	MARIADB_PID=$!

	# Wait for MariaDB to be ready
	echo "Waiting for MariaDB to start..."
	sleep 10

	# Create database and user
	echo "Creating database and user..."

	# Create database if not exists
	mariadb -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"

	# Create user with password from secret
	mariadb -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${DB_PASSWORD}';"

	# Grant all privileges on database to user
	mariadb -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"

	# Apply privilege changes
	mariadb -e "FLUSH PRIVILEGES;"

	# Shut down temporary server
	mysqladmin --user=root shutdown
	wait $MARIADB_PID

	echo "MariaDB setup completed successfully."
else
	echo "MariaDB data directory already exists. Skipping initialization."
fi

# exec replaces this script with mysqld as PID 1
# "$@" passes the CMD from Dockerfile (gosu mysql mysqld)
exec "$@"
