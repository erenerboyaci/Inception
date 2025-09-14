#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_PASSWORD_ADMIN=$(cat /run/secrets/db_root_password)

until nc -z "${DB_HOST}" 3306; do
    sleep 2
done

if [ ! -f /var/www/html/wp-config.php ]; then
    wp core download --allow-root --path=/var/www/html
    wp config create --dbname="${DB_NAME}" --dbuser="${DB_USER}" --dbpass="${DB_PASSWORD}" \
        --dbhost="${DB_HOST}" --allow-root --path=/var/www/html
    wp core install --url="${DOMAIN_NAME}" --title="${WP_TITLE}" \
        --admin_user="${WP_USER_ADMIN}" --admin_password="${WP_PASSWORD_ADMIN}" \
        --admin_email="${WP_EMAIL_ADMIN}" --skip-email --allow-root --path=/var/www/html
    wp user create "${DB_USER}" "${MYSQL_EMAIL}" --role=author \
        --user_pass="${DB_PASSWORD}" --allow-root --path=/var/www/html
    chown -R www-data:www-data /var/www/html
fi

exec php-fpm8.2 -F