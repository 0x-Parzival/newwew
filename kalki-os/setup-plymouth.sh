#!/bin/bash
# Setup Plymouth for Kalki OS

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Paths
ISO_PROFILE="/home/xero/os/kalki-os/iso-profile/kalki-base"
AIROOTFS="$ISO_PROFILE/airootfs"

# Function to print status messages
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Ensure we're running as root
if [ "$(id -u)" -ne 0 ]; then
    print_status "$RED" "This script must be run as root"
    exit 1
fi

print_status "$YELLOW" "Setting up Plymouth for Kalki OS..."

# 1. Create Plymouth configuration directory
print_status "$YELLOW" "Creating Plymouth configuration..."
mkdir -p "$AIROOTFS/etc/plymouth"

# 2. Create plymouthd.conf
cat > "$AIROOTFS/etc/plymouth/plymouthd.conf" << 'EOF'
[Daemon]
Theme=breeze
ShowDelay=0
DeviceTimeout=5
EOF

# 3. Configure mkinitcpio with correct hook order
print_status "$YELLOW" "Configuring mkinitcpio..."
mkdir -p "$AIROOTFS/etc/mkinitcpio.d"

# Create linux.preset
cat > "$AIROOTFS/etc/mkinitcpio.d/linux.preset" << 'EOF'
# mkinitcpio preset file for the 'linux' package

ALL_config="/etc/mkinitcpio.conf"
ALL_kver="/boot/vmlinuz-linux"

PRESETS=('default' 'fallback')

default_image="/boot/initramfs-linux.img"
default_options="--splash /usr/share/plymouth/themes/breeze/breeze.script"

fallback_image="/boot/initramfs-linux-fallback.img"
fallback_options="-S autodetect --splash /usr/share/plymouth/themes/breeze/breeze.script"
EOF

# Update mkinitcpio.conf
if [ -f "$AIROOTFS/etc/mkinitcpio.conf" ]; then
    if ! grep -q "plymouth" "$AIROOTFS/etc/mkinitcpio.conf"; then
        sed -i 's/^HOOKS=.*/HOOKS=(base udev plymouth autodetect modconf block filesystems keyboard fsck)/' \
            "$AIROOTFS/etc/mkinitcpio.conf"
    fi
fi

# 4. Configure GRUB
print_status "$YELLOW" "Configuring GRUB..."
mkdir -p "$AIROOTFS/etc/default"

cat > "$AIROOTFS/etc/default/grub" << 'EOF'
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Kalki"
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0"
GRUB_CMDLINE_LINUX=""
GRUB_GFXMODE=auto
GRUB_GFXPAYLOAD_LINUX=keep
EOF

# 5. Configure systemd-boot
print_status "$YELLOW" "Configuring systemd-boot..."
mkdir -p "$AIROOTFS/efi/loader/entries"

cat > "$AIROOTFS/efi/loader/entries/arch.conf" << 'EOF'
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options root=LABEL=KALKI_OS rw quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0
EOF

# 6. Add Plymouth to autostart
print_status "$YELLOW" "Configuring Plymouth autostart..."
mkdir -p "$AIROOTFS/etc/xdg/autostart"

cat > "$AIROOTFS/etc/xdg/autostart/plymouth.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=Plymouth
Exec=/usr/bin/plymouthd --tty=tty1 --mode=boot --pid-file=/run/plymouth/pid --attach-to-session
Terminal=false
NoDisplay=true
EOF

# 7. Create a post-installation script
print_status "$YELLOW" "Creating post-installation setup script..."
mkdir -p "$AIROOTFS/root"

cat > "$AIROOTFS/root/setup-plymouth.sh" << 'EOF'
#!/bin/bash
# Post-installation Plymouth setup for Kalki OS

set -euo pipefail

# Set Plymouth theme
if command -v plymouth-set-default-theme &> /dev/null; then
    plymouth-set-default-theme -R breeze
fi

# Update GRUB if installed
if command -v grub-mkconfig &> /dev/null && [ -f /etc/default/grub ]; then
    grub-mkconfig -o /boot/grub/grub.cfg
fi

# Update systemd-boot if installed
if command -v bootctl &> /dev/null && [ -d /efi/loader ]; then
    bootctl update
fi

echo "Plymouth setup completed successfully!"
EOF

chmod +x "$AIROOTFS/root/setup-plymouth.sh"

print_status "$GREEN" "Plymouth configuration completed successfully!"
