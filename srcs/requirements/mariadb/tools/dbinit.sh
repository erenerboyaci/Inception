#!/bin/bash

# Get credentials from environment and security files
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=$(cat /run/secrets/db_password)
WP_USER_ADMIN=${WP_USER_ADMIN}
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

echo "Starting MariaDB initialization..."

# Initialize database if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Installing MySQL system tables..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MySQL in the background for initialization
echo "Starting temporary MySQL instance for setup..."
mysqld_safe --user=mysql --skip-networking --datadir=/var/lib/mysql &

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
while ! mysqladmin ping -h"localhost" --silent; do
    sleep 1
done

# Set root password and remove test database
echo "Setting up root user and cleaning up..."
mysql -u root <<EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
FLUSH PRIVILEGES;
EOSQL

# Create WordPress database and users
echo "Creating database ${DB_NAME} and users ${DB_USER}, ${WP_USER_ADMIN}..."
mysql -u root -p"$DB_ROOT_PASSWORD" <<EOSQL
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
CREATE USER IF NOT EXISTS '$WP_USER_ADMIN'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$WP_USER_ADMIN'@'%';
FLUSH PRIVILEGES;
EOSQL

# Shut down the temporary MySQL instance
echo "Shutting down temporary MySQL instance..."
mysqladmin -u root -p"$DB_ROOT_PASSWORD" shutdown

echo "Database setup completed. Starting MariaDB as main process..."

# Start MySQL as the main process (PID 1)
exec mysqld --user=mysql --datadir=/var/lib/mysql