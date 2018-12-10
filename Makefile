VERSION := $(shell python -c "import sys; sys.path.insert(0, './searx'); from version import VERSION_STRING; print(VERSION_STRING)")
IMG_NAME := "cyrilix/searx"
DOCKER_CLI_EXPERIMENTAL := enabled

.PHONY: publish
publish: push manifest
	@echo "Publish image"

.PHONY: build
build: generate_dockerfile_arm register-arch
	@echo "Building latest Docker images"
	docker build --file ./Dockerfile.arm --no-cache --tag ${IMG_NAME}:arm-latest .
	docker build --file ./Dockerfile --tag ${IMG_NAME}:amd64-latest .

.PHONY: tag
tag: build
	@echo "Create tags"
	docker tag ${IMG_NAME}:amd64-latest ${IMG_NAME}:amd64-${VERSION}
	docker tag ${IMG_NAME}:arm-latest ${IMG_NAME}:arm-${VERSION}

.PHONY: push
push: tag
	@echo "Push images to Docker"
	docker push ${IMG_NAME}:amd64-latest
	docker push ${IMG_NAME}:amd64-${VERSION}
	docker push ${IMG_NAME}:arm-latest
	docker push ${IMG_NAME}:arm-${VERSION}

.PHONY: manifest
manifest:
	@echo "Create manifest for the version tag"
	DOCKER_CLI_EXPERIMENTAL=enabled docker -D manifest create "${IMG_NAME}:${VERSION}" \
		"${IMG_NAME}:amd64-${VERSION}" \
		"${IMG_NAME}:arm-${VERSION}"
	# Set the architecture to ARM for the ARM image
	DOCKER_CLI_EXPERIMENTAL=enabled docker -D manifest annotate "${IMG_NAME}:${VERSION}" "${IMG_NAME}:arm-${VERSION}" --os=linux --arch=arm --variant=v6
	# Push the manifest
	DOCKER_CLI_EXPERIMENTAL=enabled docker -D manifest push "${IMG_NAME}:${VERSION}"

    # Repeat for the latest tag
	DOCKER_CLI_EXPERIMENTAL=enabled docker -D manifest create "${IMG_NAME}:latest" \
		"${IMG_NAME}:amd64-latest" \
		"${IMG_NAME}:arm-latest"
	DOCKER_CLI_EXPERIMENTAL=enabled docker -D manifest annotate "${IMG_NAME}:latest" "${IMG_NAME}:arm-latest" --os=linux --arch=arm --variant=v6
	DOCKER_CLI_EXPERIMENTAL=enabled docker -D manifest push "${IMG_NAME}:latest"

register-arch:
	@echo "Register architecture"
	#docker run --rm --privileged multiarch/qemu-user-static:register --reset


.PHONY: generate_dockerfile_arm
generate_dockerfile_arm:
	@echo Generate ARM docker file
	cp -f Dockerfile Dockerfile.arm
	sed -i "s#FROM \(.*\)#FROM arm32v6/\1#" Dockerfile.arm


