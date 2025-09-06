#!/bin/bash

# Get credentials from environment and security files
DB_USER=${DB_USER}
DB_PASSWORD=$(cat /etc/security/db_password.txt)
DB_ROOT_PASSWORD=$(cat /etc/security/db_root_password.txt)
WP_USER=$(sed -n '1p' /etc/security/credentials.txt)
WP_EMAIL=$(sed -n '5p' /etc/security/credentials.txt)
WP_PASSWORD=$(cat /etc/security/db_password.txt)
WP_USER_ADMIN=${WP_USER_ADMIN}
WP_EMAIL_ADMIN=${WP_EMAIL_ADMIN}
WP_PASSWORD_ADMIN=$(cat /etc/security/db_password.txt)

# Wait for MariaDB to be available
until nc -z "${DB_HOST}" 3306; do
    echo "Waiting for MariaDB to be ready..."
    sleep 5
done

# Install WordPress if not already installed
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "WordPress not installed. Installing..."
    if ! wp core download --allow-root --locale=pt_BR --path=/var/www/html; then
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
    if ! wp user create "${WP_USER}" "${WP_EMAIL}" --role=author --user_pass="${WP_PASSWORD}" --allow-root --path=/var/www/html; then
        echo "Error: Failed to create WordPress user."
        exit 1
    fi
    echo "WordPress installed successfully."
else
    echo "WordPress already installed."
fi

# Start PHP-FPM as the main process
exec php-fpm8.2 -F