#!/bin/bash
# Kalki OS Structure Validation Script
# Validates the restructured project layout

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Counters
PASSED=0
FAILED=0
WARNINGS=0

log() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((PASSED++))
}

warn() {
    echo -e "${YELLOW}[⚠]${NC} $1"
    ((WARNINGS++))
}

error() {
    echo -e "${RED}[✗]${NC} $1"
    ((FAILED++))
}

show_banner() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════╗"
    echo "║       Kalki OS Structure Validation          ║"
    echo "║      Verifying Restructured Layout           ║"
    echo "╚═══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_directory_structure() {
    echo -e "\n${BLUE}Checking Directory Structure...${NC}"
    
    # Main directories
    local main_dirs=("src" "build" "dist" "docs" "tests" "tools" "workspace")
    for dir in "${main_dirs[@]}"; do
        if [ -d "$PROJECT_ROOT/$dir" ]; then
            log "Main directory exists: $dir/"
        else
            error "Missing main directory: $dir/"
        fi
    done
    
    # Source subdirectories
    local src_dirs=("core" "apps" "ai-system" "avatar-system" "security" "configs")
    for dir in "${src_dirs[@]}"; do
        if [ -d "$PROJECT_ROOT/src/$dir" ]; then
            log "Source directory exists: src/$dir/"
        else
            error "Missing source directory: src/$dir/"
        fi
    done
    
    # Build subdirectories
    local build_dirs=("scripts" "profiles" "tools" "ci")
    for dir in "${build_dirs[@]}"; do
        if [ -d "$PROJECT_ROOT/build/$dir" ]; then
            log "Build directory exists: build/$dir/"
        else
            error "Missing build directory: build/$dir/"
        fi
    done
}

check_essential_files() {
    echo -e "\n${BLUE}Checking Essential Files...${NC}"
    
    # Root files
    local root_files=("README.md" "CONTRIBUTING.md" "Makefile" ".gitignore" "setup.sh")
    for file in "${root_files[@]}"; do
        if [ -f "$PROJECT_ROOT/$file" ]; then
            log "Root file exists: $file"
        else
            error "Missing root file: $file"
        fi
    done
    
    # Requirements files
    local req_files=("requirements.txt" "requirements-all.txt" "requirements-seal.txt")
    for file in "${req_files[@]}"; do
        if [ -f "$PROJECT_ROOT/$file" ]; then
            log "Requirements file exists: $file"
        else
            warn "Missing requirements file: $file"
        fi
    done
}

check_build_scripts() {
    echo -e "\n${BLUE}Checking Build Scripts...${NC}"
    
    local build_scripts=(
        "build/scripts/build-kalki-unified.sh"
        "build/scripts/setup-build-env.sh"
    )
    
    for script in "${build_scripts[@]}"; do
        if [ -f "$PROJECT_ROOT/$script" ]; then
            if [ -x "$PROJECT_ROOT/$script" ]; then
                log "Build script exists and is executable: $script"
            else
                warn "Build script exists but not executable: $script"
                chmod +x "$PROJECT_ROOT/$script"
                log "Fixed permissions for: $script"
            fi
        else
            error "Missing build script: $script"
        fi
    done
}

check_gui_tools() {
    echo -e "\n${BLUE}Checking GUI Tools...${NC}"
    
    if [ -f "$PROJECT_ROOT/tools/gui/kalki-build-gui.py" ]; then
        log "GUI build tool exists: tools/gui/kalki-build-gui.py"
        
        # Check if it's a valid Python file
        if python3 -m py_compile "$PROJECT_ROOT/tools/gui/kalki-build-gui.py" 2>/dev/null; then
            log "GUI tool is valid Python code"
        else
            warn "GUI tool has Python syntax issues"
        fi
    else
        error "Missing GUI build tool: tools/gui/kalki-build-gui.py"
    fi
}

