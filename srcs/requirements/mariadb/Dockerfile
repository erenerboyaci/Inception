FROM debian:bookworm

RUN  apt-get update && apt-get install -y \
     mariadb-server \
     mariadb-client \
     && rm -rf /var/lib/apt/lists/*

# Create directory for initialization scripts
RUN mkdir -p /docker-entrypoint-initdb.d/

# Configure MariaDB to accept connections from any IP
RUN sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy the main database initialization script
COPY tools/dbinit.sh /dbinit.sh
RUN chmod +x /dbinit.sh

EXPOSE 3306

ENTRYPOINT [ "dbinit.sh" ]