FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /etc/nginx/ssl

# Copy Nginx configuration and SSL setup script
COPY conf/nginx.conf /etc/nginx/conf/nginx.conf
COPY tools/ssl-setup.sh /usr/local/bin/ssl-setup.sh
RUN chmod +x /usr/local/bin/ssl-setup.sh

# Create log directory if it doesn't exist
RUN mkdir -p /var/log/nginx

EXPOSE 443

# Setup SSL and run Nginx
ENTRYPOINT ["/usr/local/bin/ssl-setup.sh"]
CMD ["nginx", "-g", "daemon off;"]