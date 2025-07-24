variable "PHP_VERSION" {
  default = "8.4"
}

variable "REPO" {
  default = "lephare/frankenphp"
}

// Special target: https://github.com/docker/metadata-action#bake-definition
target "docker-metadata-action" {}

group "default" {
  targets = ["dev-local", "prod-local"]
}

group "image-all" {
  targets = ["dev-all", "prod-all"]
}

target "base" {
  inherits = ["docker-metadata-action"]
  args = {
    PHP_EXTENSIONS = "@composer apcu exif gd imagick intl memcached opcache pdo_mysql pdo_pgsql pgsql soap zip"
  }
  dockerfile = "base.Dockerfile"
}

target "dev" {
  inherits = ["docker-metadata-action"]
  args = {
    PHP_EXTENSIONS = "xdebug"
  }
  contexts = {
    base = "target:base"
  }
  dockerfile = "dev.Dockerfile"
  tags = [
    "${REPO}:${PHP_VERSION}-dev",
    "${REPO}:dev",
  ]
}

target "dev-local" {
  inherits = ["dev"]
  output = ["type=docker"]
}

target "dev-all" {
  inherits = ["dev"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}

target "prod" {
  inherits = ["docker-metadata-action"]
  contexts = {
    base = "target:base"
  }
  dockerfile = "prod.Dockerfile"
  tags = [
    "${REPO}:${PHP_VERSION}-prod",
    "${REPO}:prod",
    "${REPO}:${PHP_VERSION}",
    "${REPO}:latest",
  ]
}

target "prod-local" {
  inherits = ["prod"]
  output = ["type=docker"]
}

target "prod-all" {
  inherits = ["prod"]
}
