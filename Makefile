SHELL := /bin/bash

BASE_IMAGE_VERSION = 11.1.1-cudnn8-devel-ubuntu18.04

IMAGE_NAME := minhocomcomai/tensorflow-pytorch-cuda
IMAGE_VERSION := tf2.4.1-pytorch1.8.1-cuda$(BASE_IMAGE_VERSION)


BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VCS_REF := $(shell git rev-parse --short HEAD)
VERSION := $(IMAGE_VERSION)
VCS_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
VCS_DESCRIBED := $(shell git describe --tags --dirty)
HOSTNAME := $(shell hostname)


all: base customized

base:
	docker build \
		-f Dockerfile.base \
		--build-arg IMAGE_NAME="$(IMAGE_NAME)" \
		--build-arg BASE_IMAGE_VERSION="$(BASE_IMAGE_VERSION)" \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg VCS_REF="$(VCS_REF)" \
		--build-arg VERSION="$(VERSION)" \
		--build-arg VCS_BRANCH="$(VCS_BRANCH)" \
		--build-arg VCS_DESCRIBED="$(VCS_DESCRIBED)" \
		--build-arg HOSTNAME="$(HOSTNAME)" \
		-t $(IMAGE_NAME):$(VERSION) .
	docker push $(IMAGE_NAME):$(VERSION)

customized: customized-vscode customized-jupyterlab

customized-vscode: base
	docker build \
		-f Dockerfile.customized \
		--target vscode \
		--build-arg IMAGE_NAME="$(IMAGE_NAME)" \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg VCS_REF="$(VCS_REF)" \
		--build-arg VERSION="$(VERSION)" \
		--build-arg VCS_BRANCH="$(VCS_BRANCH)" \
		--build-arg VCS_DESCRIBED="$(VCS_DESCRIBED)" \
		--build-arg HOSTNAME="$(HOSTNAME)" \
		-t $(IMAGE_NAME):customized-vscode-$(VERSION) .
	docker push $(IMAGE_NAME):customized-vscode-$(VERSION)

customized-jupyterlab: base
	docker build \
		-f Dockerfile.customized \
		--target jupyterlab \
		--build-arg IMAGE_NAME="$(IMAGE_NAME)" \
		--build-arg BUILD_DATE="$(BUILD_DATE)" \
		--build-arg VCS_REF="$(VCS_REF)" \
		--build-arg VERSION="$(VERSION)" \
		--build-arg VCS_BRANCH="$(VCS_BRANCH)" \
		--build-arg VCS_DESCRIBED="$(VCS_DESCRIBED)" \
		--build-arg HOSTNAME="$(HOSTNAME)" \
		-t $(IMAGE_NAME):customized-jupyterlab-$(VERSION) .
	docker push $(IMAGE_NAME):customized-jupyterlab-$(VERSION)
