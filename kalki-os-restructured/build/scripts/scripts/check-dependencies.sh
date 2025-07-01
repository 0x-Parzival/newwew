#!/bin/bash
# check-dependencies.sh: Kalki OS build dependency checker
#
# IMPORTANT: Update this script whenever you add/remove build dependencies!
#
# Usage: bash scripts/check-dependencies.sh
set -euo pipefail

# List all required packages and/or commands here
# Arch: archiso mkinitcpio-archiso qemu libvirt virt-manager sudo shellcheck reflector plymouth ollama python3 jq zenity
# Debian/Ubuntu: archiso qemu-kvm libvirt-daemon-system virt-manager sudo shellcheck reflector plymouth ollama python3 jq zenity
# Fedora: archiso qemu-kvm libvirt virt-manager sudo ShellCheck reflector plymouth ollama python3 jq zenity
REQUIRED_PKGS=(
  archiso
  mkinitcpio-archiso
  qemu
  libvirt
  virt-manager
  sudo
  shellcheck
  reflector
  plymouth
  ollama
  python
  python3
  jq
  zenity
)
REQUIRED_CMDS=(
  mkarchiso
  rsync
  mksquashfs
  mkfs.fat
  syslinux
  wget
  curl
  zenity
  python3
  docker
  podman
  reflector
  plymouth
  ollama
  jq
  shellcheck
)

missing_pkgs=()
for pkg in "${REQUIRED_PKGS[@]}"; do
  if ! pacman -Q $pkg &>/dev/null; then
    missing_pkgs+=("$pkg")
  fi
done
missing_cmds=()
for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v $cmd &>/dev/null; then
    missing_cmds+=("$cmd")
  fi
done

if (( ${#missing_pkgs[@]} > 0 )) || (( ${#missing_cmds[@]} > 0 )); then
  echo "\n[ERROR] Missing dependencies:"
  for pkg in "${missing_pkgs[@]}"; do
    echo "  - Package: $pkg"
  done
  for cmd in "${missing_cmds[@]}"; do
    echo "  - Command: $cmd"
  done
  echo "\nPlease install the missing dependencies and re-run this script."
  exit 1
else
  echo "All required packages and commands are present."
fi 