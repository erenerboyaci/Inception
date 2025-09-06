#!/bin/bash

/setup_wordpress.sh

exec php-fpm8.2 -F
