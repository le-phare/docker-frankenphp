# syntax=docker/dockerfile:1
# check=error=true

FROM dunglas/frankenphp:1-php8.4-alpine

RUN apk upgrade

WORKDIR /var/www/symfony

RUN set -eux; addgroup -g 1000 -S php && adduser -G php -S -u 1000 php

ARG PHP_EXTENSIONS

RUN set -eux; install-php-extensions ${PHP_EXTENSIONS}

ENV PHP_INI_SCAN_DIR=":$PHP_INI_DIR/app.conf.d"

COPY --link conf.d/10-app.ini $PHP_INI_DIR/app.conf.d/
COPY --link Caddyfile /etc/frankenphp/Caddyfile

ENTRYPOINT ["docker-entrypoint"]

HEALTHCHECK --start-period=60s CMD curl -f http://localhost:2019/metrics || exit 1

CMD [ "frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile" ]
