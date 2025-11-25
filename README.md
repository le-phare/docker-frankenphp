# lephare/frankenphp Docker image

Pre-configured Docker image that follows [Le Phare](https://www.lephare.com) projects
[recommendations](https://faros.lephare.com)

| Version | Supported until |
|---------|-----------------|
| 8.4     | 31 Dec. 2028    |
| 8.5     | 31 Dec. 2029    |

## Environment variables

- `CADDY_BASIC_AUTH_ADDITIONAL_MATCHERS`
- `CADDY_BASIC_AUTH_APP_ENVS`
- `CADDY_BASIC_AUTH_WHITELISTED_IPS`
- `CADDY_FRANKENPHP_WORKER_CONFIG`
- `CADDY_STATIC_ERROR_PAGES_PATH`
- `CADDY_TRUSTED_PROXIES`

## Docker Image Tags

### PHP 8.5 (default)
- `lephare/frankenphp:latest` or `lephare/frankenphp:8.5` - Production image
- `lephare/frankenphp:prod` or `lephare/frankenphp:8.5-prod` - Production image (alias)
- `lephare/frankenphp:dev` or `lephare/frankenphp:8.5-dev` - Development image

### PHP 8.4
- `lephare/frankenphp:8.4` - Production image
- `lephare/frankenphp:8.4-prod` - Production image (alias)
- `lephare/frankenphp:8.4-dev` - Development image

## PHP Extensions

Both PHP 8.4 and 8.5 images include the following extensions:
- @composer
- apcu
- exif
- gd
- intl
- memcached
- opcache
- pdo_mysql
- pdo_pgsql
- pgsql
- soap
- zip

**PHP 8.5 Limitations:** The following extensions are **not available in PHP 8.5** images due to compatibility issues:
- `imagick` - Image manipulation library
- `xdebug` - Debugging extension (not available in dev images)

If you require these extensions, please use the PHP 8.4 images.

**PHP 8.4 only:** Development images (8.4-dev) include:
- xdebug

