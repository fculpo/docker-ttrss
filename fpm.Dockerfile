FROM php:fpm-alpine3.14
LABEL maintainer="Fabien Culpo <fabien.culpo@gmail.com> (@fculpo)"

RUN set -ex \
  && apk add --update --no-cache libjpeg-turbo-dev freetype-dev libpng-dev openldap-dev postgresql-dev icu-dev git \
  && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) intl ldap gd opcache pdo_pgsql pgsql

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

WORKDIR /var/www/html
USER www-data

# install ttrss
RUN curl -SL https://git.tt-rss.org/git/tt-rss/archive/master.tar.gz | tar xzC ./ --strip-components 1 \
  && git clone https://github.com/hydrian/TTRSS-Auth-LDAP.git ./TTRSS-Auth-LDAP \
  && cp -r ./TTRSS-Auth-LDAP/plugins/auth_ldap plugins/

CMD ["php-fpm"]
