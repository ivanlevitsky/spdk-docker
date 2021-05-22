SHELL := /usr/bin/env bash

PWD := $(shell pwd)
GIT_COMMIT := $(shell git rev-parse --verify HEAD)

RELEASE_VERSION ?= 0.1
BUILD_NUMBER ?= 0
DEVEL ?= 1

SPDK_VERSION ?= 21.04
FIO_VERSION ?= 3.26
LIBURING_VERSION ?= 2.0

ARCH ?= native
BUILDER_ARCH ?= $(shell uname -m)

IMAGE_NAME := $(shell basename $(PWD))
DOCKER_NAME ?= $(shell id -u -n)
DOCKER_REGISTRY ?= https://docker.pkg.github.com
DOCKER_TAG ?= $(IMAGE_NAME)-$(SPDK_VERSION)-$(BUILDER_ARCH)

export RELEASE_VERSION BUILD_NUMBER GIT_COMMIT

all: build

build:
	@echo "Version: $(RELEASE_VERSION)-$(BUILD_NUMBER)"
	@echo "SPDK version: $(SPDK_VERSION)"
	@echo "FIO version: $(FIO_VERSION)"
	@echo "IO-uring version: $(LIBURING_VERSION)"
	@echo "Build commit: $(GIT_COMMIT)"
	@echo "Builder arch: $(BUILDER_ARCH)"
	@echo "Arch: $(ARCH)"
	@echo "Docker tag: $(DOCKER_TAG)"
	docker image build \
		--tag  "$(DOCKER_TAG)" \
		--file spdk.dockerfile \
		--build-arg IMAGE_NAME="$(IMAGE_NAME)" \
		--build-arg DOCKER_NAME="$(DOCKER_NAME)" \
		--build-arg DOCKER_REGISTRY="$(DOCKER_REGISTRY)" \
		--build-arg ARCH="$(ARCH)" \
		--build-arg FIO_VERSION="$(FIO_VERSION)" \
		--build-arg LIBURING_VERSION="$(LIBURING_VERSION)" \
		--build-arg SPDK_VERSION="$(SPDK_VERSION)" \
		.

test:
	docker container run --rm \
		--name spdk-docker \
		--privileged \
		--net host \
		--volume /dev/hugepages:/dev/hugepages \
		--volume /dev/shm:/dev/shm \
		"$(DOCKER_TAG)" /app/spdk/test/unit/unittest.sh

run: 
	docker container run -it --rm \
		--name spdk-docker \
		--privileged \
		--net host \
		--volume /dev/hugepages:/dev/hugepages \
		--volume /dev/shm:/dev/shm \
		"$(DOCKER_TAG)" /app/spdk/build/bin/spdk_tgt

clean:
	docker container stop "$(DOCKER_TAG)" || true
	docker container rm "$(DOCKER_TAG)" || true
	docker image rmi "$(DOCKER_TAG)" || true

help:
	@echo "Usage:"
	@echo
	@echo "make [options] [arguments] [targets]"
	@echo
	@echo
	@echo "Targets:"
	@echo
	@echo "all		Build SPDK docker image"
	@echo "build		Build SPDK docker image"
	@echo "test		Run unit tests SPDK in docker container"
	@echo "run		Run SPDK in docker container"
	@echo "clean		Remove generated files"
	@echo "help		Display help message and exit"
	@echo
	@echo
	@echo "Arguments:"
	@echo
	@echo "SPDK_VERSION	SPDK release version number. Matches tags in SPDK git. Example: SPDK_VERSION=21.04"
	@echo "ARCH		Build architecture. Must be a valid GNU arch. Default: native"

.EXPORT_ALL_VARIABLES:
.PHONY: all build test run clean help
