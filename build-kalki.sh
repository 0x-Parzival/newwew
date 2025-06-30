#!/bin/bash
# Unified Kalki OS Build Script
# Combines all phase features into a single, maintainable build system
#
# Phases included:
# - Phase 4: AI Assistant Core
# - Phase 5: Avatar System
# - Phase 6: Dharmic Tools
# - Phase 7: Security & Privacy
# - Phase 8-10: Testing & Release

set -euo pipefail
trap 'echo "[ERROR] Build failed at line $LINENO"; exit 1' ERR

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
BUILD_TYPE="full"  # full, minimal, custom

# Feature flags - can be overridden via command line
ENABLE_AI=true
ENABLE_AVATARS=true
ENABLE_SECURITY=true
ENABLE_DHARMIC_TOOLS=true
ENABLE_TESTING=false

# Build options
VALIDATE=true
CLEAN=false
RESUME=false
VERBOSE=false
KEEP_WORKDIR=false

# Paths
BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPTS_DIR="${BASE_DIR}/scripts"
VALIDATION_DIR="${BASE_DIR}"
PHASE_DIRS=("${BASE_DIR}/phase7" "${BASE_DIR}/phase8" "${BASE_DIR}/phase9-docs" "${BASE_DIR}/phase10-release")

# Logging functions
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
    [[ "$VERBOSE" == "true" ]] && echo -e "${BLUE}[DEBUG]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}[WARNING] $1${NC}" >&2
}

# Display help
show_help() {
    echo "Kalki OS Unified Build Script"
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --type TYPE          Build type: full, minimal, custom (default: full)"
    echo "  --clean              Clean build directory before starting"
    echo "  --resume             Resume previous build"
    echo "  --no-validate        Skip validation steps"
    echo "  --no-ai              Disable AI components"
    echo "  --no-avatars         Disable avatar system"
    echo "  --no-security        Disable security hardening"
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

# Validate build type
case "$BUILD_TYPE" in
    full|minimal|custom)
        ;;
    *)
        error "Invalid build type: $BUILD_TYPE. Must be one of: full, minimal, custom"
        ;;
esac

# Check dependencies
check_deps() {
    local deps=("mkarchiso" "pacman" "git" "rsync" "sha256sum" "sbsigntool" "e2fsprogs" "cryptsetup" "apparmor-utils")
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
    
    # Check for AI dependencies if enabled
    if [[ "$ENABLE_AI" == "true" ]]; then
        if ! command -v "ollama" &>/dev/null; then
            warn "Ollama not found. AI features will be limited."
        fi
    fi
    
    # Check for avatar system dependencies
    if [[ "$ENABLE_AVATARS" == "true" ]]; then
        if ! command -v "python3" &>/dev/null; then
            warn "Python 3 not found. Avatar system features may be limited."
        fi
        if ! command -v "jq" &>/dev/null; then
            warn "jq not found. Some configuration validation may fail."
        fi
    fi
}

# Cleanup function
cleanup() {
    if [[ "$KEEP_WORKDIR" != "true" ]]; then
        log "Cleaning up work directory..."
        sudo rm -rf "$WORK_DIR"
    else
        log "Keeping work directory as requested: $WORK_DIR"
    fi
}

# Validate build environment
validate_environment() {
    [[ "$VALIDATE" == "false" ]] && return 0
    
    log "Validating build environment..."
    
    # Check for sufficient disk space (at least 15GB free)
    local free_space
    free_space=$(df -BG . | awk 'NR==2 {print $4}' | tr -d 'G')
    if [[ $free_space -lt 25 ]]; then  # Increased minimum space for all phases
        error "Insufficient disk space. Need at least 25GB free, found ${free_space}G"
    fi
    
    # Check for required kernel modules
    local modules=("loop" "squashfs" "overlay" "dm-crypt" "dm-verity" "apparmor")
    for mod in "${modules[@]}"; do
        if ! lsmod | grep -q "^$mod"; then
            if ! sudo modprobe "$mod"; then
                warn "Failed to load kernel module: $mod"
            fi
        fi
    done
    
    # Check for secure boot support
    if [[ "$ENABLE_SECURITY" == "true" ]]; then
        if ! [ -d "/sys/firmware/efi/efivars" ]; then
            warn "EFI variables not found. Secure boot support may be limited."
        fi
    fi
}

