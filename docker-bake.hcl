variable "IMAGE_NAME" {
  default = "lephare/frankenphp"
}

variable "DHI_IMAGE_NAME" {
  default = "lephare/dhi-frankenphp"
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

target "_base" {
  inherits = ["docker-metadata-action"]
  args = {
    PHP_EXTENSIONS = "@composer apcu exif gd imagick intl memcached opcache pdo_mysql pdo_pgsql pgsql soap zip"
  }
  target = "base"
}

target "base-8-4" {
  inherits = ["_base"]
  args = {
    PHP_VERSION = "8.4",
  }
}

target "base-8-5" {
  inherits = ["_base"]
  args = {
    PHP_VERSION = "8.5",
  }
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
    base = "target:base-8-4"
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
    base = "target:base-8-5"
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

target "_dhi-builder" {
  inherits = ["docker-metadata-action"]
  args = {
    PHP_EXTENSIONS = "@composer apcu exif gd imagick intl memcached opcache pdo_mysql pdo_pgsql pgsql soap zip"
  }
  dockerfile = "dhi.Dockerfile"
  target = "builder"
}

target "dhi-builder-8-4" {
  inherits = ["_dhi-builder"]
  args = {
    PHP_VERSION = "8.4",
  }
}

target "dhi-builder-8-5" {
  inherits = ["_dhi-builder"]
  args = {
    PHP_VERSION = "8.5",
  }
}

target "dhi-frankenphp-8-4-prod" {
  inherits = ["docker-metadata-action"]
  contexts = {
    builder = "target:dhi-builder-8-4"
  }
  dockerfile = "dhi.Dockerfile"
  tags = [
    "${DHI_IMAGE_NAME}:8.4-prod",
    "${DHI_IMAGE_NAME}:8.4",
  ]
  target = "dhi-prod"
}

target "dhi-frankenphp-8-5-prod" {
  inherits = ["docker-metadata-action"]
  contexts = {
    builder = "target:dhi-builder-8-5"
  }
  dockerfile = "dhi.Dockerfile"
  tags = [
    "${DHI_IMAGE_NAME}:8.5-prod",
    "${DHI_IMAGE_NAME}:8.5",
    "${DHI_IMAGE_NAME}:8-prod",
    "${DHI_IMAGE_NAME}:8",
    "${DHI_IMAGE_NAME}:prod",
    "${DHI_IMAGE_NAME}:latest",
  ]
  target = "dhi-prod"
}
