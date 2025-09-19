FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    mariadb-server mariadb-client \
    && rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/dbinit.sh /usr/local/bin/dbinit.sh
RUN chmod +x /usr/local/bin/dbinit.sh

RUN mkdir -p /var/lib/mysql /run/mysqld  && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/dbinit.sh"]


