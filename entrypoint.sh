#!/bin/sh
set -e

# Use ENV to generate a config.php file if one is not provided
if [ ! -f "/var/www/html/config.php" ]; then
    php /configure-db.php
fi

exec "$@"
