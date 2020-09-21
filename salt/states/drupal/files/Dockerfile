FROM drupal:8.9.6-fpm-buster

ENV EXT_APCU_VERSION=5.1.18
ENV EXT_UPLOADPROGRESS_VERSION=1.1.3

RUN docker-php-source extract \
    && apt-get update \
    && apt-get install -y ca-certificates git zip unzip libmagickwand-dev libpq-dev libzip-dev libwebp-dev libpng-dev libonig-dev curl python sudo --no-install-recommends \
    && pecl install imagick \
    && mkdir -p /usr/src/php/ext/apcu \
    && mkdir -p /usr/src/php/ext/uploadprogress \
    && curl -fsSL https://github.com/krakjoe/apcu/archive/v$EXT_APCU_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/apcu --strip 1 \
    && curl -fsSL https://github.com/php/pecl-php-uploadprogress/archive/uploadprogress-$EXT_UPLOADPROGRESS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/uploadprogress --strip 1 \
    && docker-php-ext-configure gd --with-jpeg --with-webp \
    && docker-php-ext-install pdo pgsql pdo_pgsql gd intl mbstring zip apcu uploadprogress \
    && docker-php-ext-enable imagick \
    && docker-php-source delete \
    && apt-get clean \
    && apt-get autoclean \
    && apt-get autoremove --purge -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/* /var/tmp/*

RUN COMPOSER_MEMORY_LIMIT=-1 composer require drupal/redhen:1.x-dev drupal/entity:^1.1 drupal/smtp:^1.0 drupal/video_embed_field:^2.4 drupal/scheduler:^1.3 drupal/simple_gmap:^3.0 drupal/addtoany:^1.14 drupal/pathauto:^1.8 drupal/token:^1.7 drupal/devel:^4.0 drupal/ctools:^3.4 drush/drush:^10.3 drupal/bootstrap_layouts:^5.2 drupal/bootstrap:^3.23 drupal/openid_connect:^1.0

WORKDIR /usr/local/share/ca-certificates
ADD development.crt /usr/local/share/ca-certificates/development.crt
RUN /usr/sbin/update-ca-certificates

WORKDIR /var/www
EXPOSE 9000
CMD ["php-fpm"]
