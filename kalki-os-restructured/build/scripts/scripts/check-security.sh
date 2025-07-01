#!/bin/bash
# check-security.sh: Security best practices check for Kalki OS
set -euo pipefail

fail=0
# Run shellcheck on all scripts
if ! command -v shellcheck &>/dev/null; then
  echo "[WARN] shellcheck not installed. Skipping script linting."
else
  for f in $(find . -type f -name '*.sh'); do
    shellcheck "$f" || fail=1
  done
fi

# Check for missing security patches in custom packages (stub)
echo "[TODO] Check for missing security patches in custom packages."

# Verify package signatures for custom packages (stub)
echo "[TODO] Verify package signatures for custom packages."

if (( fail )); then
  echo "[ERROR] Security check failed. Fix above issues."
  exit 1
else
  echo "[OK] Security check passed."
fi 