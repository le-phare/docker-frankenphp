#!/bin/sh
set -e

. /usr/local/lib/docker-entrypoint-common.sh

# The hardened base lacks dunglas' docker-php-entrypoint, which only does this
if [ "${1#-}" != "$1" ]; then
	set -- frankenphp run "$@"
fi

if is_app_command "$1"; then
	init_app
fi

exec "$@"
