FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-intl \
    php8.2-mbstring \
    php8.2-soap \
    php8.2-xml \
    php8.2-xmlrpc \
    php8.2-zip \
    wget \
    unzip \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && php wp-cli.phar --info \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp
    
WORKDIR /var/www/html

# Create PHP-FPM run directory
RUN mkdir -p /run/php

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Copy PHP-FPM configuration
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# Create PHP optimization configuration
COPY conf/php.ini /etc/php/8.2/fpm/conf.d/99-wordpress.ini

# Copy WordPress setup script
COPY setup_wordpress.sh /setup_wordpress.sh
RUN chmod +x /setup_wordpress.sh

# Copy WordPress initialization script
COPY tools/wpinit.sh /wpinit.sh
RUN chmod +x /wpinit.sh

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]