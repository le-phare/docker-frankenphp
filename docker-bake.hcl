variable "IMAGE_NAME" {
  default = "lephare/frankenphp"
}

variable "PHP_LATEST_VERSION" {
  default = "8.5"
}

// Special target: https://github.com/docker/metadata-action#bake-definition
target "docker-metadata-action" {
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}

target "base" {
  inherits = ["docker-metadata-action"]
  args = {
    PHP_EXTENSIONS = "@composer apcu exif gd imagick intl memcached opcache pdo_mysql pdo_pgsql pgsql soap zip"
  }
  target = "base"
}

target "frankenphp-8-4" {
  inherits = ["docker-metadata-action"]
  name = "frankenphp-8-4-${tgt}"
  matrix = {
    tgt = ["dev", "prod"]
  }
  args = {
    PHP_EXTENSIONS = tgt == "dev" ? "xdebug" : null,
  }
  contexts = {
    base = "target:base"
  }
  tags = [
    "${IMAGE_NAME}:8.4-${tgt}",
      tgt == "prod" ? "${IMAGE_NAME}:8.4" : "",
  ]
  target = tgt
}

target "frankenphp-8-5" {
  inherits = ["docker-metadata-action"]
  name = "frankenphp-8-5-${tgt}"
  matrix = {
    tgt = ["dev", "prod"]
  }
  args = {
    PHP_EXTENSIONS = tgt == "dev" ? "xdebug" : null,
  }
  contexts = {
    base = "target:base"
  }
  tags = [
    "${IMAGE_NAME}:8.5-${tgt}",
      tgt == "prod" ? "${IMAGE_NAME}:8.5" : "",
    "${IMAGE_NAME}:8-${tgt}",
      tgt == "prod" ? "${IMAGE_NAME}:8" : "",
    "${IMAGE_NAME}:${tgt}",
      tgt == "prod" ? "${IMAGE_NAME}:latest" : "",
  ]
  target = tgt
}
