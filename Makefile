# Variables
IMAGE_NAME := custom-netshoot
IMAGE_TAG  := local
IMAGE      := $(IMAGE_NAME):$(IMAGE_TAG)

# Declare phony targets (actions, not files on disk)
.PHONY: help build test run clean

# Default action when running just `make`
all: help

help: ## Display this help message
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build the container image locally
	podman build -t $(IMAGE) .

test: build ## Run automated verification tests inside a disposable container
	@echo "==> 1. Verifying navi installation..."
	@podman run --rm $(IMAGE) navi --version
	@echo "==> 2. Verifying networking binaries..."
	@podman run --rm $(IMAGE) sh -c \
		"which ping nc curl dig traceroute mtr tcpdump iperf3 ss ip ethtool openssl fzf zsh"
	@echo "==> 3. Verifying cheatsheet syntax parsing..."
	@podman run --rm $(IMAGE) sh -c \
		"navi --query 'check host' --best-match > /dev/null"
	@echo "==> All automated tests passed successfully."

run: build ## Run interactive troubleshooting container with full network capabilities
	podman run --rm -it \
		--net=host \
		--cap-add=NET_ADMIN \
		--cap-add=NET_RAW \
		$(IMAGE)

clean: ## Remove local container image
	podman rmi -f $(IMAGE) 2>/dev/null || true
