#!/bin/bash
# Minimal build script for Kalki OS with reduced disk usage

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
WORK_DIR="/tmp/kalki-build-$(date +%s)"
OUT_DIR="$(pwd)/out"
PROFILE="iso-profile/kalki-base"

# Log function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Error function
error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

# Cleanup function
cleanup() {
    log "Cleaning up..."
    sudo rm -rf "$WORK_DIR"
}

# Check disk space
check_disk_space() {
    local required_space=8000 # 8GB in MB
    local available_space=$(df -m --output=avail / | tail -n 1)
    
    if [ "$available_space" -lt "$required_space" ]; then
        error "Not enough disk space. Need at least 8GB free, but only ${available_space}MB available."
    fi
    
    log "Available disk space: ${available_space}MB"
}

# Fix mkinitcpio configuration
fix_mkinitcpio() {
    log "Fixing mkinitcpio configuration..."
    
    # Use simpler compression
    local mkinitcpio_conf="$PROFILE/airootfs/etc/mkinitcpio.conf"
    if [ -f "$mkinitcpio_conf" ]; then
        sudo sed -i 's/^COMPRESSION=.*/COMPRESSION="gzip"/' "$mkinitcpio_conf"
        sudo sed -i 's/^COMPRESSION_OPTIONS=.*/COMPRESSION_OPTIONS=("-9")/' "$mkinitcpio_conf"
    fi
    
    # Fix preset file
    local preset_file="$PROFILE/airootfs/etc/mkinitcpio.d/linux.preset"
    if [ -f "$preset_file" ]; then
        sudo sed -i 's/^COMPRESSION=.*/COMPRESSION="gzip"/' "$preset_file"
        sudo sed -i 's/^COMPRESSION_OPTIONS=.*/COMPRESSION_OPTIONS=("-9")/' "$preset_file"
    fi
}

# Build the ISO
build_iso() {
    log "Starting ISO build in $WORK_DIR..."
    
    # Create work and out directories
    mkdir -p "$WORK_DIR" "$OUT_DIR"
    
    # Build with minimal settings
    if ! sudo mkarchiso -v \
        -w "$WORK_DIR" \
        -o "$OUT_DIR" \
        -D "Kalki OS" \
        -A "Kalki OS Live/Rescue CD" \
        -p "base base-devel" \
        -C "pacman.conf" \
        -L "KALKI_$(date +%Y%m%d)" \
        -P "kalki" \
        -c "zstd -Xcompression-level 9 -T0" \
        -m "iso" \
        "$PROFILE"; then
        error "Failed to build ISO"
    fi
    
    log "ISO build completed successfully!"
    log "ISO location: $(ls -lh "$OUT_DIR"/*.iso)"
}

# Main function
main() {
    log "Starting minimal Kalki OS build process"
    
    # Check if running as root
    if [ "$(id -u)" -eq 0 ]; then
        error "This script should not be run as root. Please run as a regular user."
    fi
    
    # Check disk space
    check_disk_space
    
    # Set up trap for cleanup
    trap cleanup EXIT
    
    # Fix mkinitcpio configuration
    fix_mkinitcpio
    
    # Build the ISO
    build_iso
    
    log "Build process completed successfully!"
}

# Run the script
main "$@"
