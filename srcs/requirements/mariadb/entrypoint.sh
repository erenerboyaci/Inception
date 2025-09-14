# #!/bin/bash

# # This script is placed in /docker-entrypoint-initdb.d/ and will be executed automatically
# # during the first startup of MariaDB

# DB_USER=${DB_USER}
# DB_NAME=${DB_NAME}
# DB_PASSWORD=$(cat /run/secrets/db_password)

# echo "Creating database ${DB_NAME} and user ${DB_USER}..."

# mysql -u root <<EOSQL
# CREATE DATABASE IF NOT EXISTS ${DB_NAME};
# CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
# GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
# FLUSH PRIVILEGES;
# EOSQL

# echo "Database setup completed."
