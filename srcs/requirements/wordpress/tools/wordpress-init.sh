#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_PASSWORD_ADMIN=$(cat /run/secrets/db_root_password)

for i in $(seq 1 30); do
    if mysqladmin -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASSWORD}" ping --silent; then
        echo "DB is alive!"
        break
    fi
    echo "Waiting for DB..."
    sleep 2
done

if [ ! -f /var/www/html/wp-config.php ]; then
    wp core download --allow-root --path=/var/www/html
    wp config create \
        --dbname="${DB_NAME}" \
        --dbuser="${DB_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="${DB_HOST}" \
        --allow-root \
        --path=/var/www/html
fi

if wp core is-installed --allow-root --path=/var/www/html; then
    echo "WordPress already installed. Skipping install."
else
    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_USER_ADMIN}" \
        --admin_password="${WP_PASSWORD_ADMIN}" \
        --admin_email="${WP_EMAIL_ADMIN}" \
        --skip-email \
        --allow-root \
        --path=/var/www/html
fi

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "Executing wordpress now..."
exec php-fpm7.4 -F