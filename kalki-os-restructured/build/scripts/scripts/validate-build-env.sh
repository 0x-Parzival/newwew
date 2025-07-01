#!/bin/bash
# validate-build-env.sh: Pre-build environment validation for Kalki OS
set -euo pipefail

REQUIRED_VARS=(BUILD_PROFILE RELEASE_VERSION)
REQUIRED_CONFIGS=(
  configs/ai/avatar-personalities.json
  configs/security/audit-config.yaml
)
SUPPORTED_OS=("Arch" "Ubuntu" "Fedora")

missing_vars=()
for var in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    missing_vars+=("$var")
  fi
done
if (( ${#missing_vars[@]} > 0 )); then
  echo "[ERROR] Missing required environment variables: ${missing_vars[*]}" >&2
  exit 1
fi

missing_configs=()
for cfg in "${REQUIRED_CONFIGS[@]}"; do
  if [[ ! -f "$cfg" ]]; then
    missing_configs+=("$cfg")
  fi
done
if (( ${#missing_configs[@]} > 0 )); then
  echo "[ERROR] Missing required config files: ${missing_configs[*]}" >&2
  exit 1
fi

os_name=$(awk -F= '/^NAME=/{print $2}' /etc/os-release | tr -d '"')
if [[ ! " ${SUPPORTED_OS[*]} " =~ " $os_name " ]]; then
  echo "[WARNING] OS '$os_name' is not officially supported. Proceed with caution."
fi

if ! (command -v docker &>/dev/null || command -v podman &>/dev/null); then
  echo "[INFO] Consider using Docker or Podman for a reproducible build environment."
fi

echo "[OK] Build environment validated."
echo "  OS: $os_name"
echo "  Required variables: ${REQUIRED_VARS[*]}"
echo "  Required configs: ${REQUIRED_CONFIGS[*]}" 