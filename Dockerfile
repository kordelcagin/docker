FROM composer AS composer
FROM php:8.1-apache as php-apache
RUN apt-get update && apt-get upgrade -y && apt-get install libzip-dev -y
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli && pecl install redis && docker-php-ext-enable redis && docker-php-ext-install zip && docker-php-ext-enable zip

# Copy the composer binary to the container
COPY --from=composer /usr/bin/composer /usr/bin/composer
# Composer needs to run as root to allow the use of a bind-mounted cache volume
ENV COMPOSER_ALLOW_SUPERUSER=1

# Enable headers/rewrite module for Apache
RUN a2enmod headers rewrite