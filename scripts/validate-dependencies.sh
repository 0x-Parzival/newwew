#!/bin/bash
# validate-dependencies.sh: Check for all required build dependencies
set -e
REQUIRED_PKGS=(archiso git rsync python-pip paccache base-devel mkinitcpio-archiso)
all_ok=1
for pkg in "${REQUIRED_PKGS[@]}"; do
  if ! pacman -Q $pkg &>/dev/null; then
    echo "❌ Missing package: $pkg"
    all_ok=0
  else
    echo "✅ Found package: $pkg"
  fi
done
if [[ $all_ok -eq 1 ]]; then
  echo "All dependencies are installed."
else
  echo "Some dependencies are missing. Install them with:"
  echo "  sudo pacman -S --needed ${REQUIRED_PKGS[*]}"
  exit 1
fi 