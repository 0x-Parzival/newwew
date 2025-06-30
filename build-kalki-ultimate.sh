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

# Required directories for overlays
REQUIRED_DIRS=(
  "ai-tools"
  "hyprland"
  "avatar-system"
  "apps"
  "security-layer"
  "benchmarking"
  "iso-profile/${PROFILE}"
)

# Required files in profile
REQUIRED_PROFILE_FILES=(
  "iso-profile/${PROFILE}/packages.x86_64"
)

# Feature flags (default: all enabled)
ENABLE_AI=true
ENABLE_AVATARS=true
ENABLE_SECURITY=true
ENABLE_DHARMIC_TOOLS=true
ENABLE_TESTING=false
VALIDATE=true
CLEAN=false
RESUME=false
VERBOSE=false
KEEP_WORKDIR=false
BUILD_TYPE="full"

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

# Automated dependency installation
install_deps() {
    local deps=("mkarchiso" "pacman" "git" "rsync" "sha256sum" "sbsigntool" "e2fsprogs" "cryptsetup")
    local missing=()
    log "Checking and installing build dependencies..."
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        log "Installing missing dependencies: ${missing[*]}"
        sudo pacman -Sy --noconfirm --needed "${missing[@]}"
    fi
}

# Validate required directories and files
validate_structure() {
    local all_ok=1
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [[ ! -d "$dir" ]]; then
            warn "Required directory missing: $dir. Creating it (empty)."
            mkdir -p "$dir"
            all_ok=0
        fi
    done
    for file in "${REQUIRED_PROFILE_FILES[@]}"; do
        if [[ ! -f "$file" ]]; then
            warn "Required file missing: $file. Creating empty placeholder."
            touch "$file"
            all_ok=0
        fi
    done
    if [[ $all_ok -eq 0 ]]; then
        warn "Some required directories/files were missing and have been created as empty placeholders. Please populate them as needed."
    fi
}

# Cleanup function
cleanup() {
    log "Cleaning up..."
    sudo rm -rf "$WORK_DIR"
}

# Check dependencies (now handled by install_deps)
check_deps() { :; }

# Show help function
show_help() {
    echo "Kalki OS Ultimate Build Script"
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --type TYPE          Build type: full, minimal, custom (default: full)"
    echo "  --clean              Clean build directory before starting"
    echo "  --resume             Resume previous build"
    echo "  --no-validate        Skip validation steps"
    echo "  --no-ai              Disable AI components"
    echo "  --no-avatars         Disable avatar system"
    echo "  --no-security        Disable security hardening"
    echo "  --no-dharmic-tools   Disable dharmic tools/apps"
    echo "  --enable-testing     Run post-build tests"
    echo "  --keep-workdir       Keep work directory after build"
    echo "  -v, --verbose        Enable verbose output"
    echo "  -h, --help           Show this help message"
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --resume)
            RESUME=true
            shift
            ;;
        --no-validate)
            VALIDATE=false
            shift
            ;;
        --no-ai)
            ENABLE_AI=false
            shift
            ;;
        --no-avatars)
            ENABLE_AVATARS=false
            shift
            ;;
        --no-security)
            ENABLE_SECURITY=false
            shift
            ;;
        --no-dharmic-tools)
            ENABLE_DHARMIC_TOOLS=false
            shift
            ;;
        --enable-testing)
            ENABLE_TESTING=true
            shift
            ;;
        --keep-workdir)
            KEEP_WORKDIR=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            error "Unknown option: $1"
            ;;
    esac
done

# Print build summary
show_build_summary() {
    echo -e "\n${GREEN}=== Build Summary ===${NC}"
    echo -e "Build Type:       $BUILD_TYPE"
    echo -e "AI Integration:   $([[ $ENABLE_AI == "true" ]] && echo "Enabled" || echo "Disabled")"
    echo -e "Avatar System:    $([[ $ENABLE_AVATARS == "true" ]] && echo "Enabled" || echo "Disabled")"
    echo -e "Security:         $([[ $ENABLE_SECURITY == "true" ]] && echo "Enabled" || echo "Disabled")"
    echo -e "Dharmic Tools:    $([[ $ENABLE_DHARMIC_TOOLS == "true" ]] && echo "Enabled" || echo "Disabled")"
    echo -e "Validation:       $([[ $VALIDATE == "true" ]] && echo "Enabled" || echo "Disabled")"
    echo -e "Work Directory:   $WORK_DIR"
    echo -e "Output Directory: $OUT_DIR"
    echo -e "${GREEN}====================${NC}\n"
}

# Prepare overlays
prepare_overlays() {
    log "Preparing phase overlays..."
    local overlay_dir="iso-profile/${PROFILE}/overlay.d"
    # 01-ai: AI components
    if [[ "$ENABLE_AI" == "true" && -d "ai-tools" ]]; then
        log "  - Adding AI tools..."
        mkdir -p "${overlay_dir}/01-ai/opt/kalki/ai-tools"
        cp -r ai-tools/* "${overlay_dir}/01-ai/opt/kalki/ai-tools/"
    fi
    # 02-ui: UI components
    if [ -d "hyprland" ]; then
        log "  - Adding Hyprland configuration..."
        mkdir -p "${overlay_dir}/02-ui/etc/skel/.config/hypr"
        cp -r hypr/* "${overlay_dir}/02-ui/etc/skel/.config/hypr/"
    fi
    # 03-avatars: Avatar system
    if [[ "$ENABLE_AVATARS" == "true" && -d "avatar-system" ]]; then
        log "  - Adding Avatar system..."
        mkdir -p "${overlay_dir}/03-avatars/opt/kalki/avatars"
        cp -r avatar-system/* "${overlay_dir}/03-avatars/opt/kalki/avatars/"
    fi
    # 04-apps: Dharmic applications
    if [[ "$ENABLE_DHARMIC_TOOLS" == "true" && -d "apps" ]]; then
        log "  - Adding Dharmic applications..."
        mkdir -p "${overlay_dir}/04-apps/opt/kalki/apps"
        cp -r apps/* "${overlay_dir}/04-apps/opt/kalki/apps/"
    fi
    # 05-security: Security layer
    if [[ "$ENABLE_SECURITY" == "true" && -d "security-layer" ]]; then
        log "  - Adding security configurations..."
        mkdir -p "${overlay_dir}/05-security/etc"
        cp -r security-layer/etc/* "${overlay_dir}/05-security/etc/"
    fi
    # 06-bench: Benchmarking tools
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
    
    # Automated dependency installation
    install_deps
    
    # Validate required structure
    validate_structure
    
    # Prepare overlays
    prepare_overlays
    
    # Flatten overlays into airootfs
    flatten_overlays
    
    # Update profiledef.sh
    update_profiledef
    
    # Build the ISO
    build_iso
    
    log "Build process completed successfully!"
    show_build_summary
}

# Run main function
main "$@"

exit 0