# Prepare build directory
prepare_build() {
    if [[ "$CLEAN" == "true" ]]; then
        log "Cleaning previous build..."
        sudo rm -rf "$WORK_DIR" "$OUT_DIR"
    elif [[ "$RESUME" != "true" && -d "$WORK_DIR" ]]; then
        error "Work directory exists. Use --clean to remove it or --resume to continue."
    fi
    
    mkdir -p "$WORK_DIR" "$OUT_DIR"
}

# Run validation scripts
run_validations() {
    [[ "$VALIDATE" == "false" ]] && return 0
    
    log "Running validation checks..."
    
    # Phase 5 validations
    if [[ "$ENABLE_AVATARS" == "true" ]]; then
        if [ -f "${VALIDATION_DIR}/validate-phase5.sh" ]; then
            log "Running Phase 5 validations..."
            if ! "${VALIDATION_DIR}/validate-phase5.sh"; then
                error "Phase 5 validation failed"
            fi
        fi
    fi
    
    # Phase 6 validations
    if [[ "$ENABLE_DHARMIC_TOOLS" == "true" ]]; then
        if [ -f "${VALIDATION_DIR}/validate-phase6.sh" ]; then
            log "Running Phase 6 validations..."
            if ! "${VALIDATION_DIR}/validate-phase6.sh"; then
                error "Phase 6 validation failed"
            fi
        fi
    fi
    
    # AI Integration validation
    if [[ "$ENABLE_AI" == "true" ]]; then
        if [ -f "${VALIDATION_DIR}/validate-ai-integration.sh" ]; then
            log "Validating AI integration..."
            if ! "${VALIDATION_DIR}/validate-ai-integration.sh"; then
                error "AI integration validation failed"
            fi
        fi
    fi
}

# Apply security hardening
apply_security_hardening() {
    [[ "$ENABLE_SECURITY" != "true" ]] && return 0
    
    log "Applying security hardening..."
    
    # Enable AppArmor
    if ! systemctl is-active --quiet apparmor; then
        log "Enabling AppArmor..."
        systemctl enable --now apparmor
    fi
    
    # Set secure kernel parameters
    log "Configuring secure kernel parameters..."
    cat > /etc/sysctl.d/99-kalki-security.conf << EOF
# Kernel hardening
kernel.kptr_restrict=2
kernel.dmesg_restrict=1
kernel.kexec_load_disabled=1
kernel.sysrq=0
kernel.unprivileged_bpf_disabled=1
net.core.bpf_jit_harden=2

# Network security
net.ipv4.conf.all.rp_filter=1
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0
net.ipv4.conf.all.secure_redirects=0
net.ipv4.conf.default.secure_redirects=0
net.ipv4.conf.all.log_martians=1
net.ipv4.conf.default.log_martians=1
net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.icmp_ignore_bogus_error_responses=1
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_rfc1337=1
net.ipv6.conf.all.accept_redirects=0
net.ipv6.conf.default.accept_redirects=0
net.ipv6.conf.all.accept_ra=0
net.ipv6.conf.default.accept_ra=0
EOF
    
    # Apply sysctl settings
    sysctl --system
}

