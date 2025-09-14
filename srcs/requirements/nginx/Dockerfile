FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /etc/nginx/ssl

# Copy Nginx configuration and initialization script
COPY conf/nginx.conf /etc/nginx/conf/nginx.conf
COPY tools/nginx_init.sh /usr/local/bin/nginx_init.sh
RUN chmod +x /usr/local/bin/nginx_init.sh

EXPOSE 443

# Setup NGINX and run
ENTRYPOINT ["/usr/local/bin/nginx_init.sh"]