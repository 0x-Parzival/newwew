#!/usr/bin/env bash
# Unified Kalki OS Ultimate Build Script
# Builds a single ISO with all phases combined

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROFILE="kalki-ultimate"
WORK_DIR="./work"
OUT_DIR="./out"

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

# Prepare overlays
prepare_overlays() {
    log "Preparing phase overlays..."
    
    # Create overlay directories
    local overlay_dir="iso-profile/${PROFILE}/overlay.d"
    
    # 01-ai: AI components (Phase 2-4)
    if [ -d "ai-tools" ]; then
        log "  - Adding AI tools..."
        mkdir -p "${overlay_dir}/01-ai/opt/kalki/ai-tools"
        cp -r ai-tools/* "${overlay_dir}/01-ai/opt/kalki/ai-tools/"
    fi
    
    # 02-ui: UI components (Phase 3-4)
    if [ -d "hyprland" ]; then
        log "  - Adding Hyprland configuration..."
        mkdir -p "${overlay_dir}/02-ui/etc/skel/.config/hypr"
        cp -r hypr/* "${overlay_dir}/02-ui/etc/skel/.config/hypr/"
    fi
    
    # 03-avatars: Avatar system (Phase 5)
    if [ -d "avatar-system" ]; then
        log "  - Adding Avatar system..."
        mkdir -p "${overlay_dir}/03-avatars/opt/kalki/avatars"
        cp -r avatar-system/* "${overlay_dir}/03-avatars/opt/kalki/avatars/"
    fi
    
    # 04-apps: Dharmic applications (Phase 6)
    if [ -d "apps" ]; then
        log "  - Adding Dharmic applications..."
        mkdir -p "${overlay_dir}/04-apps/opt/kalki/apps"
        cp -r apps/* "${overlay_dir}/04-apps/opt/kalki/apps/"
    fi
    
    # 05-security: Security layer (Phase 7)
    if [ -d "security-layer" ]; then
        log "  - Adding security configurations..."
        mkdir -p "${overlay_dir}/05-security/etc"
        cp -r security-layer/etc/* "${overlay_dir}/05-security/etc/"
    fi
    
    # 06-bench: Benchmarking tools (Phase 8)
    if [ -d "benchmarking" ]; then
        log "  - Adding benchmarking tools..."
        mkdir -p "${overlay_dir}/06-bench/opt/kalki/bench"
        cp -r benchmarking/* "${overlay_dir}/06-bench/opt/kalki/bench/"
    fi
}

# Flatten overlays into final airootfs
flatten_overlays() {
    log "Flattening overlays into final airootfs..."
    
    local airootfs="iso-profile/${PROFILE}/airootfs"
    local overlay_dir="iso-profile/${PROFILE}/overlay.d"
    
    # Create airootfs if it doesn't exist
    mkdir -p "$airootfs"
    
    # Process overlays in order
    for dir in $(ls -1v "$overlay_dir"); do
        local src="${overlay_dir}/${dir}"
        if [ -d "$src" ]; then
            log "  - Applying overlay: $dir"
            sudo rsync -aH "${src}/" "$airootfs/"
        fi
    done
}

# Update profiledef.sh
update_profiledef() {
    log "Updating profiledef.sh..."
    
    local profiledef="iso-profile/${PROFILE}/profiledef.sh"
    
    cat > "$profiledef" << 'EOF'
# vim:set ft=sh
# MODIFICATION START
iso_name="kalki"
iso_label="KALKI_ULTIMATE_$(date +%Y%m)"
iso_publisher="Krix Collective"
iso_application="Kalki OS – Ultimate Dharmic Edition"
install_dir="kalki"
arch="x86_64"
bootmodes=(
  'bios.syslinux.mbr'
  'bios.syslinux.eltorito'
  'uefi-x64.systemd-boot.esp'
  'uefi-x64.systemd-boot.eltorito'
)
airootfs_image_type="squashfs"
airootfs_image_tool_options=(-comp zstd -Xcompression-level 19)
# MODIFICATION END
EOF
    
    log "  - Updated ${profiledef}"
}

# Build the ISO
build_iso() {
    log "Starting ISO build process..."
    
    # Clean previous builds
    sudo rm -rf "$WORK_DIR" "$OUT_DIR"
    
    # Run mkarchiso
    log "Running mkarchiso..."
    sudo mkarchiso -v \
        -w "$WORK_DIR" \
        -o "$OUT_DIR" \
        "iso-profile/${PROFILE}"
    
    # Rename the output ISO
    local iso_file=$(ls -1t "$OUT_DIR/"*.iso 2>/dev/null | head -n 1)
    if [ -n "$iso_file" ]; then
        local version=$(date +%Y.%m.%d)
        local new_name="${OUT_DIR}/kalki-ultimate-${version}-x86_64.iso"
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
    echo -e "${BLUE}=== Kalki OS Ultimate ISO Builder ===${NC}"
    echo -e "This will build a single ISO with all phases combined."
    echo -e "${YELLOW}This process requires root privileges.${NC}"
    echo -e "${BLUE}======================================${NC}\n"
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        error "Please run this script as root (use sudo)"
    fi
    
    # Check dependencies
    check_deps
    
    # Prepare overlays
    prepare_overlays
    
    # Flatten overlays into airootfs
    flatten_overlays
    
    # Update profiledef.sh
    update_profiledef
    
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
