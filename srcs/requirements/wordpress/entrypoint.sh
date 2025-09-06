#!/bin/bash

# Run WordPress setup
/setup_wordpress.sh

# Start PHP-FPM
exec php-fpm8.2 -F
