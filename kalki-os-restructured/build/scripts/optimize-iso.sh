#!/bin/bash
# Kalki OS ISO Optimization Script

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Paths
ISO_PROFILE="/home/xero/os/kalki-os/iso-profile/kalki-base"
AIROOTFS="$ISO_PROFILE/airootfs"
PACKAGES_FILE="$ISO_PROFILE/packages.x86_64"
PACMAN_CONF="$ISO_PROFILE/pacman.conf"
PROFILE_DEF="$ISO_PROFILE/profiledef.sh"

# Function to print status messages
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to update compression settings
update_compression() {
    print_status "$YELLOW" "Updating compression settings..."
    if [ -f "$PROFILE_DEF" ]; then
        # Update compression settings
        if ! grep -q "airootfs_image_tool_options" "$PROFILE_DEF"; then
            echo 'airootfs_image_tool_options=("-comp" "zstd" "-Xcompression-level" "19" "-b" "1M")' >> "$PROFILE_DEF"
        else
            sed -i 's/-Xcompression-level [0-9]\+/-Xcompression-level 19/g' "$PROFILE_DEF"
        fi
        
        # Add filesystem options
        if ! grep -q "airootfs_image_type" "$PROFILE_DEF"; then
            echo 'airootfs_image_type="squashfs"' >> "$PROFILE_DEF"
        fi
    fi
}

# Function to optimize pacman configuration
optimize_pacman() {
    print_status "$YELLOW" "Optimizing pacman configuration..."
    if [ -f "$PACMAN_CONF" ]; then
        # Enable parallel downloads
        sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' "$PACMAN_CONF"
        
        # Add space-saving options
        if ! grep -q "^NoExtract" "$PACMAN_CONF"; then
            echo -e "\n# Space-saving exclusions" >> "$PACMAN_CONF"
            echo "NoExtract   = usr/share/man/* usr/share/gtk-doc/* usr/share/doc/*" >> "$PACMAN_CONF"
            echo "NoExtract   = usr/share/locale/*/LC_MESSAGES/*.mo" >> "$PACMAN_CONF"
            echo "NoExtract   = usr/share/help/*" >> "$PACMAN_CONF"
            echo "NoExtract   = usr/share/texmf-dist/doc/*" >> "$PACMAN_CONF"
        fi
    fi
}

# Function to clean up filesystem
cleanup_filesystem() {
    print_status "$YELLOW" "Cleaning up filesystem..."
    if [ -d "$AIROOTFS" ]; then
        # Remove man pages and documentation
        find "$AIROOTFS/usr/share/man" -type f -delete 2>/dev/null || true
        find "$AIROOTFS/usr/share/doc" -type f -delete 2>/dev/null || true
        find "$AIROOTFS/usr/share/gtk-doc" -type f -delete 2>/dev/null || true
        
        # Remove locale data (keep en_US)
        find "$AIROOTFS/usr/share/locale" -mindepth 1 -maxdepth 1 ! -name 'en_US' -exec rm -rf {} + 2>/dev/null || true
        
        # Clean package cache
        rm -rf "$AIROOTFS/var/cache/pacman/pkg/"* 2>/dev/null || true
        
        # Remove unnecessary files
        find "$AIROOTFS" -name '*.a' -delete 2>/dev/null || true
        find "$AIROOTFS" -name '*.la' -delete 2>/dev/null || true
        find "$AIROOTFS/usr/lib" -name '*.o' -delete 2>/dev/null || true
    fi
}

