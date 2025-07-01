# Kalki OS Makefile
# Provides convenient targets for common development tasks

.PHONY: help setup build build-minimal clean test lint docs install-deps gui

# Default target
help:
	@echo "Kalki OS Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  setup          - Setup build environment"
	@echo "  build          - Build full Kalki OS ISO"
	@echo "  build-minimal  - Build minimal ISO"
	@echo "  clean          - Clean build artifacts"
	@echo "  test           - Run tests"
	@echo "  test-vm        - Test in virtual machine"
	@echo "  lint           - Run code linting"
	@echo "  docs           - Generate documentation"
	@echo "  gui            - Launch GUI build tool"
	@echo "  install-deps   - Install build dependencies"
	@echo "  validate       - Run validation checks"
	@echo ""
	@echo "Docker targets:"
	@echo "  docker-build   - Build in Docker container"
	@echo "  docker-shell   - Launch Docker build shell"

# Setup build environment
setup:
	@echo "Setting up build environment..."
	bash build/scripts/setup-build-env.sh

# Install build dependencies
install-deps:
	@echo "Installing build dependencies..."
	bash build/scripts/check-dependencies.sh

# Build full Kalki OS
build:
	@echo "Building full Kalki OS..."
	bash build/scripts/build-kalki-unified.sh --verbose

# Build minimal ISO
build-minimal:
	@echo "Building minimal Kalki OS..."
	bash build/scripts/build-kalki-unified.sh --type minimal --verbose

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	sudo rm -rf workspace/work/ workspace/temp/ workspace/cache/
	sudo rm -rf dist/iso/*.iso dist/iso/*.sha256
	find . -name "*.log" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

# Run tests
test:
	@echo "Running tests..."
	bash tests/run-basic-tests.sh

# Test in virtual machine
test-vm:
	@echo "Testing in virtual machine..."
	bash build/scripts/test-kalki-vm.sh

# Run linting
lint:
	@echo "Running shellcheck on all scripts..."
	find . -name "*.sh" -exec shellcheck {} +
	@echo "Running Python linting..."
	python3 -m flake8 tools/gui/ src/ --max-line-length=120 || true

# Generate documentation
docs:
	@echo "Generating documentation..."
	# Add documentation generation commands here

# Launch GUI build tool
gui:
	@echo "Launching GUI build tool..."
	python3 tools/gui/kalki-build-gui.py

# Run validation checks
validate:
	@echo "Running validation checks..."
	bash tools/validation/validate-phase5.sh
	bash tools/validation/validate-phase6.sh

# Docker targets
docker-build:
	@echo "Building in Docker container..."
	bash build/ci/run-arch-build-container.sh

docker-shell:
	@echo "Launching Docker build shell..."
	bash build/ci/run-arch-build-container.sh --shell

# Advanced targets
build-custom:
	@echo "Building custom Kalki OS..."
	bash build/scripts/build-kalki-unified.sh --type custom --verbose

build-no-ai:
	@echo "Building without AI components..."
	bash build/scripts/build-kalki-unified.sh --no-ai --verbose

build-security:
	@echo "Building with enhanced security..."
	bash build/scripts/build-kalki-unified.sh --enable-security --verbose

# Development targets
dev-setup:
	@echo "Setting up development environment..."
	bash build/scripts/setup-build-env.sh
	python3 -m pip install -r requirements.txt
	python3 -m pip install -r requirements-all.txt

dev-test:
	@echo "Running development tests..."
	bash tests/unit/run-unit-tests.sh
	bash tests/integration/run-integration-tests.sh

# Release targets
release-check:
	@echo "Running pre-release checks..."
	bash tools/validation/validate-build-env.sh
	bash tools/validation/validate-dependencies.sh
	make lint
	make test

release-build:
	@echo "Building release version..."
	make clean
	bash build/scripts/build-kalki-unified.sh --type full --verbose --no-debug

# Information targets
info:
	@echo "Kalki OS Build Information"
	@echo "========================="
	@echo "Project Structure:"
	@find . -maxdepth 2 -type d | sort
	@echo ""
	@echo "Build Scripts:"
	@find build/scripts/ -name "*.sh" | sort
	@echo ""
	@echo "Available Profiles:"
	@find build/profiles/ -maxdepth 1 -type d | sort

size:
	@echo "Project Size Analysis:"
	@du -h --max-depth=1 . | sort -hr