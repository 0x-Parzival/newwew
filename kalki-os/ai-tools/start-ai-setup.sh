#!/bin/bash

# Dharma OS - AI Setup Assistant
# Interactive setup script for AI components

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
AI_USER="kalki"
AI_HOME="/home/${AI_USER}"
LOG_FILE="/var/log/krix-ai/setup-$(date +%Y%m%d-%H%M%S).log"

# Ensure we're running as the correct user
if [ "$(whoami)" != "${AI_USER}" ]; then
    echo -e "${RED}Error: This script must be run as user '${AI_USER}'${NC}" >&2
    exit 1
fi

# Create log directory
mkdir -p "$(dirname "${LOG_FILE}")"

# Log function
log() {
    echo -e "$1" | tee -a "${LOG_FILE}" > /dev/tty
}

# Header
clear
log "${GREEN}========================================"
log "  Dharma OS - AI Setup Assistant"
log "========================================${NC}"

# Check for internet connection
check_internet() {
    log "Checking internet connection..."
    if ! ping -c 1 archlinux.org &> /dev/null; then
        log "${RED}Error: No internet connection detected.${NC}"
        log "Please connect to the internet and try again."
        exit 1
    fi
    log "${GREEN}✓ Internet connection detected.${NC}"
}

# Check disk space
check_disk_space() {
    local required_gb=20  # Minimum 20GB free space recommended
    local available_gb=$(df -BG "${AI_HOME}" | awk 'NR==2 {gsub(/[^0-9]/,"",$4); print $4}')
    
    if [ "${available_gb}" -lt "${required_gb}" ]; then
        log "${YELLOW}Warning: Low disk space. At least ${required_gb}GB is recommended.${NC}"
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "Setup cancelled by user."
            exit 0
        fi
    fi
}

# Install AI components
install_ai_components() {
    log "\n${GREEN}Installing AI components...${NC}"
    
    # Run the installation script with sudo
    log "You may be prompted for your password to install system components."
    if ! sudo -v; then
        log "${RED}Error: Failed to get sudo privileges.${NC}"
        exit 1
    fi
    
    # Run the installation
    log "Starting AI component installation (this may take a while)..."
    if ! sudo "${AI_HOME}/ai-tools/install-ai-foundation.sh" 2>&1 | tee -a "${LOG_FILE}"; then
        log "${RED}Error: Failed to install AI components.${NC}"
        log "Check the log file at: ${LOG_FILE}"
        exit 1
    fi
    
    log "${GREEN}✓ AI components installed successfully!${NC}"
}

# Download AI models
download_ai_models() {
    log "\n${GREEN}AI Model Download${NC}"
    log "This will download AI models which may require significant disk space."
    log "Recommended free space: At least 20GB"
    
    # Show disk usage
    log "\nCurrent disk usage in ${AI_HOME}/ai-models:"
    du -sh "${AI_HOME}/ai-models"
    
    read -p "Do you want to download AI models now? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Skipping model download. You can run this later with: ~/download-ai-models.sh"
        return 0
    fi
    
    log "\nStarting model download (this may take a while, depending on your internet speed)..."
    if ! "${AI_HOME}/download-ai-models.sh" 2>&1 | tee -a "${LOG_FILE}"; then
        log "${YELLOW}Warning: There were issues downloading some models.${NC}"
        log "You can try running the download again later with: ~/download-ai-models.sh"
    else
        log "${GREEN}✓ AI models downloaded successfully!${NC}"
    fi
}

# Configure user environment
configure_environment() {
    log "\n${GREEN}Configuring user environment...${NC}"
    
    # Add AI tools to PATH
    if ! grep -q "ai-tools" "${AI_HOME}/.bashrc"; then
        echo -e "\n# Add AI tools to PATH" >> "${AI_HOME}/.bashrc"
        echo 'export PATH="$HOME/ai-tools:$PATH"' >> "${AI_HOME}/.bashrc"
    fi
    
    # Add Python virtual environment activation
    if ! grep -q "ai-venv" "${AI_HOME}/.bashrc"; then
        echo -e "\n# Activate Python virtual environment" >> "${AI_HOME}/.bashrc"
        echo 'if [ -f "$HOME/ai-venv/bin/activate" ]; then' >> "${AI_HOME}/.bashrc"
        echo '    source "$HOME/ai-venv/bin/activate"' >> "${AI_HOME}/.bashrc"
        echo 'fi' >> "${AI_HOME}/.bashrc"
    fi
    
    # Set up environment variables
    if [ ! -f "${AI_HOME}/.env" ]; then
        cat > "${AI_HOME}/.env" << EOF
# Dharma OS AI Environment Variables
MODEL_DIR="${AI_HOME}/ai-models"
OLLAMA_HOST="http://localhost:11434"
KRIX_AI_HOST="http://localhost:8000"
EOF
    fi
    
    log "${GREEN}✓ User environment configured.${NC}"
}

# Show completion message
show_completion() {
    log "\n${GREEN}========================================"
    log "  AI Setup Complete!"
    log "========================================${NC}"
    
    log "\n${GREEN}What's next?${NC}"
    log "1. Start using the AI services with: ${YELLOW}ai-manager start${NC}"
    log "2. Access the Krix AI web interface at: ${YELLOW}http://localhost:8000/api/docs${NC}"
    log "3. Manage AI models with: ${YELLOW}ai-model-manager${NC}"
    
    log "\n${GREEN}Documentation:${NC}"
    log "- ${YELLOW}${AI_HOME}/README.md${NC} - Local documentation"
    log "- ${YELLOW}https://krix-os.github.io/dharma-ai${NC} - Online documentation"
    
    log "\n${GREEN}Need help?${NC}"
    log "- Check the logs at: ${YELLOW}${LOG_FILE}${NC}"
    log "- Visit our community forum: ${YELLOW}https://community.krix-os.org${NC}"
    
    log "\n${GREEN}Thank you for choosing Dharma OS!${NC}\n"
}

# Main execution
main() {
    check_internet
    check_disk_space
    install_ai_components
    download_ai_models
    configure_environment
    show_completion
}

# Run the main function
main "$@"

exit 0
