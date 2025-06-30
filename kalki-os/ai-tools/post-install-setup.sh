#!/bin/bash

# Dharma OS - Post-Install AI Setup
# This script is run after system installation to complete AI setup

# Exit on error
set -e

# Configuration
AI_USER="kalki"
AI_HOME="/home/${AI_USER}"
LOG_FILE="/var/log/krix-ai/post-install.log"

# Create log directory
mkdir -p "$(dirname "${LOG_FILE}")
touch "${LOG_FILE}"
chown -R ${AI_USER}:${AI_USER} "$(dirname "${LOG_FILE}")"
chmod 644 "${LOG_FILE}"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"
}

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

log "Starting Dharma OS AI post-installation setup..."

# Check if we're in a live environment
if grep -q "boot=live" /proc/cmdline; then
    log "Running in live environment, skipping post-install setup."
    exit 0
fi

# Check if this is the first boot after installation
if [ ! -f "/var/lib/krix-ai/first-boot" ]; then
    log "First boot detected, running initial setup..."
    
    # Create first boot marker
    mkdir -p /var/lib/krix-ai
    touch /var/lib/krix-ai/first-boot
    
    # Enable and start AI services
    log "Enabling AI services..."
    systemctl enable krix-ai || log "Warning: Failed to enable krix-ai service"
    systemctl enable ollama || log "Warning: Failed to enable ollama service"
    
    # Set up user environment
    log "Setting up user environment..."
    sudo -u ${AI_USER} mkdir -p "${AI_HOME}/.config/autostart"
    
    # Create desktop entry for model download
    cat > "/tmp/ai-setup.desktop" << EOF
[Desktop Entry]
Type=Application
Name=AI Setup Assistant
Comment=Complete AI setup for Dharma OS
Exec=konsole -e "bash -c '~/ai-tools/start-ai-setup.sh; read -p \"Press Enter to close this window...\"'"
Icon=system-run
Terminal=false
Categories=System;
X-KDE-autostart-phase=2
X-KDE-autostart-after=panel
EOF
    
    mv "/tmp/ai-setup.desktop" "${AI_HOME}/.config/autostart/ai-setup.desktop"
    chown ${AI_USER}:${AI_USER} "${AI_HOME}/.config/autostart/ai-setup.desktop"
    
    log "First boot setup complete. The AI Setup Assistant will start on login."
else
    log "Not first boot, skipping initial setup."
fi

log "Post-installation setup complete."
exit 0
