#!/bin/bash
set -euo pipefail

# Kalki OS Automated Build Script
# Based on comprehensive ArchISO implementation guide

# ANSI Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Dharmic symbols for visual appeal
OM_SYMBOL="🕉️"
KALKI_SYMBOL="⚔️"
SUCCESS_SYMBOL="✅"
ERROR_SYMBOL="❌"
BUILDING_SYMBOL="🔨"
TESTING_SYMBOL="🧪"

# Function to print colored output
print_status() {
    local color=$1
    local symbol=$2
    local message=$3
    echo -e "${color}${symbol} ${message}${NC}"
}

print_header() {
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE}${OM_SYMBOL}     KALKI OS - DHARMIC COMPUTING     ${OM_SYMBOL}${NC}"
    echo -e "${PURPLE}         ArchISO Build System${NC}"
    echo -e "${PURPLE}================================================${NC}"
    echo
}

check_dependencies() {
    print_status "$BLUE" "$KALKI_SYMBOL" "Checking build dependencies..."

    local deps=("archiso" "git" "qemu-system-x86_64" "mkarchiso")
    local missing_deps=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done

    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_status "$RED" "$ERROR_SYMBOL" "Missing dependencies: ${missing_deps[*]}"
        print_status "$YELLOW" "$KALKI_SYMBOL" "Installing missing dependencies..."
        sudo pacman -S --needed --noconfirm "${missing_deps[@]}" || {
            print_status "$RED" "$ERROR_SYMBOL" "Failed to install dependencies"
            exit 1
        }
    fi
}

create_project_structure() {
    print_status "$BLUE" "$KALKI_SYMBOL" "Creating project structure..."
    
    mkdir -p ~/kalki-os-project/iso
    mkdir -p ~/kalki-os-project/airootfs
    mkdir -p ~/kalki-os-project/out
    
    # Copy ISO profile if it doesn't exist
    if [ ! -d ~/kalki-os-project/iso-profile ]; then
        cp -r /usr/share/archiso/configs/releng ~/kalki-os-project/iso-profile
    fi
    
    print_status "$GREEN" "$SUCCESS_SYMBOL" "Project structure created at ~/kalki-os-project"
}

