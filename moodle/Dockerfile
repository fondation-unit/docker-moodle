FROM php:8.2-fpm

ENV PHP_INI_DIR=/usr/local/etc/php
COPY ./php.ini "$PHP_INI_DIR/php.ini"

RUN apt-get -y update && apt-get install -y \
    cron \
    g++ \
    libzip-dev \
    libxml2-dev \
    libicu-dev \
    libpng-dev \
    locales \
    msmtp \
    zlib1g-dev

RUN docker-php-ext-install exif
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install opcache
RUN docker-php-ext-install gd
RUN docker-php-ext-install soap
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl
RUN docker-php-ext-configure zip
RUN docker-php-ext-install zip

RUN pecl install channel://pecl.php.net/xmlrpc-1.0.0RC3
RUN docker-php-ext-enable xmlrpc

# Configure PHP to use msmtp for mail()
RUN echo "sendmail_path = /usr/bin/msmtp -t" >> /usr/local/etc/php/conf.d/sendmail.ini

# Generate locales from LOCALES env variable
RUN for locale in $LOCALES; do \
    sed -i -e "s/# $locale/$locale/" /etc/locale.gen; \
    done && \
    locale-gen

ENV LANG=fr_FR.UTF-8
ENV LC_ALL=fr_FR.UTF-8

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Redis
RUN pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

# Memcached
# RUN apt-get install -y libmemcached-dev \
#     && pecl install memcached \
#     && docker-php-ext-enable memcached

WORKDIR /var/www/html/
RUN mkdir /var/moodledata

COPY ./src /var/www/html
COPY ./config.php /var/www/html/config.php

RUN composer install --no-dev --classmap-authoritative
RUN chown -R www-data:www-data /var/www/html/*

# Entrypoint
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]