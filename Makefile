build:
	docker buildx bake --pull

build-8.4:
	docker buildx bake --pull dev-8_4-local prod-8_4-local

build-8.5:
	docker buildx bake --pull dev-8_5-local prod-8_5-local

build-all:
	docker run --privileged --rm tonistiigi/binfmt --install all
	docker buildx bake --pull image-all
