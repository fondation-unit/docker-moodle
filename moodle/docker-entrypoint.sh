#!/bin/sh
set -e

mkdir -p /var/moodledata
chown -R www-data:www-data /var/moodledata
chmod -R 777 /var/moodledata

exec docker-php-entrypoint "$@"