# Function to optimize package list
optimize_packages() {
    print_status "$YELLOW" "Optimizing package list..."
    if [ -f "$PACKAGES_FILE" ]; then
        local temp_file
        temp_file=$(mktemp)
        
        # Keep only essential packages and remove comments/empty lines
        grep -v '^#' "$PACKAGES_FILE" | grep -v '^$' | sort -u > "$temp_file"
        
        # Define packages to remove in an array
        local packages_to_remove=(
            'firefox' 'thunderbird' 'libreoffice*' 'gimp' 'inkscape' 'blender' 'krita'
            'texlive-*' 'texlive' 'texlive-*-doc' 'texlive-*-lang' 'texlive-*-recommended'
            'man-pages' 'man-db' 'man-pages-*' 'docbook-*' 'python-*doc*' '*-doc' '*-docs'
            '*-examples' '*-debug' '*-devel' '*-dev' '*-unstable' '*-git' '*-cvs' '*-svn'
            '*-browser' '*-web' '*-www' '*-www-browser' '*-www-client' '*-www-server' '*-www-service'
            '*-www-theme' '*-www-themes' '*-www-ui' '*-www-utils' '*-www-viewer' '*-www-widgets'
            '*-www-wm' '*-www-xul' '*-www-xulrunner' '*-x11' '*-x11-*' '*-x11-drivers' '*-x11-libs'
            '*-x11-utils' '*-x11-xfs' '*-x11-xkb-utils' '*-x11-xserver' '*-x11-xserver-utils'
            '*-x11-xserver-xephyr' '*-x11-xserver-xnest' '*-x11-xserver-xvfb' '*-x11-xserver-xwayland'
            '*-x11-xserver-common' '*-x11-xserver-xorg' '*-x11-xserver-xorg-core' '*-x11-xserver-xorg-dev'
            '*-x11-xserver-xorg-doc' '*-x11-xserver-xorg-input-evdev' '*-x11-xserver-xorg-input-kbd'
            '*-x11-xserver-xorg-input-libinput' '*-x11-xserver-xorg-input-mouse' '*-x11-xserver-xorg-input-synaptics'
            '*-x11-xserver-xorg-input-wacom' '*-x11-xserver-xorg-video-amdgpu' '*-x11-xserver-xorg-video-ati'
            '*-x11-xserver-xorg-video-fbdev' '*-x11-xserver-xorg-video-intel' '*-x11-xserver-xorg-video-nouveau'
            '*-x11-xserver-xorg-video-vesa' '*-x11-xserver-xorg-video-vmware' '*-x11-xserver-xorg-video-qxl'
        )
        
        # Process package removals
        for pkg in "${packages_to_remove[@]}"; do
            grep -v "^$pkg" "$temp_file" > "${temp_file}.tmp"
            mv "${temp_file}.tmp" "$temp_file"
        done
        
        # Define essential packages in an array
        local essential_packages=(
            'base' 'linux-zen' 'linux-firmware' 'intel-ucode' 'amd-ucode'
            'plymouth' 'plymouth-theme-breeze' 'sddm' 'xorg-server' 'hyprland' 'waybar'
            'wofi' 'mako' 'alacritty' 'thunar' 'hyprpaper' 'pipewire' 'pipewire-alsa'
            'pipewire-pulse' 'wireplumber' 'networkmanager' 'network-manager-applet'
            'firefox' 'btrfs-progs' 'snapper' 'zram-generator' 'ufw' 'git' 'base-devel'
            'neovim' 'rust' 'cargo' 'python' 'python-pip' 'jq' 'wget' 'curl' 'htop'
        )
        
        # Ensure essential packages are included
        for pkg in "${essential_packages[@]}"; do
            if ! grep -q "^$pkg$" "$temp_file"; then
                echo "$pkg" >> "$temp_file"
            fi
        done
        
        # Sort and clean up
        sort -u "$temp_file" > "$PACKAGES_FILE"
        rm -f "$temp_file"
    fi
}

# Function to create cleanup script
create_cleanup_script() {
    print_status "$YELLOW" "Creating post-installation cleanup script..."
    cat > "$AIROOTFS/root/cleanup-system.sh" << 'EOF'
#!/bin/bash
# Post-installation cleanup script for Kalki OS

set -euo pipefail

# Remove orphaned packages
pacman -Rns $(pacman -Qtdq) 2>/dev/null || true

# Clean package cache
paccache -rk 1

# Remove old configuration files
find /etc -name '*.pacnew' -o -name '*.pacsave' -delete

# Clean temporary files
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /var/cache/pacman/pkg/*

echo "System cleanup completed!"
EOF

    chmod +x "$AIROOTFS/root/cleanup-system.sh"
}

# Main function
main() {
    # Ensure we're running as root
    if [ "$(id -u)" -ne 0 ]; then
        print_status "$RED" "This script must be run as root"
        exit 1
    fi

    print_status "$YELLOW" "Starting ISO optimization..."
    
    # Run optimization steps
    update_compression
    optimize_pacman
    cleanup_filesystem
    optimize_packages
    create_cleanup_script
    
    print_status "$GREEN" "ISO optimization completed successfully!"
}

# Execute main function
main "$@"
