#!/bin/bash
set -e

# Update package database
echo "Updating package database..."
sudo pacman -Syu --noconfirm

# Install required build dependencies
echo "Installing build dependencies..."
sudo pacman -S --needed --noconfirm \
    archiso \
    git \
    wget \
    rsync \
    arch-install-scripts \
    mkinitcpio-archiso \
    archiso

# Verify required tools are installed
for cmd in mkarchiso pacstrap arch-chroot; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd not found!"
        exit 1
    fi
done

echo "Pre-build setup completed successfully!"
