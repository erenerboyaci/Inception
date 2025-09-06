#!/bin/bash

# Get credentials from environment and security files
DB_ROOT_PASSWORD=$(cat /etc/security/db_root_password.txt)
DB_USER=${DB_USER}
DB_PASSWORD=$(cat /etc/security/db_password.txt)
DB_NAME=${DB_NAME}

# Initialize database if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MySQL in the background for initialization
mysqld_safe --user=mysql --skip-networking --datadir=/var/lib/mysql &

# Wait for MySQL to be ready
while ! mysqladmin ping -h"localhost" --silent; do
    sleep 1
done

# Set root password and remove test database
mysql -u root <<EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOSQL

# Create WordPress database and user
mysql -u root -p"$DB_ROOT_PASSWORD" <<EOSQL
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;
EOSQL

# Shut down the temporary MySQL instance
mysqladmin -u root -p"$DB_ROOT_PASSWORD" shutdown

# Start MySQL as the main process (PID 1)
exec mysqld --user=mysql --datadir=/var/lib/mysql