FROM php:7.4.9-fpm
VOLUME /var/www

RUN docker-php-source extract \
    && apt-get update \
    && apt-get install -y libmagickwand-dev libpq-dev libwebp-dev libpng-dev --no-install-recommends \
    && pecl install imagick \
    && docker-php-ext-configure gd --with-jpeg --with-webp \
    && docker-php-ext-install pdo pgsql pdo_pgsql gd \
    && docker-php-ext-enable imagick \
    && docker-php-source delete \
    && apt-get clean \
    && apt-get autoclean \
    && apt-get autoremove --purge -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

WORKDIR /var/www
EXPOSE 9000
CMD ["php-fpm"]
