#!/bin/sh
set -e

mkdir -p /var/moodledata
chown -R www-data:www-data /var/moodledata
chmod -R 777 /var/moodledata

# Create the log file for msmtp and cron
touch /var/log/msmtp.log
chmod 666 /var/log/msmtp.log
touch /var/log/cron.log
chmod 666 /var/log/cron.log

# Create msmtp config with logging
cat > /etc/msmtprc <<EOL
defaults
auth on
tls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile /var/log/msmtp.log

account default
host ${SMTP_HOST}
port ${SMTP_PORT:-587}
user ${SMTP_USER}
password ${SMTP_PASS}
from ${SMTP_USER}
EOL

chmod 644 /etc/msmtprc

# Create cron job with the environment variables
cat > /etc/cron.d/moodle <<EOL
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
MYSQL_DATABASE=${MYSQL_DATABASE}
MYSQL_USER=${MYSQL_USER}
MYSQL_PASSWORD=${MYSQL_PASSWORD}
DOMAIN_NAME=${DOMAIN_NAME}
SMTP_HOST=${SMTP_HOST}
SMTP_USER=${SMTP_USER}
SMTP_PASS=${SMTP_PASS}
SMTP_SECURE=${SMTP_SECURE}
SMTP_AUTHTYPE=${SMTP_AUTHTYPE}
SMTP_PORT=${SMTP_PORT}

*/2 * * * * www-data /usr/local/bin/php /var/www/html/admin/cli/cron.php >> /var/log/cron.log 2>&1

EOL

chmod 0644 /etc/cron.d/moodle

# Start cron
cron

exec docker-php-entrypoint "$@"
