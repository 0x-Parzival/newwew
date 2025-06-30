#!/bin/bash
# check-python-dependencies.sh: Check and install all Python dependencies for Kalki OS
# Usage: bash scripts/check-python-dependencies.sh
set -euo pipefail

REQ_FILE="$(dirname "$0")/../requirements-all.txt"
if [ ! -f "$REQ_FILE" ]; then
  echo "[ERROR] requirements-all.txt not found!" >&2
  exit 1
fi

MISSING=()
while read -r pkg; do
  [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue
  pkg_name=$(echo "$pkg" | cut -d'=' -f1 | cut -d'[' -f1)
  if ! python3 -c "import $pkg_name" &>/dev/null; then
    MISSING+=("$pkg")
  fi
done < "$REQ_FILE"

if [ ${#MISSING[@]} -eq 0 ]; then
  echo "All Python dependencies are installed."
  exit 0
fi

echo "Missing Python packages:"
for pkg in "${MISSING[@]}"; do
  echo "  - $pkg"
done

echo "\nInstall all with:"
echo "  pip install -r $REQ_FILE"
read -p "Install now? [y/N] " -n 1 -r; echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  pip install -r "$REQ_FILE"
fi 