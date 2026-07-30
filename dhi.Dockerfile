# syntax=docker/dockerfile:1
# check=error=true

ARG PHP_VERSION=8.5

FROM dunglas/frankenphp:php${PHP_VERSION} AS builder

ARG PHP_EXTENSIONS

RUN <<-EOF
    set -eux
    apt-get -y update
    apt-get -y upgrade
    apt-get install -y --no-install-recommends libtree
    install-php-extensions ${PHP_EXTENSIONS}
    mkdir -p /tmp/libs
    for target in $(which frankenphp) \
        $(find "$(php -r 'echo ini_get("extension_dir");')" -maxdepth 2 -name "*.so"); do
        libtree -pv "$target" 2>/dev/null | grep -oP '(?:── )\K/\S+(?= \[)' | while IFS= read -r lib; do
            [ -f "$lib" ] && cp -n "$lib" /tmp/libs/
        done
    done
EOF

FROM dhi.io/debian-base:trixie AS dhi-prod

COPY --from=builder /usr/local/bin/frankenphp /usr/local/bin/frankenphp
COPY --from=builder /usr/local/bin/php /usr/local/bin/php

COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /tmp/libs /usr/lib

COPY --from=builder /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d
COPY --from=builder /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

COPY --link ./caddy/ /etc/caddy/le_phare/
COPY --link ./Caddyfile /etc/caddy/

COPY --link conf.d/10-app.ini /usr/local/etc/php/app.conf.d/
COPY --link conf.d/20-app.prod.ini /usr/local/etc/php/app.conf.d/
COPY --link --chmod=755 docker-entrypoint-prod.sh /usr/local/bin/docker-entrypoint

ENV XDG_CONFIG_HOME=/config XDG_DATA_HOME=/data

COPY --from=builder --chown=nonroot:nonroot /data /data
COPY --from=builder --chown=nonroot:nonroot /config /config

ENV APP_ENV=prod

USER nonroot

WORKDIR /var/www/symfony

ENTRYPOINT ["docker-entrypoint"]

CMD [ "frankenphp", "run" ]

HEALTHCHECK --start-period=60s CMD curl -f http://localhost:2019/metrics || exit 1
