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
- `DATABASE_WAIT_ATTEMPTS`: how many times (1 per second) the prod entrypoints try to reach the database, defaults to 60

## Hardened image (`lephare/frankenphp-hardened`)

The app code is meant to stay read-only at runtime, so unlike `lephare/frankenphp`, the entrypoint doesn't
dump the Composer autoloader. Run it in your own build:

```dockerfile
RUN composer dump-autoload --classmap-authoritative --no-dev
```
