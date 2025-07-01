#!/bin/bash
# Unified Kalki OS Build Script - Updated for New Structure
# Combines all phase features into a single, maintainable build system
#
# This script has been updated to work with the new structured directory layout

set -euo pipefail
trap 'echo "[ERROR] Build failed at line $LINENO"; exit 1' ERR

# Colors for output
GREEN='33[0;32m'
YELLOW='33[1;33m'
RED='33[0;31m'
BLUE='33[0;34m'
NC='33[0m' # No Color

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Configuration
WORK_DIR="$PROJECT_ROOT/workspace/work"
OUT_DIR="$PROJECT_ROOT/dist/iso"
PROFILE_DIR="$PROJECT_ROOT/build/profiles"
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
    echo "Kalki OS Unified Build Script (Restructured Version)"
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --type TYPE          Build type: full, minimal, custom (default: full)"
    echo "  --clean              Clean build directory before starting"
    echo "  --resume             Resume previous build"
    echo "  --no-validate        Skip validation steps"
    echo "  --no-ai              Disable AI components"
    echo "  --no-avatars         Disable avatar system"
    echo "  --no-security        Disable security hardening"
    echo "  --no-dharmic-tools   Disable dharmic applications"
    echo "  --keep-workdir       Keep work directory after build"
    echo "  -v, --verbose        Enable verbose output"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "New Structure Paths:"
    echo "  Project Root: $PROJECT_ROOT"
    echo "  Work Dir:     $WORK_DIR"
    echo "  Output Dir:   $OUT_DIR"
    echo "  Profiles:     $PROFILE_DIR"
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
    local deps=("mkarchiso" "pacman" "git" "rsync" "sha256sum")
    local missing=()
    
    log "Checking build dependencies..."
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing dependencies: ${missing[*]}. Run: bash build/scripts/setup-build-env.sh"
    fi
    
    # Check for AI dependencies if enabled
    if [[ "$ENABLE_AI" == "true" ]]; then
        if ! command -v "ollama" &>/dev/null; then
            warn "Ollama not found. AI features will be limited."
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

# Copy source files to build directory
prepare_sources() {
    log "Preparing source files..."
    
    # Copy core components
    if [ -d "$PROJECT_ROOT/src/core" ]; then
        log "Copying core components..."
        cp -r "$PROJECT_ROOT/src/core"/* "$WORK_DIR/"
    fi
    
    # Copy configurations
    if [ -d "$PROJECT_ROOT/src/configs" ]; then
        log "Copying system configurations..."
        cp -r "$PROJECT_ROOT/src/configs"/* "$WORK_DIR/"
    fi
    
    # Copy AI system if enabled
    if [[ "$ENABLE_AI" == "true" ]] && [ -d "$PROJECT_ROOT/src/ai-system" ]; then
        log "Including AI system components..."
        cp -r "$PROJECT_ROOT/src/ai-system"/* "$WORK_DIR/"
    fi
    
    # Copy avatar system if enabled
    if [[ "$ENABLE_AVATARS" == "true" ]] && [ -d "$PROJECT_ROOT/src/avatar-system" ]; then
        log "Including avatar system..."
        cp -r "$PROJECT_ROOT/src/avatar-system"/* "$WORK_DIR/"
    fi
    
    # Copy dharmic applications if enabled
    if [[ "$ENABLE_DHARMIC_TOOLS" == "true" ]] && [ -d "$PROJECT_ROOT/src/apps" ]; then
        log "Including dharmic applications..."
        cp -r "$PROJECT_ROOT/src/apps"/* "$WORK_DIR/"
    fi
    
    # Copy security components if enabled
    if [[ "$ENABLE_SECURITY" == "true" ]] && [ -d "$PROJECT_ROOT/src/security" ]; then
        log "Including security components..."
        cp -r "$PROJECT_ROOT/src/security"/* "$WORK_DIR/"
    fi
}

# Run validation scripts
run_validations() {
    [[ "$VALIDATE" == "false" ]] && return 0
    
    log "Running validation checks..."
    
    # Phase 5 validations
    if [[ "$ENABLE_AVATARS" == "true" ]]; then
        if [ -f "$PROJECT_ROOT/tools/validation/validate-phase5.sh" ]; then
            log "Running Phase 5 validations..."
            if ! bash "$PROJECT_ROOT/tools/validation/validate-phase5.sh"; then
                error "Phase 5 validation failed"
            fi
        fi
    fi
    
    # Phase 6 validations
    if [[ "$ENABLE_DHARMIC_TOOLS" == "true" ]]; then
        if [ -f "$PROJECT_ROOT/tools/validation/validate-phase6.sh" ]; then
            log "Running Phase 6 validations..."
            if ! bash "$PROJECT_ROOT/tools/validation/validate-phase6.sh"; then
                error "Phase 6 validation failed"
            fi
        fi
    fi
}

# Build the ISO
build_iso() {
    local profile_path
    
    # Determine which profile to use
    case "$BUILD_TYPE" in
        minimal)
            profile_path="$PROFILE_DIR/kalki-base"
            ;;
        full|custom)
            profile_path="$PROFILE_DIR/kalki-os"
            ;;
    esac
    
    if [ ! -d "$profile_path" ]; then
        error "Profile not found: $profile_path"
    fi
    
    local build_cmd=("mkarchiso" "-v" "-w" "$WORK_DIR" "-o" "$OUT_DIR" "$profile_path")
    
    log "Starting build with command: ${build_cmd[*]}"
    
    # Run validations before building
    run_validations
    
    # Prepare source files
    prepare_sources
    
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

# Cleanup function
cleanup() {
    if [[ "$KEEP_WORKDIR" != "true" ]]; then
        log "Cleaning up work directory..."
        sudo rm -rf "$WORK_DIR"
    else
        log "Keeping work directory as requested: $WORK_DIR"
    fi
}

# Main function
main() {
    log "Starting Kalki OS build (Type: $BUILD_TYPE)"
    log "Using restructured project layout"
    log "Project Root: $PROJECT_ROOT"
    
    show_build_summary
    
    check_deps
    prepare_build
    build_iso
    post_build
    
    log "Build process completed successfully!"
    
    # Run post-build tests if enabled
    if [[ "$ENABLE_TESTING" == "true" ]]; then
        log "Running post-build tests..."
        if [ -f "$PROJECT_ROOT/tests/integration/test-kalki-vm.sh" ]; then
            bash "$PROJECT_ROOT/tests/integration/test-kalki-vm.sh"
        fi
    fi
    
    return 0
}

# Handle errors
trap 'error "Build interrupted by user"' INT TERM
trap 'cleanup' EXIT

# Check build dependencies before proceeding
if [ -f "$PROJECT_ROOT/build/scripts/check-dependencies.sh" ]; then
    if ! bash "$PROJECT_ROOT/build/scripts/check-dependencies.sh"; then
        echo "[build-unified] Dependency check failed. Please run setup first."
        exit 1
    fi
    echo "[build-unified] Dependency check passed."
else
    warn "Dependency check script not found!"
fi

# Run main function
main "$@"