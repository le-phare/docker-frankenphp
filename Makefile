build:
	docker buildx bake --pull

build-all:
	docker run --privileged --rm tonistiigi/binfmt --install all
	docker buildx bake --pull image-all