configure_iso_profile() {
    print_status "$BLUE" "$KALKI_SYMBOL" "Configuring ISO profile..."
    
    local profile_dir=~/kalki-os-project/iso-profile
    
    # Copy our custom files
    cp -r /home/xero/os/kalki-os/iso-profile/* "$profile_dir/"
    
    # Update pacman.conf with our customizations
    if [ -f "$profile_dir/pacman.conf" ]; then
        # Enable multilib and other required repositories
        sed -i '/^#\[multilib\]/,/^#\[.*\]/ s/^#//' "$profile_dir/pacman.conf"
        
        # Add custom repositories if needed
        if ! grep -q "krix" "$profile_dir/pacman.conf"; then
            echo -e "\n[krix]\nServer = https://repo.krix.io/archlinux/$repo/os/$arch\n" >> "$profile_dir/pacman.conf"
        fi
    fi
    
    print_status "$GREEN" "$SUCCESS_SYMBOL" "ISO profile configured"
}

configure_desktop() {
    print_status "$BLUE" "$KALKI_SYMBOL" "Configuring Glass Dharma desktop..."
    
    local airootfs=~/kalki-os-project/airootfs
    
    # Copy our comprehensive graphical setup script
    if [ -f "/home/xero/os/kalki-os/scripts/setup-graphical.sh" ]; then
        print_status "$BLUE" "$KALKI_SYMBOL" "Installing graphical environment..."
        mkdir -p "$airootfs/usr/local/bin"
        cp /home/xero/os/kalki-os/scripts/setup-graphical.sh "$airootfs/root/setup-graphical.sh"
        chmod +x "$airootfs/root/setup-graphical.sh"
        
        # Create a systemd service to run the setup script on first boot
        mkdir -p "$airootfs/etc/systemd/system/multi-user.target.wants"
        cat > "$airootfs/etc/systemd/system/setup-graphical.service" << 'EOF'
[Unit]
Description=Setup Graphical Environment
After=network.target

[Service]
Type=oneshot
ExecStart=/root/setup-graphical.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

        # Enable the service
        ln -sf /etc/systemd/system/setup-graphical.service \
            "$airootfs/etc/systemd/system/multi-user.target.wants/setup-graphical.service"
    fi

    # SDDM auto-login configuration
    mkdir -p "$airootfs/etc/sddm.conf.d"
    cat > "$airootfs/etc/sddm.conf.d/kalki.conf" << 'EOF'
[Autologin]
User=kalki
Session=hyprland
EOF

    # Hyprland session
    mkdir -p "$airootfs/usr/share/wayland-sessions"
    cat > "$airootfs/usr/share/wayland-sessions/hyprland.desktop" << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=Dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
EOF

    # Basic Hyprland configuration (will be enhanced by the setup script)
    mkdir -p "$airootfs/etc/skel/.config/hypr"
    cat > "$airootfs/etc/skel/.config/hypr/hyprland.conf" << 'EOF'
# Kalki OS Hyprland Configuration
# This is a minimal config - full config will be installed by setup-graphical.sh

# Basic monitor setup
monitor = ,preferred,auto,1

# Basic key bindings
$mainMod = SUPER
bind = $mainMod, Return, exec, alacritty
bind = $mainMod, Q, killactive
bind = $mainMod, R, exec, wofi --show drun

# Basic workspace setup
workspace = 1, monitor:HDMI-A-1
workspace = 2, monitor:HDMI-A-1
workspace = 3, monitor:HDMI-A-1
workspace = 4, monitor:DP-1
workspace = 5, monitor:DP-1

# Basic window rules
windowrulev2 = float,class:^(org.kde.polkit-kde-authentication-agent-1)$
windowrulev2 = float,class:^(pavucontrol)$
windowrulev2 = float,class:^(blueman-manager)$

# Basic environment variables
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORM,wayland
env = QT_WAYLAND_DISABLE_WINDOWDECORATION,1
env = QT_AUTO_SCREEN_SCALE_FACTOR,1

# Basic input settings
input {
    kb_layout = us
    follow_mouse = 1
    sensitivity = 0
}

# Basic general settings
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    layout = dwindle
}

# Basic decoration settings
decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
}

# Basic animations
animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# Basic layout settings
dwindle {
    pseudotile = yes
    preserve_split = yes
}

master {
    new_is_master = true
}

gestures {
    workspace_swipe = true
}
EOF

    print_status "$GREEN" "$SUCCESS_SYMBOL" "Desktop environment configured"
}

build_iso() {
    print_status "$BLUE" "$BUILDING_SYMBOL" "Building ISO..."
    
    local profile_dir=~/kalki-os-project/iso-profile
    local out_dir=~/kalki-os-project/out
    
    # Clean previous build
    rm -f "$out_dir"/*.iso
    
    # Build the ISO
    sudo mkarchiso -v \
        -w /tmp/archiso-tmp \
        -o "$out_dir" \
        "$profile_dir/"
    
    if [ $? -eq 0 ]; then
        print_status "$GREEN" "$SUCCESS_SYMBOL" "ISO built successfully!"
        ls -lh "$out_dir"/*.iso
    else
        print_status "$RED" "$ERROR_SYMBOL" "Failed to build ISO"
        exit 1
    fi
}

test_iso() {
    local out_dir=~/kalki-os-project/out
    local iso_file=("$out_dir"/*.iso)
    
    if [ ! -f "$iso_file" ]; then
        print_status "$RED" "$ERROR_SYMBOL" "No ISO file found in $out_dir"
        return 1
    fi
    
    print_status "$BLUE" "$TESTING_SYMBOL" "Testing ISO in QEMU..."
    
    qemu-system-x86_64 \
        -cdrom "$iso_file" \
        -m 8G \
        -smp 4 \
        -enable-kvm \
        -cpu host \
        -vga virtio \
        -display gtk,gl=on \
        -device virtio-net,netdev=net0 \
        -netdev user,id=net0,hostfwd=tcp::2222-:22
}

# Main execution flow
main() {
    print_header
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        print_status "$RED" "$ERROR_SYMBOL" "This script should not be run as root"
        exit 1
    fi
    
    # Check and install dependencies
    check_dependencies
    
    # Create project structure
    create_project_structure
    
    # Configure ISO profile
    configure_iso_profile
    
    # Configure desktop environment
    configure_desktop
    
    # Build the ISO
    build_iso
    
    # Ask to test the ISO
    echo
    read -p "Test the ISO in QEMU? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        test_iso
    fi
}

# Error handling
trap 'print_status "$RED" "$ERROR_SYMBOL" "Build interrupted. Check ~/kalki-os-project/ for partial progress."' INT TERM

# Run main function
main "$@"