check_documentation() {
    echo -e "\n${BLUE}Checking Documentation...${NC}"
    
    local doc_files=(
        "docs/README.md"
        "docs/ARCHITECTURE.md"
    )
    
    for doc in "${doc_files[@]}"; do
        if [ -f "$PROJECT_ROOT/$doc" ]; then
            log "Documentation exists: $doc"
        else
            warn "Missing documentation: $doc"
        fi
    done
    
    # Check if docs have content
    if [ -f "$PROJECT_ROOT/docs/README.md" ]; then
        if [ -s "$PROJECT_ROOT/docs/README.md" ]; then
            log "README has content"
        else
            warn "README is empty"
        fi
    fi
}

check_source_content() {
    echo -e "\n${BLUE}Checking Source Content...${NC}"
    
    # Check if source directories have content
    local content_dirs=("src/apps" "src/configs" "src/core")
    for dir in "${content_dirs[@]}"; do
        if [ -d "$PROJECT_ROOT/$dir" ] && [ "$(ls -A "$PROJECT_ROOT/$dir" 2>/dev/null)" ]; then
            log "Source directory has content: $dir/"
        else
            warn "Source directory is empty: $dir/"
        fi
    done
}

check_workspace_setup() {
    echo -e "\n${BLUE}Checking Workspace Setup...${NC}"
    
    local workspace_dirs=("workspace/work" "workspace/temp" "workspace/cache")
    for dir in "${workspace_dirs[@]}"; do
        if [ -d "$PROJECT_ROOT/$dir" ]; then
            log "Workspace directory exists: $dir/"
        else
            warn "Workspace directory missing: $dir/ (will be created on demand)"
        fi
    done
    
    # Check permissions
    if [ -w "$PROJECT_ROOT/workspace" ]; then
        log "Workspace is writable"
    else
        error "Workspace is not writable"
    fi
}

check_makefile_targets() {
    echo -e "\n${BLUE}Checking Makefile Targets...${NC}"
    
    if [ -f "$PROJECT_ROOT/Makefile" ]; then
        local targets=("help" "setup" "build" "clean" "test" "gui")
        for target in "${targets[@]}"; do
            if grep -q "^$target:" "$PROJECT_ROOT/Makefile"; then
                log "Makefile target exists: $target"
            else
                warn "Missing Makefile target: $target"
            fi
        done
    fi
}

show_summary() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════${NC}"
    echo -e "${BLUE}             VALIDATION SUMMARY${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════${NC}"
    
    echo -e "\n📊 Results:"
    echo -e "  ${GREEN}✓ Passed:   $PASSED${NC}"
    echo -e "  ${YELLOW}⚠ Warnings: $WARNINGS${NC}"
    echo -e "  ${RED}✗ Failed:   $FAILED${NC}"
    
    if [ "$FAILED" -eq 0 ]; then
        echo -e "\n${GREEN}🎉 Structure validation PASSED!${NC}"
        echo -e "${GREEN}The project is properly restructured and ready for use.${NC}"
    elif [ "$FAILED" -lt 5 ]; then
        echo -e "\n${YELLOW}⚠️  Structure validation completed with minor issues.${NC}"
        echo -e "${YELLOW}The project should still be functional.${NC}"
    else
        echo -e "\n${RED}❌ Structure validation FAILED!${NC}"
        echo -e "${RED}Please fix the issues before proceeding.${NC}"
    fi
    
    if [ "$WARNINGS" -gt 0 ]; then
        echo -e "\n💡 Consider addressing the warnings for optimal functionality."
    fi
}

show_next_steps() {
    if [ "$FAILED" -eq 0 ]; then
        echo -e "\n${GREEN}🚀 Ready to proceed!${NC}"
        echo ""
        echo "Next steps:"
        echo "  1. Run setup: ./setup.sh"
        echo "  2. Build project: make build"
        echo "  3. Launch GUI: make gui"
        echo ""
        echo "For help: make help"
    fi
}

main() {
    show_banner
    
    echo "Validating project structure at: $PROJECT_ROOT"
    
    check_directory_structure
    check_essential_files
    check_build_scripts
    check_gui_tools
    check_documentation
    check_source_content
    check_workspace_setup
    check_makefile_targets
    
    show_summary
    show_next_steps
    
    # Exit with appropriate code
    if [ "$FAILED" -gt 5 ]; then
        exit 1
    else
        exit 0
    fi
}

# Run main function
main "$@"