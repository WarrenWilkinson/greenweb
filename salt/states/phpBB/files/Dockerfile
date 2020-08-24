FROM php:7.4.9-fpm

VOLUME /var/www

RUN docker-php-source extract \
    && apt-get update \
    && apt-get install -y libmagickwand-dev libpq-dev libwebp-dev libpng-dev --no-install-recommends \
    && pecl install imagick \
    && docker-php-ext-configure gd --with-jpeg --with-webp \
    && docker-php-ext-install pdo_pgsql gd \
    && docker-php-ext-enable imagick \
    && docker-php-source delete \
    && apt-get clean \
    && apt-get autoclean \
    && apt-get autoremove --purge -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

# RUN curl -Lo phpBB-3.3.1.tar.bz2  https://download.phpbb.com/pub/release/3.3/3.3.1/phpBB-3.3.1.tar.bz2 \
#     && tar -xjf phpBB-3.3.1.tar.bz2 \
#     && mv phpBB3/* /var/www/html/ \
#     && bash -c "mv phpBB3/.[^.]* /var/www/html/" \
#     && rm -rf phpBB-3.3.1.tar.bz2 phpBB3 \
#     && chown -R www-data:www-data /var/www/html \
#     && chmod 755 -R /var/www/html \
#     && chmod 660 /var/www/html/images/avatars/upload/ /var/www/html/config.php \
#     && chmod 770 /var/www/html/store/ /var/www/html/cache/ /var/www/html/files/

WORKDIR /var/www
EXPOSE 9000
CMD ["php-fpm"]
