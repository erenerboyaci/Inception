#!/bin/bash

echo "server { "  >> /etc/nginx/sites-enabled/default
echo "	listen 443 ssl;"  >> /etc/nginx/sites-enabled/default
echo "	listen [::]:443 ssl;"  >> /etc/nginx/sites-enabled/default
echo "	server_name $DOMAIN_NAME;"  >> /etc/nginx/sites-enabled/default

echo "	ssl_certificate $CERTIFICICATES_OUT; "  >> /etc/nginx/sites-enabled/default
echo "	ssl_certificate_key $CERTIFICICATES_KEYOUT; "  >> /etc/nginx/sites-enabled/default
echo "	ssl_protocols TLSv1.3;"  >> /etc/nginx/sites-enabled/default

echo "	root /var/www/html;"  >> /etc/nginx/sites-enabled/default

echo "	index index.php;"  >> /etc/nginx/sites-enabled/default

echo '        location / {'  >> /etc/nginx/sites-enabled/default
echo '                try_files $uri $uri/ =404;'  >> /etc/nginx/sites-enabled/default
echo '        }'  >> /etc/nginx/sites-enabled/default
 
echo "	location ~ \.php$ { "  >> /etc/nginx/sites-enabled/default
echo "		include snippets/fastcgi-php.conf;"  >> /etc/nginx/sites-enabled/default
echo "		fastcgi_pass $MYSQL_DATABASE_NAME:9000;"  >> /etc/nginx/sites-enabled/default
echo "		proxy_connect_timeout 300s; "  >> /etc/nginx/sites-enabled/default
echo "		proxy_send_timeout 300s; "  >> /etc/nginx/sites-enabled/default
echo "		proxy_read_timeout 300s; "  >> /etc/nginx/sites-enabled/default
echo "		fastcgi_send_timeout 300s; "  >> /etc/nginx/sites-enabled/default
echo "		fastcgi_read_timeout 300s; " >> /etc/nginx/sites-enabled/default
echo "	} "  >> /etc/nginx/sites-enabled/default
echo "}" >> /etc/nginx/sites-enabled/default

mkdir -p /etc/ssl/certs
mkdir -p /etc/ssl/private
mkdir -p /etc/nginx/ssl

if [ ! -f $CERTIFICICATES_OUT ]; then
    openssl req \
    -newkey rsa:2048 \
    -nodes \
    -keyout $CERTIFICICATES_KEYOUT \
    -x509 \
    -days 365 \
    -out $CERTIFICICATES_OUT \
    -subj "/C=TR/ST=KOCAELI/L=GEBZE/O=42Kocaeli/CN=$DOMAIN_NAME";
    
    # Also create copies in nginx ssl directory for our config
    cp $CERTIFICICATES_OUT /etc/nginx/ssl/nginx.crt
    cp $CERTIFICICATES_KEYOUT /etc/nginx/ssl/nginx.key
fi

exec "$@"