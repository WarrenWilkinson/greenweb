FROM drupal:8.9.4-fpm-buster


RUN docker-php-source extract \
    && apt-get update \
    && apt-get install -y ca-certificates git libmagickwand-dev libpq-dev libzip-dev libwebp-dev libpng-dev libonig-dev --no-install-recommends \
    && pecl install imagick \
    && docker-php-ext-configure gd --with-jpeg --with-webp \
    && docker-php-ext-install pdo pgsql pdo_pgsql gd intl mbstring zip \
    && docker-php-ext-enable imagick \
    && docker-php-source delete \
    && apt-get clean \
    && apt-get autoclean \
    && apt-get autoremove --purge -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

RUN COMPOSER_MEMORY_LIMIT=-1 composer require civicrm/civicrm-asset-plugin:1.0.1 civicrm/civicrm-core:5.29 civicrm/civicrm-packages:5.29 civicrm/civicrm-drupal-8:5.29

## No composer, it's not up to date and causes issues.
## RUN COMPOSER_MEMORY_LIMIT=-1 composer require civicrm/cv:0.3.3
## RUN cv core:install -vv --db="pgsql:host={{ dbhost }};port={{ dbport }};dbname={{ dbname }};user={{ dbuser }};password={{ dbpassword }}" --cms-base-url="{{ base_url }}" --lang="en_US"

WORKDIR /usr/local/share/ca-certificates
ADD development.crt /usr/local/share/ca-certificates/development.crt
RUN /usr/sbin/update-ca-certificates

VOLUME /var/www/html
WORKDIR /var/www
EXPOSE 9000
CMD ["php-fpm"]
