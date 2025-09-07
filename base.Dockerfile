# syntax=docker/dockerfile:1
# check=error=true

FROM dunglas/frankenphp:1-php8.4

WORKDIR /var/www/symfony

ARG PHP_EXTENSIONS

RUN set -eux; \
    apt-get -y update; \
    apt-get -y upgrade; \
    install-php-extensions ${PHP_EXTENSIONS}; \
    groupadd -g 1000 php && useradd --no-log-init -u 1000 -g php php; \
    rm -rf /etc/caddy /etc/frankenphp; \
    mkdir /etc/caddy; \
    chown php:php -R /app/public /config/caddy /data/caddy /etc/caddy /var/www/symfony

USER php

ENV PHP_INI_SCAN_DIR=":$PHP_INI_DIR/app.conf.d"

COPY --link conf.d/10-app.ini $PHP_INI_DIR/app.conf.d/
COPY --link --chown=1000:1000 ./caddy/ /etc/caddy/le_phare/
COPY --link --chown=1000:1000 ./Caddyfile /etc/caddy/

ENTRYPOINT ["docker-entrypoint"]

HEALTHCHECK --start-period=60s CMD curl -f http://localhost:2019/metrics || exit 1

CMD [ "frankenphp", "run" ]
