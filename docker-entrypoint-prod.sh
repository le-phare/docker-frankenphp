#!/bin/sh
set -e

. /usr/local/lib/docker-entrypoint-common.sh

if is_app_command "$1"; then
	composer dump-autoload --classmap-authoritative --no-dev
	init_app
fi

exec docker-php-entrypoint "$@"
