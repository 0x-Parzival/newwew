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

# Robust path resolution (symlink-safe)
resolve_path() {
    if command -v realpath >/dev/null 2>&1; then
        realpath "$1"
    elif command -v readlink >/dev/null 2>&1; then
        readlink -f "$1"
    else
        # Portable fallback: works in all POSIX shells
        dir=$(dirname -- "$1")
        base=$(basename -- "$1")
        echo "$(cd "$dir" 2>/dev/null && pwd)/$base"
    fi
}
echo "[DEBUG] Running shell: $SHELL"
SCRIPT_PATH="$(resolve_path "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

# Dependency check at the start
if [ -f "$SCRIPT_DIR/../scripts/check-dependencies.sh" ]; then
  bash "$SCRIPT_DIR/../scripts/check-dependencies.sh" || exit 1
  echo "[build-combined-iso.sh] Dependency check passed."
else
  echo "[build-combined-iso.sh] Dependency check script not found!"
  exit 1
fi

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
    cat "$SCRIPT_DIR/../iso-profile/kalki-base/packages.x86_64" > "$combined_pkgs"
    
    # Add AI components
    if [ -f "$SCRIPT_DIR/../ai-tools/ai-packages.txt" ]; then
        log "Adding AI packages..."
        cat "$SCRIPT_DIR/../ai-tools/ai-packages.txt" >> "$combined_pkgs"
    fi
    
    # Add Avatar System components
    if [ -f "$SCRIPT_DIR/../avatar-system/avatar-packages.txt" ]; then
        log "Adding Avatar System packages..."
        cat "$SCRIPT_DIR/../avatar-system/avatar-packages.txt" >> "$combined_pkgs"
    fi
    
    # Add Dharmic Tools
    if [ -f "$SCRIPT_DIR/../ai-tools/dharmic-packages.txt" ]; then
        log "Adding Dharmic Tools packages..."
        cat "$SCRIPT_DIR/../ai-tools/dharmic-packages.txt" >> "$combined_pkgs"
    fi
    
    # Add Security packages
    if [ -f "$SCRIPT_DIR/../security-layer/security-packages.txt" ]; then
        log "Adding Security packages..."
        cat "$SCRIPT_DIR/../security-layer/security-packages.txt" >> "$combined_pkgs"
    fi
    
    # Remove duplicates and sort
    sort -u "$combined_pkgs" > "$SCRIPT_DIR/../iso-profile/kalki-base/packages.x86_64"
    rm -f "$combined_pkgs"
    
    log "Combined $(wc -l $SCRIPT_DIR/../iso-profile/kalki-base/packages.x86_64 | awk '{print $1}') packages"
}

# Copy custom files and configurations
copy_custom_files() {
    log "Copying custom files and configurations..."
    
    # AI Components
    if [ -d "$SCRIPT_DIR/../ai-tools/" ]; then
        log "Copying AI components..."
        sudo cp -r "$SCRIPT_DIR/../ai-tools/" "$SCRIPT_DIR/../iso-profile/kalki-base/airootfs/opt/"
    fi
    
    # Avatar System
    if [ -d "$SCRIPT_DIR/../avatar-system/" ]; then
        log "Copying Avatar System..."
        sudo cp -r "$SCRIPT_DIR/../avatar-system/" "$SCRIPT_DIR/../iso-profile/kalki-base/airootfs/opt/kalki/"
    fi
    
    # Security Configurations
    if [ -d "$SCRIPT_DIR/../security-layer/" ]; then
        log "Copying security configurations..."
        sudo cp -r "$SCRIPT_DIR/../security-layer/etc/" "$SCRIPT_DIR/../iso-profile/kalki-base/airootfs/"
    fi
    
    # Post-install scripts
    if [ -f "$SCRIPT_DIR/../ai-post-install.sh" ]; then
        log "Copying post-install scripts..."
        sudo cp "$SCRIPT_DIR/../ai-post-install.sh" "$SCRIPT_DIR/../iso-profile/kalki-base/airootfs/root/"
        sudo chmod +x "$SCRIPT_DIR/../iso-profile/kalki-base/airootfs/root/ai-post-install.sh"
    fi
}

# Build the ISO
build_iso() {
    log "Starting ISO build process..."
    
    # Ensure we're in the right directory
    cd "$SCRIPT_DIR/.."
    
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

    # Hardware compatibility check
    if [ -f "$SCRIPT_DIR/../scripts/check-hardware.sh" ]; then
        bash "$SCRIPT_DIR/../scripts/check-hardware.sh" || exit 1
        echo "[build-combined-iso.sh] Hardware compatibility check passed."
    else
        echo "[build-combined-iso.sh] Hardware check script not found!"
        exit 1
    fi

    # Security best practices check
    if [ -f "$SCRIPT_DIR/../scripts/check-security.sh" ]; then
        bash "$SCRIPT_DIR/../scripts/check-security.sh" || exit 1
        echo "[build-combined-iso.sh] Security check passed."
    else
        echo "[build-combined-iso.sh] Security check script not found!"
        exit 1
    fi

    # Performance metrics logging
    if [ -f "$SCRIPT_DIR/../scripts/report-build-metrics.sh" ]; then
        source "$SCRIPT_DIR/../scripts/report-build-metrics.sh"
    else
        echo "[build-combined-iso.sh] Performance metrics script not found!"
    fi

    if declare -f report_build_metrics_end &>/dev/null; then
        report_build_metrics_end
    fi
}

# Run main function
main "$@"

exit 0
