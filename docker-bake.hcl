variable "REPO" {
  default = "lephare/frankenphp"
}

// Special target: https://github.com/docker/metadata-action#bake-definition
target "docker-metadata-action" {}

group "default" {
  targets = ["dev-8_5-local", "prod-8_5-local"]
}

group "image-all" {
  targets = ["dev-8_4-all", "prod-8_4-all", "dev-8_5-all", "prod-8_5-all"]
}

// PHP 8.4 targets
target "base-8_4" {
  inherits = ["docker-metadata-action"]
  args = {
    PHP_VERSION = "8.4"
    PHP_EXTENSIONS = "@composer apcu exif gd imagick intl memcached opcache pdo_mysql pdo_pgsql pgsql soap zip"
  }
  dockerfile = "base.Dockerfile"
}

target "dev-8_4" {
  inherits = ["docker-metadata-action"]
  args = {
    PHP_EXTENSIONS = "xdebug"
  }
  contexts = {
    base = "target:base-8_4"
  }
  dockerfile = "dev.Dockerfile"
  tags = [
    "${REPO}:8.4-dev",
  ]
}

target "dev-8_4-local" {
  inherits = ["dev-8_4"]
  output = ["type=docker"]
}

target "dev-8_4-all" {
  inherits = ["dev-8_4"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}

target "prod-8_4" {
  inherits = ["docker-metadata-action"]
  contexts = {
    base = "target:base-8_4"
  }
  dockerfile = "prod.Dockerfile"
  tags = [
    "${REPO}:8.4-prod",
    "${REPO}:8.4",
  ]
}

target "prod-8_4-local" {
  inherits = ["prod-8_4"]
  output = ["type=docker"]
}

target "prod-8_4-all" {
  inherits = ["prod-8_4"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}

// PHP 8.5 targets (default)
target "base-8_5" {
  inherits = ["docker-metadata-action"]
  args = {
    PHP_VERSION = "8.5"
    PHP_EXTENSIONS = "@composer apcu exif gd intl memcached opcache pdo_mysql pdo_pgsql pgsql soap zip"
  }
  dockerfile = "base.Dockerfile"
}

target "dev-8_5" {
  inherits = ["docker-metadata-action"]
  args = {
    PHP_EXTENSIONS = ""
  }
  contexts = {
    base = "target:base-8_5"
  }
  dockerfile = "dev.Dockerfile"
  tags = [
    "${REPO}:8.5-dev",
    "${REPO}:dev",
  ]
}

target "dev-8_5-local" {
  inherits = ["dev-8_5"]
  output = ["type=docker"]
}

target "dev-8_5-all" {
  inherits = ["dev-8_5"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}

target "prod-8_5" {
  inherits = ["docker-metadata-action"]
  contexts = {
    base = "target:base-8_5"
  }
  dockerfile = "prod.Dockerfile"
  tags = [
    "${REPO}:8.5-prod",
    "${REPO}:prod",
    "${REPO}:8.5",
    "${REPO}:latest",
  ]
}

target "prod-8_5-local" {
  inherits = ["prod-8_5"]
  output = ["type=docker"]
}

target "prod-8_5-all" {
  inherits = ["prod-8_5"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
