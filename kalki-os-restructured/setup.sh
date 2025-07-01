#!/bin/bash
# Kalki OS Quick Setup Script
# Sets up the development environment for the restructured project

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
    echo -e "${GREEN}[SETUP]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

show_banner() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════╗"
    echo "║           Kalki OS Quick Setup                ║"
    echo "║        Restructured Project Layout            ║"
    echo "╚═══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_system() {
    log "Checking system requirements..."
    
    # Check if running on Arch Linux
    if [ -f /etc/arch-release ]; then
        log "Arch Linux detected - optimal environment"
    else
        warn "Not running on Arch Linux - consider using Docker container"
    fi
    
    # Check for basic tools
    local tools=("git" "bash" "python3" "make")
    for tool in "${tools[@]}"; do
        if command -v "$tool" &>/dev/null; then
            log "Found: $tool"
        else
            error "Missing required tool: $tool"
        fi
    done
}

setup_directories() {
    log "Ensuring all directories exist..."
    
    # Create any missing directories
    mkdir -p "$PROJECT_ROOT"/{workspace/{work,temp,cache},dist/{iso,packages,keys}}
    
    # Set proper permissions
    chmod 755 "$PROJECT_ROOT"/build/scripts/*.sh 2>/dev/null || true
    chmod 755 "$PROJECT_ROOT"/tools/*/*.sh 2>/dev/null || true
    chmod 755 "$PROJECT_ROOT"/setup.sh
    
    log "Directory structure verified"
}

install_dependencies() {
    log "Setting up build dependencies..."
    
    if [ -f "$PROJECT_ROOT/build/scripts/setup-build-env.sh" ]; then
        bash "$PROJECT_ROOT/build/scripts/setup-build-env.sh"
    else
        warn "setup-build-env.sh not found, skipping dependency installation"
    fi
}

setup_python_env() {
    log "Setting up Python environment..."
    
    if [ -f "$PROJECT_ROOT/requirements.txt" ]; then
        if command -v pip3 &>/dev/null; then
            pip3 install -r "$PROJECT_ROOT/requirements.txt" --user
            log "Python dependencies installed"
        else
            warn "pip3 not found, skipping Python setup"
        fi
    fi
}

run_validation() {
    log "Running initial validation..."
    
    # Check build scripts
    if [ -f "$PROJECT_ROOT/build/scripts/check-dependencies.sh" ]; then
        if bash "$PROJECT_ROOT/build/scripts/check-dependencies.sh"; then
            log "Dependency check passed"
        else
            warn "Some dependencies may be missing"
        fi
    fi
    
    # Test GUI tool
    if [ -f "$PROJECT_ROOT/tools/gui/kalki-build-gui.py" ]; then
        if python3 -c "import tkinter"; then
            log "GUI build tool should work"
        else
            warn "GUI may not work - tkinter not available"
        fi
    fi
}

show_next_steps() {
    echo -e "\n${GREEN}✅ Setup Complete!${NC}\n"
    echo "Next steps:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "🚀 Quick Start Options:"
    echo ""
    echo "  1. GUI Build (Recommended):"
    echo "     python3 tools/gui/kalki-build-gui.py"
    echo ""
    echo "  2. Command Line Build:"
    echo "     make build                    # Full build"
    echo "     make build-minimal           # Minimal build"
    echo ""
    echo "  3. Docker Build (Cross-platform):"
    echo "     make docker-build"
    echo ""
    echo "📖 Documentation:"
    echo "  - README:       docs/README.md"
    echo "  - Architecture: docs/ARCHITECTURE.md"
    echo "  - Contributing: CONTRIBUTING.md"
    echo ""
    echo "🛠️  Development:"
    echo "  - Makefile targets: make help"
    echo "  - Build scripts:    build/scripts/"
    echo "  - Validation:       make validate"
    echo ""
    echo "🏗️  Project Structure:"
    echo "  - Source:       src/"
    echo "  - Build:        build/"
    echo "  - Tools:        tools/"
    echo "  - Tests:        tests/"
    echo "  - Workspace:    workspace/"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

main() {
    show_banner
    
    log "Starting Kalki OS setup..."
    log "Project root: $PROJECT_ROOT"
    
    check_system
    setup_directories
    install_dependencies
    setup_python_env
    run_validation
    
    show_next_steps
}

# Run main function
main "$@"