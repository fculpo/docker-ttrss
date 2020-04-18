FROM php:7.4-fpm-alpine3.11
LABEL maintainer="Fabien Culpo <fabien.culpo@gmail.com> (@fculpo)"

RUN set -ex \
  && apk add --update --no-cache libjpeg-turbo-dev freetype-dev libpng-dev openldap-dev postgresql-dev icu-dev git \
  && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) intl ldap gd opcache pdo_pgsql pgsql

COPY configure-db.php /configure-db.php
COPY entrypoint.sh /entrypoint.sh
RUN chown www-data:www-data /configure-db.php /entrypoint.sh
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

WORKDIR /var/www/html
USER www-data

# install ttrss
RUN curl -SL https://git.tt-rss.org/git/tt-rss/archive/master.tar.gz | tar xzC ./ --strip-components 1 \
  && git clone https://github.com/hydrian/TTRSS-Auth-LDAP.git ./TTRSS-Auth-LDAP \
  && cp -r ./TTRSS-Auth-LDAP/plugins/auth_ldap plugins/

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
