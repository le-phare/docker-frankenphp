# syntax=docker/dockerfile:1
# check=error=true

FROM base

ENV APP_ENV=dev
ENV FRANKENPHP_WORKER_CONFIG=watch
ENV XDEBUG_MODE=off

USER root

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

ARG PHP_EXTENSIONS

RUN set -eux; install-php-extensions ${PHP_EXTENSIONS}

USER php

COPY --link conf.d/20-app.dev.ini $PHP_INI_DIR/app.conf.d/
COPY --link --chmod=755 docker-entrypoint-dev.sh /usr/local/bin/docker-entrypoint

CMD [ "frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile", "--watch" ]