# Build the ISO
build_iso() {
    local build_cmd=("mkarchiso" "-v")
    
    [[ "$VERBOSE" == "true" ]] && build_cmd+=("-v")
    
    build_cmd+=(
        "-w" "$WORK_DIR"
        "-o" "$OUT_DIR"
    )
    
    # Add profile-specific options
    case "$BUILD_TYPE" in
        minimal)
            build_cmd+=("-p" "base")
            ;;
        custom)
            [[ "$ENABLE_AI" == "true" ]] && build_cmd+=("-p" "ai")
            [[ "$ENABLE_AVATARS" == "true" ]] && build_cmd+=("-p" "avatars")
            [[ "$ENABLE_SECURITY" == "true" ]] && build_cmd+=("-p" "security")
            [[ "$ENABLE_DHARMIC_TOOLS" == "true" ]] && build_cmd+=("-p" "dharmic-tools")
            ;;
    esac
    
    # Add secure boot support if enabled
    if [[ "$ENABLE_SECURITY" == "true" ]]; then
        build_cmd+=("--sign")
    fi
    
    build_cmd+=("$PROFILE")
    
    log "Starting build with command: ${build_cmd[*]}"
    
    # Run validations before building
    run_validations
    
    # Apply security hardening
    apply_security_hardening
    
    # Execute the build
    if ! "${build_cmd[@]}"; then
        error "Build failed. Check the logs in $WORK_DIR/build.log"
    fi
}

# Post-build processing
post_build() {
    local iso_file
    iso_file=$(find "$OUT_DIR" -name 'kalki-*.iso' | head -n 1)
    
    if [[ -z "$iso_file" ]]; then
        error "No ISO file found in $OUT_DIR"
    fi
    
    # Generate checksum
    log "Generating SHA256 checksum..."
    (cd "$(dirname "$iso_file")" && \
     sha256sum "$(basename "$iso_file")" > "$(basename "$iso_file").sha256")
    
    # Display build info
    local size
    size=$(du -h "$iso_file" | cut -f1)
    
    echo -e "\n${GREEN}✅ Build completed successfully!${NC}"
    echo -e "📦 ISO: $iso_file"
    echo -e "📏 Size: $size"
    echo -e "🔑 SHA256: $(cat "$iso_file.sha256")"
    
    # Clean up if requested
    [[ "$KEEP_WORKDIR" != "true" ]] && cleanup
    
    return 0
}

# Display build summary
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

# Main function
main() {
    log "Starting Kalki OS build (Type: $BUILD_TYPE)"
    log "Build features: AI=$ENABLE_AI, Avatars=$ENABLE_AVATARS, Security=$ENABLE_SECURITY, Dharmic Tools=$ENABLE_DHARMIC_TOOLS"
    
    show_build_summary
    
    check_deps
    validate_environment
    prepare_build
    build_iso
    post_build
    
    log "Build process completed successfully!"
    
    # Run post-build tests if enabled
    if [[ "$ENABLE_TESTING" == "true" ]]; then
        log "Running post-build tests..."
        if [ -f "${BASE_DIR}/test-kalki-vm.sh" ]; then
            "${BASE_DIR}/test-kalki-vm.sh"
        fi
    fi
    
    return 0
}

# Handle errors
trap 'error "Build interrupted by user"' INT TERM
trap 'cleanup' EXIT

# Check build dependencies before proceeding
if [ -f "$SCRIPTS_DIR/check-dependencies.sh" ]; then
  if ! bash "$SCRIPTS_DIR/check-dependencies.sh"; then
    echo "[build-kalki.sh] Dependency check failed. Attempting to auto-update dependencies..."
    if [ -f "$SCRIPTS_DIR/suggest-dependencies.sh" ]; then
      bash "$SCRIPTS_DIR/suggest-dependencies.sh"
      echo "[build-kalki.sh] Dependencies updated. Please review and re-run the build."
      exit 1
    else
      echo "[build-kalki.sh] suggest-dependencies.sh not found!"
      exit 1
    fi
  fi
  echo "[build-kalki.sh] Dependency check passed."
else
  echo "[build-kalki.sh] Dependency check script not found!"
  exit 1
fi

# Run main function
main "$@"
