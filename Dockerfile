# syntax=docker/dockerfile:1
# check=error=true

ARG PHP_VERSION=8.5

FROM dunglas/frankenphp:php${PHP_VERSION} AS base

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

FROM base AS dev

ENV APP_ENV=dev
ENV CADDY_FRANKENPHP_WORKER_CONFIG=watch
ENV XDEBUG_MODE=off

USER root

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN set -eux; install-php-extensions xdebug

USER php

COPY --link conf.d/20-app.dev.ini $PHP_INI_DIR/app.conf.d/
COPY --link --chmod=755 docker-entrypoint-dev.sh /usr/local/bin/docker-entrypoint

CMD [ "frankenphp", "run", "--watch" ]

FROM base AS prod

ENV APP_ENV=prod

USER root

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

USER php

COPY --link conf.d/20-app.prod.ini $PHP_INI_DIR/app.conf.d/
COPY --link --chmod=755 docker-entrypoint-prod.sh /usr/local/bin/docker-entrypoint

CMD [ "frankenphp", "run" ]
