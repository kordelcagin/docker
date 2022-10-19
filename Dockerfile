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

# Create the project root folder and assign ownership to the pre-existing www-data user
RUN mkdir -p /var/www/html /.composer && chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

COPY --chown=www-data composer.json /var/www/html/

# Install all composer dependencies without running the autoloader and the scripts since these
# actions rely on the source files of the application.
# Also, volume mounting a bind-mounted cache to composer's /.composer folder helps speeding up the build
# since even when you break the cache by adding/removing a composer package, all previously installed
# packages are served from the mounted cache.
RUN --mount=type=cache,target=/.composer/cache composer install --no-autoloader --no-scripts

# Copy the rest of the source code to the container. Now, if source files are changed, the cache-layer
# breaks here and the only the 'composer dump-autoload' command will have to run again.
COPY --chown=www-data . /var/www/html/

# Generate an optimized autoloader after copying the source files to the container
RUN composer dump-autoload --optimize

# Change ownership of the root folder to www-data
RUN chown -R www-data:www-data vendor/

#COPY composer.json composer.json
#RUN composer require slim/slim:"4.*" slim/psr7 nyholm/psr7 nyholm/psr7-server guzzlehttp/psr7 "^2" laminas/laminas-diactoros