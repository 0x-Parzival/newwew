#!/bin/bash
set -e  # Exit on error

# Wallpaper setup function
setup_wallpapers() {
    log "Setting up dynamic wallpapers..."
    
    # Create wallpaper directories
    mkdir -p "/opt/kalki/wallpapers/{dawn,day,dusk,night}"
    
    # Install required dependencies
    pacman -S --noconfirm --needed imagemagick
    
    # Make scripts executable
    chmod +x /usr/local/bin/kalki-wallpaper
    chmod +x /usr/local/bin/setup-wallpapers
    
    # Run the setup script
    /usr/local/bin/setup-wallpapers
    
    # Create systemd directories for user services
    mkdir -p "/etc/skel/.config/systemd/user/"
    
    # Copy systemd service files
    cp /etc/systemd/system/kalki-wallpaper.service "/etc/skel/.config/systemd/user/"
    cp /etc/systemd/system/kalki-wallpaper.timer "/etc/skel/.config/systemd/user/"
    
    # Enable the service for new users
    echo '[[ -f ~/.config/systemd/user/kalki-wallpaper.timer ]] && \
    systemctl --user enable --now kalki-wallpaper.timer' >> "/etc/skel/.zshrc"
    
    log "Wallpaper setup complete"
}

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

# Update keyring and mirrors
update_system() {
    log "Updating keyring..."
    pacman -Sy --noconfirm archlinux-keyring || error "Failed to update keyring"
    
    log "Initializing pacman keyring..."
    pacman-key --init || error "Failed to initialize keyring"
    pacman-key --populate archlinux || error "Failed to populate keyring"
    
    log "Updating mirrorlist..."
    # Use reflector to get the fastest mirrors
    if ! command -v reflector >/dev/null; then
        pacman -S --noconfirm reflector
    fi
    
    # Create a backup of the current mirrorlist
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
    
    # Generate a new mirrorlist
    reflector \
        --verbose \
        --country US \
        --protocol https \
        --latest 20 \
        --sort rate \
        --save /etc/pacman.d/mirrorlist || \
        error "Failed to generate mirrorlist"
    
    log "Mirrorlist updated successfully"
}

# Setup Plymouth boot splash
setup_plymouth() {
    log "Setting up Plymouth boot splash..."
    
    # Install Plymouth if not already installed
    if ! command -v plymouth &>/dev/null; then
        log "Installing Plymouth..."
        pacman -S --noconfirm --needed plymouth
    fi
    
    # Run Plymouth setup script
    if [ -f "/root/setup-plymouth.sh" ]; then
        log "Running Plymouth setup..."
        chmod +x /root/setup-plymouth.sh
        /root/setup-plymouth.sh || error "Plymouth setup failed"
    else
        log "${YELLOW}Warning: Plymouth setup script not found${NC}"
    fi
    
    # Ensure Plymouth is properly configured in mkinitcpio
    log "Ensuring Plymouth is properly configured in mkinitcpio..."
    
    # Create mkinitcpio.d directory if it doesn't exist
    mkdir -p /etc/mkinitcpio.d
    
    # Copy our preset file if it doesn't exist
    if [ ! -f "/etc/mkinitcpio.d/kalki.preset" ]; then
        cp "/usr/share/mkinitcpio/kalki.preset" "/etc/mkinitcpio.d/" || \
            log "${YELLOW}Warning: Failed to copy kalki.preset${NC}"
    fi
    
    # Update mkinitcpio configuration
    if [ -f "/usr/local/bin/update-mkinitcpio" ]; then
        /usr/local/bin/update-mkinitcpio || \
            log "${YELLOW}Warning: Failed to update mkinitcpio configuration${NC}"
    fi
}

# Configure kernel parameters for better boot experience
configure_kernel_params() {
    log "Configuring kernel parameters..."
    
    # Set kernel parameters for quiet boot and splash
    local grub_cfg="/etc/default/grub"
    if [ -f "$grub_cfg" ]; then
        log "Updating GRUB configuration..."
        
        # Backup original config
        cp "$grub_cfg" "${grub_cfg}.bak"
        
        # Update kernel parameters
        sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash rd.udev.log_priority=3 vt.global_cursor_default=0"/' "$grub_cfg"
        
        # Update GRUB if available
        if command -v update-grub &>/dev/null; then
            update-grub
        elif command -v grub-mkconfig &>/dev/null; then
            grub-mkconfig -o /boot/grub/grub.cfg
        fi
    fi
}

