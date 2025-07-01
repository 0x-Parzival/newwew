#!/bin/bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Log function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Error function
error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

# Install required packages
install_dependencies() {
    log "Installing required packages..."
    pacman -S --noconfirm --needed \
        plymouth \
        plymouth-theme-kodi \
        noto-fonts \
        noto-fonts-emoji \
        noto-fonts-cjk \
        noto-fonts-extra \
        ttf-dejavu \
        ttf-liberation \
        ttf-ubuntu-font-family \
        gnu-free-fonts \
        ttf-hack \
        ttf-jetbrains-mono \
        ttf-nerd-fonts-symbols
}

# Generate OM symbol image
generate_om_symbol() {
    local theme_dir="/usr/share/plymouth/themes/kalki-dharma"
    local font_path="/usr/share/fonts/noto/NotoSansDevanagari-Regular.ttf"
    
    log "Generating OM symbol image..."
    
    # Create theme directory if it doesn't exist
    mkdir -p "$theme_dir"
    
    # Generate the OM symbol using ImageMagick
    if ! convert -size 200x200 xc:transparent \
        -font "$font_path" \
        -pointsize 100 \
        -fill white \
        -gravity center \
        -annotate +0+0 "ॐ" \
        "${theme_dir}/om-symbol.png" 2>/dev/null; then
        
        # Fallback to using text if image generation fails
        log "${YELLOW}Warning: Could not generate OM symbol image, using text fallback${NC}"
        echo "ॐ" > "${theme_dir}/om-symbol.txt"
    fi
}

# Configure Plymouth
configure_plymouth() {
    log "Configuring Plymouth..."
    
    # Set the default theme
    if ! plymouth-set-default-theme -R kalki-dharma; then
        error "Failed to set Plymouth theme"
    fi
    
    # Enable necessary services
    log "Enabling Plymouth services..."
    systemctl enable plymouth-quit-wait.service || \
        log "${YELLOW}Warning: Failed to enable plymouth-quit-wait.service${NC}"
    
    systemctl enable plymouth-start.service || \
        log "${YELLOW}Warning: Failed to enable plymouth-start.service${NC}"
    
    systemctl enable plymouth-set-theme.service || \
        log "${YELLOW}Warning: Failed to enable plymouth-set-theme.service${NC}"
    
    # Update initramfs
    log "Updating initramfs..."
    if ! mkinitcpio -P; then
        error "Failed to update initramfs"
    fi
    
    # Update GRUB configuration
    if [ -f /etc/default/grub ]; then
        log "Updating GRUB configuration..."
        sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash rd.udev.log_priority=3 vt.global_cursor_default=0"/' /etc/default/grub
        grub-mkconfig -o /boot/grub/grub.cfg
    fi
}

# Main function
main() {
    # Check if running as root
    if [ "$(id -u)" -ne 0 ]; then
        error "This script must be run as root"
    fi
    
    # Install dependencies
    install_dependencies
    
    # Generate OM symbol
    generate_om_symbol
    
    # Configure Plymouth
    configure_plymouth
    
    log "Plymouth setup completed successfully!"
}

# Run the script
main "$@"
