FROM alpine:3.9

ARG PHP_VERSION=7.3
ARG MICROWEBER_VERSION=dev-master

ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

RUN set -eux; \
    apk --update add ca-certificates; \
    echo "@php https://dl.bintray.com/php-alpine/v3.9/php-${PHP_VERSION}" >> /etc/apk/repositories; \
    apk --no-cache --update add \
        apache2 apache2-utils bash git busybox-suid nano postgresql-client sed sudo \
        php7@php \
        php7-amqp@php \
        php7-apache2@php \
        php7-apcu@php \
        php7-bcmath@php \
        php7-dom@php \
        php7-ctype@php \
        php7-curl@php \
        php7-gd@php \
        php7-gmp@php \
        php7-iconv@php \
        php7-imagick@php \
        php7-intl@php \
        php7-json@php \
        php7-mbstring@php \
        php7-opcache@php \
        php7-openssl@php \
        php7-pdo@php \
        php7-pdo_pgsql@php \
        php7-phar@php \
        php7-phpdbg@php \
        php7-session@php \
        php7-soap@php \
        php7-sysvsem@php \
        php7-xml@php \
        php7-xmlreader@php \
        php7-zip@php \
        php7-zlib@php \
        ; \
    ln -s /usr/bin/php7 /usr/bin/php; \
    chown -R apache:apache /var/www; \
    php -v


COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV PATH="${PATH}:/root/.composer/vendor/bin"

USER apache
WORKDIR /var/www

RUN set -eux; \
    composer global require "hirak/prestissimo:^0.3" --prefer-dist --no-progress --no-suggest --classmap-authoritative; \
    composer create-project microweber/microweber /var/www/microweber ${MICROWEBER_VERSION} --no-progress --prefer-dist --no-dev --no-scripts; \
    composer clear-cache;

# shelve config and userfiles so they don't confict with VOLUMES
RUN mkdir -p /var/www/microweber-defaults; \
    mv /var/www/microweber/config /var/www/microweber-defaults; \
    mv /var/www/microweber/userfiles /var/www/microweber-defaults; \
    mkdir -p /var/www/microweber/config /var/www/microweber/userfiles


USER root

WORKDIR /var/www/microweber

COPY ./php.ini /etc/php7/conf.d/50_setting.ini
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint

VOLUME /var/www/microweber/config
VOLUME /var/www/microweber/userfiles

EXPOSE 80

ENTRYPOINT ["docker-entrypoint"]
CMD ["httpd", "-DFOREGROUND"]
