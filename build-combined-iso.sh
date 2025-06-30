#!/bin/bash
# Combined Kalki OS ISO Builder
# This script combines all phases into a single ISO

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WORK_DIR="./work"
OUT_DIR="./out"
PROFILE="kalki-base"
ISO_NAME="kalki-os-combined"

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}" >&2
}

# Cleanup function
cleanup() {
    log "Cleaning up..."
    sudo rm -rf "$WORK_DIR"
}

# Check dependencies
check_deps() {
    local deps=("mkarchiso" "pacman" "git" "rsync" "sha256sum" "sbsigntool" "e2fsprogs" "cryptsetup")
    local missing=()
    
    log "Checking build dependencies..."
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing dependencies: ${missing[*]}. Please install them first."
    fi
}

# Prepare environment
prepare_environment() {
    log "Preparing build environment..."
    
    # Clean previous builds
    if [ -d "$WORK_DIR" ]; then
        log "Cleaning previous build directory..."
        sudo rm -rf "$WORK_DIR"
    fi
    
    if [ -d "$OUT_DIR" ]; then
        log "Cleaning output directory..."
        sudo rm -rf "$OUT_DIR"
    fi
    
    mkdir -p "$WORK_DIR" "$OUT_DIR"
}

# Combine all phase packages
combine_packages() {
    log "Combining packages from all phases..."
    
    # Create a temporary file for combined packages
    local combined_pkgs="$(mktemp)"
    
    # Base packages
    cat "/home/xero/os/kalki-os/iso-profile/kalki-base/packages.x86_64" > "$combined_pkgs"
    
    # Add AI components
    if [ -f "/home/xero/os/kalki-os/ai-tools/ai-packages.txt" ]; then
        log "Adding AI packages..."
        cat "/home/xero/os/kalki-os/ai-tools/ai-packages.txt" >> "$combined_pkgs"
    fi
    
    # Add Avatar System components
    if [ -f "/home/xero/os/kalki-os/avatar-system/avatar-packages.txt" ]; then
        log "Adding Avatar System packages..."
        cat "/home/xero/os/kalki-os/avatar-system/avatar-packages.txt" >> "$combined_pkgs"
    fi
    
    # Add Dharmic Tools
    if [ -f "/home/xero/os/kalki-os/ai-tools/dharmic-packages.txt" ]; then
        log "Adding Dharmic Tools packages..."
        cat "/home/xero/os/kalki-os/ai-tools/dharmic-packages.txt" >> "$combined_pkgs"
    fi
    
    # Add Security packages
    if [ -f "/home/xero/os/kalki-os/security-layer/security-packages.txt" ]; then
        log "Adding Security packages..."
        cat "/home/xero/os/kalki-os/security-layer/security-packages.txt" >> "$combined_pkgs"
    fi
    
    # Remove duplicates and sort
    sort -u "$combined_pkgs" > "/home/xero/os/kalki-os/iso-profile/kalki-base/packages.x86_64"
    rm -f "$combined_pkgs"
    
    log "Combined $(wc -l /home/xero/os/kalki-os/iso-profile/kalki-base/packages.x86_64 | awk '{print $1}') packages"
}

# Copy custom files and configurations
copy_custom_files() {
    log "Copying custom files and configurations..."
    
    # AI Components
    if [ -d "/home/xero/os/kalki-os/ai-tools/" ]; then
        log "Copying AI components..."
        sudo cp -r "/home/xero/os/kalki-os/ai-tools/" "/home/xero/os/kalki-os/iso-profile/kalki-base/airootfs/opt/"
    fi
    
    # Avatar System
    if [ -d "/home/xero/os/kalki-os/avatar-system/" ]; then
        log "Copying Avatar System..."
        sudo cp -r "/home/xero/os/kalki-os/avatar-system/" "/home/xero/os/kalki-os/iso-profile/kalki-base/airootfs/opt/kalki/"
    fi
    
    # Security Configurations
    if [ -d "/home/xero/os/kalki-os/security-layer/" ]; then
        log "Copying security configurations..."
        sudo cp -r "/home/xero/os/kalki-os/security-layer/etc/" "/home/xero/os/kalki-os/iso-profile/kalki-base/airootfs/"
    fi
    
    # Post-install scripts
    if [ -f "/home/xero/os/kalki-os/ai-post-install.sh" ]; then
        log "Copying post-install scripts..."
        sudo cp "/home/xero/os/kalki-os/ai-post-install.sh" "/home/xero/os/kalki-os/iso-profile/kalki-base/airootfs/root/"
        sudo chmod +x "/home/xero/os/kalki-os/iso-profile/kalki-base/airootfs/root/ai-post-install.sh"
    fi
}

# Build the ISO
build_iso() {
    log "Starting ISO build process..."
    
    # Ensure we're in the right directory
    cd "/home/xero/os/kalki-os"
    
    # Run mkarchiso with all features enabled
    sudo mkarchiso -v \
        -w "$WORK_DIR" \
        -o "$OUT_DIR" \
        -p "base ai avatars security dharmic-tools" \
        "$PROFILE"
    
    # Rename the output ISO
    local iso_file=$(ls -1t "$OUT_DIR/"*.iso 2>/dev/null | head -n 1)
    if [ -n "$iso_file" ]; then
        local new_name="${OUT_DIR}/${ISO_NAME}-$(date +%Y.%m.%d)-x86_64.iso"
        mv "$iso_file" "$new_name"
        
        # Generate checksum
        log "Generating SHA256 checksum..."
        (cd "$OUT_DIR" && sha256sum "$(basename "$new_name")" > "${new_name}.sha256")
        
        log "ISO created successfully: ${new_name}"
    else
        error "Failed to create ISO. Check the build logs in $WORK_DIR"
    fi
}

# Main function
main() {
    echo -e "${BLUE}=== Kalki OS Combined ISO Builder ===${NC}"
    echo -e "This will combine all phases into a single ISO."
    echo -e "${YELLOW}This process requires root privileges.${NC}"
    echo -e "${BLUE}======================================${NC}\n"
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        error "Please run this script as root (use sudo)"
    fi
    
    # Check dependencies
    check_deps
    
    # Prepare environment
    prepare_environment
    
    # Combine packages
    combine_packages
    
    # Copy custom files
    copy_custom_files
    
    # Build the ISO
    build_iso
    
    log "Build process completed successfully!"
    echo -e "\n${GREEN}=== Build Summary ===${NC}"
    echo -e "ISO Location: ${OUT_DIR}/$(ls -1t "${OUT_DIR}"/*.iso 2>/dev/null | head -n 1 | xargs basename 2>/dev/null)"
    echo -e "Checksum:     ${OUT_DIR}/$(ls -1t "${OUT_DIR}"/*.sha256 2>/dev/null | head -n 1 | xargs basename 2>/dev/null)"
    echo -e "${GREEN}====================${NC}\n"
}

# Run main function
main "$@"

exit 0
