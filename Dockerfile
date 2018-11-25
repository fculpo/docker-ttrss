FROM ubuntu:18.10
MAINTAINER Fabien Culpo <fabien.culpo@gmail.com>

RUN ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime
RUN mkdir -p /run/php

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
  git nginx supervisor php7.2-fpm php7.2-cli php7.2-curl php7.2-gd php7.2-json \
  php7.2-pgsql php7.2-ldap php7.2-mysql php7.2-opcache php7.2-xml php7.2-mbstring curl ca-certificates --no-install-recommends \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# add ttrss as the only nginx site
ADD ttrss.nginx.conf /etc/nginx/sites-available/ttrss
RUN ln -s /etc/nginx/sites-available/ttrss /etc/nginx/sites-enabled/ttrss
RUN rm /etc/nginx/sites-enabled/default

# install ttrss and patch configuration
WORKDIR /var/www
RUN curl -SL https://git.tt-rss.org/git/tt-rss/archive/master.tar.gz | tar xzC /var/www --strip-components 1 \
    && chown www-data:www-data -R /var/www

RUN git clone https://github.com/hydrian/TTRSS-Auth-LDAP.git /TTRSS-Auth-LDAP && \
    cp -r /TTRSS-Auth-LDAP/plugins/auth_ldap plugins/ && \
    ls -la /var/www/plugins

RUN cp config.php-dist config.php

# expose only nginx HTTP port
EXPOSE 80

# complete path to ttrss
ENV SELF_URL_PATH http://localhost

# expose default database credentials via ENV in order to ease overwriting
ENV DB_NAME ttrss
ENV DB_USER ttrss
ENV DB_PASS ttrss

# auth method, options are: internal, ldap
ENV AUTH_METHOD internal

# always re-configure database with current ENV when RUNning container, then monitor all services
ADD configure-db.php /configure-db.php
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
