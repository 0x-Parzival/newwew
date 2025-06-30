# Kalki OS Build Instructions

## Prerequisites
- See `scripts/check-dependencies.sh` for a full list of required packages and commands.
- Supported OS: Arch Linux (or compatible), Ubuntu 22.04+, Fedora 36+, or use the provided Dockerfile for a reproducible environment.

## Required Environment Variables
- `BUILD_PROFILE`: Which ISO profile to build (e.g., `kalki-base`, `kalki-ultimate`)
- `RELEASE_VERSION`: Version string for release builds
- `REPO_URL`: Custom package repository URL (if used)

## Setting Up a Clean Build Environment
1. Clone the repository:
   ```bash
   git clone https://github.com/0x-Parzival/kalki.git
   cd kalki
   ```
2. Run the dependency check:
   ```bash
   bash scripts/check-dependencies.sh
   ```
3. (Recommended) Use Docker/Podman for a clean, reproducible build:
   ```bash
   docker build -t kalki-os-build .
   docker run --rm -it -v "$PWD:/workspace" kalki-os-build
   ```

## Building Kalki OS
- Main build script:
  ```bash
  sudo bash kalki-os/build-kalki.sh
  ```
- Minimal ISO:
  ```bash
  sudo bash kalki-os/build-minimal-iso.sh
  ```
- Combined ISO:
  ```bash
  sudo bash kalki-os/build-combined-iso.sh
  ```

## Testing and Release
- Run tests:
  ```bash
  bash scripts/test-kalki-vm.sh
  ```
- Release script:
  ```bash
  sudo bash scripts/release-kalki.sh --version <version>
  ```

## Sample Config Files
- See `configs/` for sample configs. Copy and edit as needed:
  - `configs/ai/avatar-personalities.json.sample`
  - `configs/security/audit-config.yaml.sample`

## Known Issues & Troubleshooting
- See `ISSUES.md` and the GitHub issue tracker for up-to-date problems and solutions.
- Common issues:
  - Dependency errors: Run `scripts/suggest-dependencies.sh` to auto-update.
  - Permission errors: Ensure you run build scripts as root.
  - Missing configs: Copy from `.sample` files in `configs/`.

## Community & Support
- GitHub: https://github.com/0x-Parzival/kalki
- Issues: https://github.com/0x-Parzival/kalki/issues
- Discussions: https://github.com/0x-Parzival/kalki/discussions 