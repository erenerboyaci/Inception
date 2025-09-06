#!/bin/bash
set -e

echo "Starting SSL setup..."

# Create directories if they don't exist
mkdir -p /etc/nginx/ssl

# Generate self-signed SSL certificate if not exists
if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    echo "Generating self-signed SSL certificate..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=TR/ST=KOCAELI/L=GEBZE/O=42Kocaeli/CN=merboyac.42.fr"
    
    chmod 600 /etc/nginx/ssl/nginx.key
    chmod 644 /etc/nginx/ssl/nginx.crt
    echo "SSL certificate generated successfully."
fi

echo "SSL certificates prepared at /etc/nginx/ssl/"
ls -la /etc/nginx/ssl/

# Check that nginx.conf exists
if [ -f /etc/nginx/nginx.conf ]; then
    echo "Default nginx.conf exists, moving to backup"
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
fi

# Copy our custom configuration
echo "Copying custom nginx configuration..."
cp /etc/nginx/conf/nginx.conf /etc/nginx/nginx.conf

# Test the configuration
echo "Testing Nginx configuration..."
nginx -t

echo "Starting Nginx..."
exec "$@"
