build:
	docker buildx bake --pull --set '*.platform=linux/amd64' 'frankenphp-*'

build-arm:
	docker run --privileged --rm tonistiigi/binfmt --install all
	docker buildx bake --pull --set '*.platform=linux/arm64' 'frankenphp-*'

build-dhi:
	docker buildx bake --pull --set '*.platform=linux/amd64' 'dhi-frankenphp-*'

build-arm-dhi:
	docker run --privileged --rm tonistiigi/binfmt --install all
	docker buildx bake --pull --set '*.platform=linux/arm64' 'dhi-frankenphp-*'
