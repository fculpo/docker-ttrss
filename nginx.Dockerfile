FROM nginx:alpine

LABEL maintainer="Fabien Culpo <fabien.culpo@gmail.com> (@fculpo)"

RUN set -ex && apk add --no-cache curl git

WORKDIR /usr/share/nginx/html

# install ttrss
RUN curl -sL https://git.tt-rss.org/git/tt-rss/archive/master.tar.gz | tar xzC ./ --strip-components 1 \
    && git clone https://github.com/hydrian/TTRSS-Auth-LDAP.git /TTRSS-Auth-LDAP \
    && cp -r /TTRSS-Auth-LDAP/plugins/auth_ldap plugins/ \
    && cp config.php-dist config.php

COPY ttrss.nginx.conf /tmp/ttrss.nginx.conf

ENV FPM 127.0.0.1:9000
ENV FPM_DOC_ROOT /var/www/html

CMD [ "sh", "-c", "envsubst '$$FPM $$FPM_DOC_ROOT' < /tmp/ttrss.nginx.conf > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"]
