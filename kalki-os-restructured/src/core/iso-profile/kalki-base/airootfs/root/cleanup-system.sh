#!/bin/bash
# Post-installation cleanup script for Kalki OS

set -euo pipefail

# Remove orphaned packages
pacman -Rns $(pacman -Qtdq) 2>/dev/null || true

# Clean package cache
paccache -rk 1

# Remove old configuration files
find /etc -name '*.pacnew' -o -name '*.pacsave' -delete

# Clean temporary files
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /var/cache/pacman/pkg/*

echo "System cleanup completed!"
