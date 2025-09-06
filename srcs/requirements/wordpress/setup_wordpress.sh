#!/bin/bash

# This script is called by the entrypoint.sh to setup WordPress
# Get credentials from environment and security files
DB_USER=${DB_USER}
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_NAME=${DB_NAME}
DB_HOST=${DB_HOST}
DOMAIN_NAME=${DOMAIN_NAME}
WP_TITLE=${WP_TITLE}
WP_USER_ADMIN=${WP_USER_ADMIN}
WP_EMAIL_ADMIN=${WP_EMAIL_ADMIN}
# Use the root password for WordPress admin for better security
WP_PASSWORD_ADMIN=$(cat /run/secrets/db_root_password)

# Wait for MariaDB to be available
until nc -z "${DB_HOST}" 3306; do
    echo "Waiting for MariaDB to be ready..."
    sleep 5
done

# Install WordPress if not already installed
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress not installed. Installing..."
    if ! wp core download --allow-root --path=/var/www/html; then
        echo "Error: Failed to download WordPress."
        exit 1
    fi
    if ! wp config create --dbname="${DB_NAME}" --dbuser="${DB_USER}" --dbpass="${DB_PASSWORD}" --dbhost="${DB_HOST}" --allow-root --path=/var/www/html; then
        echo "Error: Failed to create wp-config.php."
        exit 1
    fi
    if ! wp core install --url="${DOMAIN_NAME}" --title="${WP_TITLE}" --admin_user="${WP_USER_ADMIN}" --admin_password="${WP_PASSWORD_ADMIN}" --admin_email="${WP_EMAIL_ADMIN}" --skip-email --allow-root --path=/var/www/html; then
        echo "Error: Failed to install WordPress."
        exit 1
    fi
    
    # Create regular user account
    if ! wp user create "${DB_USER}" "${MYSQL_EMAIL}" --role=author --user_pass="${DB_PASSWORD}" --allow-root --path=/var/www/html; then
        echo "Warning: Failed to create regular WordPress user, may already exist."
    fi
    
    # Enable pretty permalinks
    wp rewrite structure '/%postname%/' --allow-root --path=/var/www/html
    
    # Enable comments
    wp option update default_comment_status 'open' --allow-root --path=/var/www/html
    wp option update require_name_email '1' --allow-root --path=/var/www/html
    
    # Set proper permissions
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
    
    echo "WordPress installed successfully."
else
    echo "WordPress already installed."
fi
