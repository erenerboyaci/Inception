#!/bin/bash
set -e

DB_PASS="$(cat /run/secrets/db_password)"
DB_ROOT_PASS="$(cat /run/secrets/db_root_password)"

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

mysqld_safe --skip-networking --datadir=/var/lib/mysql --user=mysql &
pid="$!"
echo "MARIATEST1"
until mariadb -uroot -e "SELECT 1;" &>/dev/null; do
    sleep 1
done

mariadb -uroot <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
    DELETE FROM mysql.user WHERE User='';
    DROP DATABASE IF EXISTS test;
    FLUSH PRIVILEGES;
EOSQL
echo "MARIATEST2"
mariadb -uroot -p"${DB_ROOT_PASS}" <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
    CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
    CREATE USER IF NOT EXISTS '${WP_USER_ADMIN}'@'%' IDENTIFIED BY '${DB_ROOT_PASS}';
    GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
    GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${WP_USER_ADMIN}'@'%';
    FLUSH PRIVILEGES;
EOSQL
echo "MARIATEST3"
mysqladmin -uroot -p"${DB_ROOT_PASS}" shutdown
wait "$pid" || true

exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0
