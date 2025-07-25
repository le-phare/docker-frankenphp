# syntax=docker/dockerfile:1
# check=error=true

FROM dunglas/frankenphp:1-php8.4-alpine

WORKDIR /var/www/symfony

ARG PHP_EXTENSIONS

RUN set -eux; \
    apk upgrade; \
    install-php-extensions ${PHP_EXTENSIONS}; \
    addgroup -g 1000 -S php && adduser -G php -S -u 1000 php; \
    chown php:php -R /app/public /config/caddy /data/caddy /etc/caddy /etc/frankenphp /var/www/symfony

USER php

ENV PHP_INI_SCAN_DIR=":$PHP_INI_DIR/app.conf.d"

COPY --link conf.d/10-app.ini $PHP_INI_DIR/app.conf.d/
COPY --link Caddyfile /etc/frankenphp/Caddyfile

ENTRYPOINT ["docker-entrypoint"]

HEALTHCHECK --start-period=60s CMD curl -f http://localhost:2019/metrics || exit 1

CMD [ "frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile" ]
