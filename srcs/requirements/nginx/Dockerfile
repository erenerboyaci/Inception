FROM debian:bullseye

RUN apt-get update -y && apt-get install -y; apt-get install -y nginx openssl

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes \
	-days 365 \
	-newkey rsa:4096 \
	-keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt \
	-subj "/C=TR/ST=Kocaeli/L=Kocaeli/O=42/OU=42/CN=merboyac.42.fr"

COPY ./conf/nginx.conf /etc/nginx/conf.d/nginx.conf

CMD ["nginx", "-g", "daemon off;"]