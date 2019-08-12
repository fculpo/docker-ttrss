FROM php:alpine
LABEL maintainer="Fabien Culpo <fabien.culpo@gmail.com> (@fculpo)"

RUN set -ex \
    && apk add --update --no-cache postgresql-dev icu-dev \
    && docker-php-ext-install -j$(nproc) intl pdo_pgsql pgsql pcntl

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY configure-db.php /configure-db.php
COPY entrypoint.sh /entrypoint.sh
RUN chown www-data:www-data /configure-db.php /entrypoint.sh

WORKDIR /var/www/html
USER www-data

RUN curl -SL https://git.tt-rss.org/git/tt-rss/archive/master.tar.gz | tar xzC ./ --strip-components 1

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php", "./update_daemon2.php"]
