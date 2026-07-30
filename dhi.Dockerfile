# syntax=docker/dockerfile:1
# check=error=true

ARG PHP_VERSION=8.5

FROM dhi.io/debian-base:trixie AS dhi-base

FROM dunglas/frankenphp:php${PHP_VERSION} AS builder

ARG PHP_EXTENSIONS

# Only copy the libs the hardened base lacks: copying its own (libc…) would put
# a second, possibly different version of them in /usr/lib.
RUN --mount=type=bind,from=dhi-base,target=/base <<-EOF
    set -eux
    apt-get -y update
    apt-get -y upgrade
    apt-get install -y --no-install-recommends libtree
    install-php-extensions ${PHP_EXTENSIONS}
    [ -d /base/usr/lib ]
    mkdir -p /tmp/libs
    for target in $(which frankenphp) \
        $(find "$(php -r 'echo ini_get("extension_dir");')" -maxdepth 2 -name "*.so"); do
        deps="$(libtree -pv "$target")"
        if printf '%s\n' "$deps" | grep -q 'not found'; then
            printf 'Unresolved dependency for %s:\n%s\n' "$target" "$deps" >&2
            exit 1
        fi
        # -v always lists libc, so no match means libtree's output format changed:
        # let grep's failure abort the build rather than silently copy nothing.
        libs="$(printf '%s\n' "$deps" | grep -oP '(?:── )\K/\S+(?= \[)')"
        for lib in $libs; do
            [ -e "/base$lib" ] || [ -e "/base/usr/lib/$(basename "$lib")" ] || cp -n "$lib" /tmp/libs/
        done
    done
EOF

FROM dhi-base AS dhi-prod

COPY --from=builder /usr/local/bin/frankenphp /usr/local/bin/frankenphp
COPY --from=builder /usr/local/bin/php /usr/local/bin/php
COPY --from=builder /usr/local/bin/composer /usr/local/bin/composer

COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions
COPY --from=builder /tmp/libs /usr/lib

COPY --from=builder /usr/local/etc/php/conf.d /usr/local/etc/php/conf.d
COPY --from=builder /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

COPY --link ./caddy/ /etc/caddy/le_phare/
COPY --link ./Caddyfile /etc/caddy/

ENV PHP_INI_SCAN_DIR=":/usr/local/etc/php/app.conf.d"

COPY --link conf.d/10-app.ini /usr/local/etc/php/app.conf.d/
COPY --link conf.d/20-app.prod.ini /usr/local/etc/php/app.conf.d/

# PHP only warns when an extension fails to load (e.g. a lib missing from the
# hardened base), so fail the build instead of the container start.
RUN php -r ' \
        foreach (array_map("trim", explode(",", php_ini_scanned_files())) as $ini) { \
            $ext = parse_ini_file($ini, false, INI_SCANNER_RAW)["extension"] ?? null; \
            if (null !== $ext && !extension_loaded(basename($ext, ".so"))) { \
                fwrite(STDERR, "Extension $ext from $ini failed to load\n"); \
                exit(1); \
            } \
        }' \
    && composer --version

COPY --link --chmod=644 docker-entrypoint-common.sh /usr/local/lib/
COPY --link --chmod=755 docker-entrypoint-dhi.sh /usr/local/bin/docker-entrypoint

ENV XDG_CONFIG_HOME=/config XDG_DATA_HOME=/data

COPY --from=builder --chown=nonroot:nonroot /data /data
COPY --from=builder --chown=nonroot:nonroot /config /config

ENV APP_ENV=prod

# The base runs as nonroot, which could otherwise rename the app code away.
# Its passwd has no root user, hence the UID.
USER 0
WORKDIR /var/www/symfony

USER nonroot

ENTRYPOINT ["docker-entrypoint"]

CMD [ "frankenphp", "run" ]

HEALTHCHECK --start-period=60s CMD ["php", "-r", "exit(false === @file_get_contents('http://localhost:2019/metrics') ? 1 : 0);"]