# Branding setup
setup_branding() {
    log "Setting up Kalki OS branding..."
    
    # Run the branding setup script
    if [ -f "/root/setup-branding.sh" ]; then
        chmod +x /root/setup-branding.sh
        /root/setup-branding.sh || log "Warning: Branding setup encountered issues"
    else
        log "Branding setup script not found"
    fi
    
    # Ensure os-release is properly set
    if [ -f "/etc/os-release" ]; then
        chmod 644 /etc/os-release
    fi
    
    # Ensure lsb-release is properly set
    if [ -f "/etc/lsb-release" ]; then
        chmod 644 /etc/lsb-release
    fi
}

# Main execution
main() {
    log "Starting ISO customization..."
    
    # Update system first
    update_system
    
    # Set up branding
    setup_branding
    
    # Set up Plymouth
    setup_plymouth
    
    # Configure kernel parameters
    configure_kernel_params
    
    # Run user setup script if it exists
    if [ -f "/root/setup-user.sh" ]; then
        log "Running user setup..."
        /root/setup-user.sh || error "User setup failed"
    fi
    
    # Set up services if the script exists
    if [ -f "/root/setup-services.sh" ]; then
        log "Setting up services..."
        /root/setup-services.sh || error "Service setup failed"
    fi

# Set up autologin for getty
tty=1
if [[ -d "/etc/systemd/system/getty@tty${tty}.service.d" ]]; then
    mkdir -p "/etc/systemd/system/getty@tty${tty}.service.d"
    cat > "/etc/systemd/system/getty@tty${tty}.service.d/autologin.conf" << 'EOF'
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin kalki --noclear %I \$TERM
Type=simple
EOF
fi

# Set default shell to zsh
chsh -s /bin/zsh kalki

# Create .zshrc if it doesn't exist
if [[ ! -f "/home/kalki/.zshrc" ]]; then
    cat > "/home/kalki/.zshrc" << 'EOF'
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Basic zsh configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Aliases
alias ls="ls --color=auto"
alias ll="ls -la"
alias update="sudo pacman -Syu"

# Environment variables
export EDITOR=nvim
export VISUAL=nvim

# Start Hyprland at login
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
    exec Hyprland
fi
EOF
    chown kalki:kalki "/home/kalki/.zshrc"
fi

# Set up XDG user directories
mkdir -p "/home/kalki/Desktop"
mkdir -p "/home/kalki/Downloads"
mkdir -p "/home/kalki/Documents"
mkdir -p "/home/kalki/Pictures"
mkdir -p "/home/kalki/Videos"
chown -R kalki:kalki "/home/kalki"

# Set default file permissions
chmod 700 "/home/kalki"
chmod 755 "/home"
    
    # Set up dynamic wallpapers
    setup_wallpapers
}

# Execute main function
main "$@"

# AI Assistant setup function
setup_ai_assistant() {
    log "Setting up AI Installation Assistant..."
    
    # Install required dependencies
    log "Installing AI assistant dependencies..."
    pacman -S --noconfirm --needed \
        python-pip \
        python-torch \
        python-numpy \
        python-transformers \
        python-llama-cpp-python
    
    # Install Python packages
    log "Installing Python packages..."
    pip install --no-cache-dir \
        llama-cpp-python \
        pyyaml \
        requests
    
    # Verify model exists
    if [ ! -f "/opt/kalki/ai-assistant/install-assistant.gguf" ]; then
        error "AI model not found in /opt/kalki/ai-assistant/"
        return 1
    fi
    
    # Set permissions
    chmod +x /opt/kalki/ai-assistant/kia.py
    chmod 644 /opt/kalki/ai-assistant/install-assistant.gguf
    
    # Create symbolic links for easy access
    ln -sf /opt/kalki/ai-assistant/kia.py /usr/local/bin/kia
    
    # Enable the service for the live environment
    systemctl enable kalki-install-assistant.service
    
    log "AI Installation Assistant setup complete"
}

# Setup AI Installation Assistant
log "Setting up AI Installation Assistant..."
setup_ai_assistant || {
    log "Warning: AI assistant setup encountered issues, but continuing..." "YELLOW"
}
