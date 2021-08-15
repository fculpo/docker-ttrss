FROM php:fpm-alpine3.14
LABEL maintainer="Fabien Culpo <fabien.culpo@gmail.com> (@fculpo)"

RUN set -ex \
    && apk add --update --no-cache postgresql-dev icu-dev \
    && docker-php-ext-install -j$(nproc) intl pdo_pgsql pgsql pcntl

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

WORKDIR /var/www/html
USER www-data

RUN curl -SL https://git.tt-rss.org/git/tt-rss/archive/master.tar.gz | tar xzC ./ --strip-components 1

CMD ["php", "./update_daemon2.php"]
