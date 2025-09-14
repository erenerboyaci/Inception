#!/bin/bash
set -e

mkdir -p /etc/nginx/ssl
mkdir -p /var/log/nginx

if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=TR/ST=KOCAELI/L=GEBZE/O=42Kocaeli/CN=${DOMAIN_NAME}"
    
    chmod 600 /etc/nginx/ssl/nginx.key
    chmod 644 /etc/nginx/ssl/nginx.crt
fi
if [ -f /etc/nginx/nginx.conf ] && [ ! -L /etc/nginx/nginx.conf ]; then
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup
fi

cp /etc/nginx/conf/nginx.conf /etc/nginx/nginx.conf

nginx -t

exec nginx -g "daemon off;"