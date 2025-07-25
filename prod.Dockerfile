# syntax=docker/dockerfile:1
# check=error=true

FROM base

ENV APP_ENV=prod

USER root

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

USER php

COPY --link conf.d/20-app.prod.ini $PHP_INI_DIR/app.conf.d/
COPY --link --chmod=755 docker-entrypoint-prod.sh /usr/local/bin/docker-entrypoint
