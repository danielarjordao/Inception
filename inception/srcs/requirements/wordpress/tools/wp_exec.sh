#!/bin/bash

# Exit immediately if a command fails
set -e

# Read passwords from Docker secrets
DB_PASSWORD=$(cat /run/secrets/db_pass)
admin_pass_wp=$(cat /run/secrets/admin_pass_wp)
user_pass_wp=$(cat /run/secrets/user_pass_wp)

# If WordPress files are missing, copy from staging directory
if ! [ -e "/var/www/html/wp-includes/version.php" ]; then
    rsync -a --chown=www-data:www-data /usr/src/wordpress/. /var/www/html/
fi

# Set correct file permissions and ownership
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html/
mkdir -p /var/www/html/wp-content/
find /var/www/html/wp-content -type d -exec chmod 755 {} \;
find /var/www/html/wp-content -type f -exec chmod 644 {} \;

# Wait for database connection to be ready
wait_for_db() {
    local max_attempts=10
    local attempt=1
    while ! mysqladmin ping -h"$DB_HOST" -u"$DB_USER" -p"$DB_PASSWORD" --silent; do
        if [ $attempt -ge $max_attempts ]; then
            echo "ERROR: Database connection failed."
            exit 1
        fi
        sleep 5
        attempt=$((attempt + 1))
    done
}

# Create wp-config.php with database credentials
wait_for_db

# Remove old wp-config.php if it exists (to ensure fresh credentials)
if [ -f "/var/www/html/wp-config.php" ]; then
    rm -f /var/www/html/wp-config.php
fi

# Create wp-config.php with database connection settings using wp-cli
# gosu runs as www-data user (not root)
gosu www-data wp config create \
    --path=/var/www/html \
    --dbname="$DB_NAME" \
    --dbuser="$DB_USER" \
    --dbpass="$DB_PASSWORD" \
    --dbhost="$DB_HOST" \
    --force

# Generate new security salts for wp-config.php
gosu www-data wp config shuffle-salts --path=/var/www/html

# Install WordPress if not already installed in the database
if ! gosu www-data wp core is-installed --path=/var/www/html 2>&1; then
    echo "Installing WordPress..."
    if gosu www-data wp core install \
        --url="$WP_URL" \
        --title="$WP_SITE_TITLE" \
        --admin_user="$WP_ADMIN_NAME" \
        --admin_password="$admin_pass_wp" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --path=/var/www/html 2>&1; then
        echo "WordPress installed successfully."
    else
        echo "ERROR: WordPress installation failed."
        exit 1
    fi
    # Create a second user if it does not exist
    if ! gosu www-data wp user get "$WP_USER_NAME" --field=ID --path=/var/www/html 2>/dev/null; then
        gosu www-data wp user create "$WP_USER_NAME" "$WP_USER_EMAIL" \
            --user_pass="$user_pass_wp" \
            --role="$WP_USER_ROLE" \
            --path=/var/www/html
    fi
fi

# Prepare PHP-FPM runtime directory
mkdir -p /run/php
chown www-data:www-data /run/php

# Start PHP-FPM as main process
exec "$@"
