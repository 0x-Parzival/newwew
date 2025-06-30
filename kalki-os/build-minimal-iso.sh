#!/bin/bash
# Minimal build script for Kalki OS with reduced disk usage
#
# Requirements:
#   - Run as a regular user (not root)
#   - Dependencies: archiso, mkinitcpio-archiso, qemu, libvirt, virt-manager, sudo, shellcheck, etc.
#   - At least 8GB free disk space (25GB recommended for full build)
#   - Virtualization extensions enabled for VM testing
#
# Usage:
#   ./build-minimal-iso.sh [--skip-validations] [--verbose]
#
# Flags:
#   --skip-validations   Skip hardware/security/metrics checks (warn only)
#   --verbose            Enable verbose output

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse flags
SKIP_VALIDATIONS=false
VERBOSE=false
for arg in "$@"; do
  case $arg in
    --skip-validations) SKIP_VALIDATIONS=true ;;
    --verbose) VERBOSE=true ;;
  esac
done

# Robust path resolution (symlink-safe)
resolve_path() {
    # Usage: resolve_path <path>
    # Outputs the absolute path of the given file or directory
    local target="$1"
    if command -v realpath >/dev/null 2>&1; then
        realpath "$target"
    elif command -v grealpath >/dev/null 2>&1; then
        grealpath "$target"
    else
        # Fallback: use Python for cross-platform compatibility
        python3 -c "import os,sys; print(os.path.abspath(sys.argv[1]))" "$target"
    fi
}
SCRIPT_PATH="$(resolve_path "$0")"
PROJECT_ROOT="$(dirname "$SCRIPT_PATH")"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

# Dependency check at the start
if [ -f "$SCRIPTS_DIR/check-dependencies.sh" ]; then
  bash "$SCRIPTS_DIR/check-dependencies.sh" || exit 1
  echo "[build-minimal-iso.sh] Dependency check passed."
else
  echo "[build-minimal-iso.sh] Dependency check script not found!"
  exit 1
fi

# Log function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
    if [ "$VERBOSE" = true ]; then
      echo -e "${YELLOW}[VERBOSE]${NC} $1"
    fi
}

# Error function
error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

# Warn function
warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}" >&2
}

# Cleanup function
cleanup() {
    log "Cleaning up..."
    sudo rm -rf "$WORK_DIR"
}

# Check disk space
check_disk_space() {
    local required_space=8000 # 8GB in MB
    local available_space
    if df -m . >/dev/null 2>&1; then
        # Linux/GNU
        available_space=$(df -m . | awk 'NR==2 {print $4}')
    else
        # macOS/BSD
        available_space=$(df -k . | awk 'NR==2 {print int($4/1024)}')
    fi
    if [ -z "$available_space" ] || [ "$available_space" -lt "$required_space" ]; then
        error "Not enough disk space. Need at least 8GB free, but only ${available_space:-0}MB available."
    fi
    log "Available disk space: ${available_space}MB"
}

# Fix mkinitcpio configuration
fix_mkinitcpio() {
    log "Fixing mkinitcpio configuration..."
    local mkinitcpio_conf="$PROFILE/airootfs/etc/mkinitcpio.conf"
    if [ -f "$mkinitcpio_conf" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sudo sed -i '' 's/^COMPRESSION=.*/COMPRESSION="gzip"/' "$mkinitcpio_conf"
            sudo sed -i '' 's/^COMPRESSION_OPTIONS=.*/COMPRESSION_OPTIONS=("-9")/' "$mkinitcpio_conf"
        else
            sudo sed -i 's/^COMPRESSION=.*/COMPRESSION="gzip"/' "$mkinitcpio_conf"
            sudo sed -i 's/^COMPRESSION_OPTIONS=.*/COMPRESSION_OPTIONS=("-9")/' "$mkinitcpio_conf"
        fi
    fi
    local preset_file="$PROFILE/airootfs/etc/mkinitcpio.d/linux.preset"
    if [ -f "$preset_file" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sudo sed -i '' 's/^COMPRESSION=.*/COMPRESSION="gzip"/' "$preset_file"
            sudo sed -i '' 's/^COMPRESSION_OPTIONS=.*/COMPRESSION_OPTIONS=("-9")/' "$preset_file"
        else
            sudo sed -i 's/^COMPRESSION=.*/COMPRESSION="gzip"/' "$preset_file"
            sudo sed -i 's/^COMPRESSION_OPTIONS=.*/COMPRESSION_OPTIONS=("-9")/' "$preset_file"
        fi
    fi
}

# Build the ISO
build_iso() {
    log "Starting ISO build in $WORK_DIR..."
    mkdir -p "$WORK_DIR" "$OUT_DIR"
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
    if [ "$(id -u)" -eq 0 ]; then
        error "This script should not be run as root. Please run as a regular user."
    fi
    check_disk_space
    trap cleanup EXIT
    fix_mkinitcpio
    # Hardware compatibility check
    if [ -f "$SCRIPTS_DIR/check-hardware.sh" ]; then
        if ! bash "$SCRIPTS_DIR/check-hardware.sh"; then
            if [ "$SKIP_VALIDATIONS" = true ]; then
                warn "Hardware compatibility check failed, but continuing due to --skip-validations."
            else
                error "Hardware compatibility check failed. Use --skip-validations to override."
            fi
        else
            log "Hardware compatibility check passed."
        fi
    else
        if [ "$SKIP_VALIDATIONS" = true ]; then
            warn "Hardware check script not found, skipping due to --skip-validations."
        else
            error "Hardware check script not found! Use --skip-validations to override."
        fi
    fi
    # Security best practices check
    if [ -f "$SCRIPTS_DIR/check-security.sh" ]; then
        if ! bash "$SCRIPTS_DIR/check-security.sh"; then
            if [ "$SKIP_VALIDATIONS" = true ]; then
                warn "Security check failed, but continuing due to --skip-validations."
            else
                error "Security check failed. Use --skip-validations to override."
            fi
        else
            log "Security check passed."
        fi
    else
        if [ "$SKIP_VALIDATIONS" = true ]; then
            warn "Security check script not found, skipping due to --skip-validations."
        else
            error "Security check script not found! Use --skip-validations to override."
        fi
    fi
    # Performance metrics logging
    if [ -f "$SCRIPTS_DIR/report-build-metrics.sh" ]; then
        source "$SCRIPTS_DIR/report-build-metrics.sh"
    else
        if [ "$SKIP_VALIDATIONS" = true ]; then
            warn "Performance metrics script not found, skipping due to --skip-validations."
        else
            error "Performance metrics script not found! Use --skip-validations to override."
        fi
    fi
    build_iso
    log "Build process completed successfully!"
    if declare -f report_build_metrics_end &>/dev/null; then
        report_build_metrics_end
    fi
}

# Configuration
WORK_DIR="/tmp/kalki-build-$(date +%s)"
OUT_DIR="$(pwd)/out"
PROFILE="iso-profile/kalki-base"

# Run the script
main "$@"
