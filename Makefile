## If make reports an error mentioning multiple target patterns,
## you need to ensure the Makefile is formatted with tabs not spaces.

.PHONY: help

APP_NAME ?= $(shell grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g')
APP_VSN ?= $(shell grep 'version:' mix.exs | cut -d '"' -f2)
BUILD ?= $(shell git rev-parse --short HEAD)

help:
		@echo "$(APP_NAME):$(APP_VSN)-$(BUILD)"
		@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
		docker build --build-arg APP_NAME=$(APP_NAME) \
				--build-arg APP_VSN=$(APP_VSN) \
				-t $(APP_NAME):$(APP_VSN)-$(BUILD) \
				-t $(APP_NAME):latest .

push:
		docker tag `docker images -f reference='$(APP_NAME):latest' -q` registry.cn-hangzhou.aliyuncs.com/jet/$(APP_NAME):$(APP_VSN)
		docker tag `docker images -f reference='$(APP_NAME):latest' -q` registry.cn-hangzhou.aliyuncs.com/jet/$(APP_NAME):latest
		docker push registry.cn-hangzhou.aliyuncs.com/jet/$(APP_NAME):$(APP_VSN)
		docker push registry.cn-hangzhou.aliyuncs.com/jet/$(APP_NAME):latest
