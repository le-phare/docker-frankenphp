#syntax=docker/dockerfile:1

FROM base

ENV APP_ENV=prod

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY --link conf.d/20-app.prod.ini $PHP_INI_DIR/app.conf.d/
COPY --link --chmod=755 docker-entrypoint-prod.sh /usr/local/bin/docker-entrypoint
