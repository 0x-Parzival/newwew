#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Paths
ISO_PROFILE="/home/xero/os/kalki-os/iso-profile/kalki-base"

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

# Check if ISO profile exists
if [ ! -d "$ISO_PROFILE" ]; then
    print_status "$RED" "ISO profile directory not found: $ISO_PROFILE"
    exit 1
fi

print_status "$YELLOW" "=== Fixing Boot Configuration ==="

# 1. Create required directories
print_status "$YELLOW" "Creating required directories..."
mkdir -p "$ISO_PROFILE/airootfs/boot/grub"
mkdir -p "$ISO_PROFILE/syslinux"
mkdir -p "$ISO_PROFILE/efiboot/loader/entries"

# 2. Create basic syslinux.cfg
print_status "$YELLOW" "Creating syslinux configuration..."
cat > "$ISO_PROFILE/syslinux/syslinux.cfg" << 'EOF'
DEFAULT archlinux
LABEL archlinux
    MENU LABEL Boot Kalki OS (x86_64)
    LINUX /%INSTALL_DIR%/boot/x86_64/vmlinuz-linux
    APPEND root=live:LABEL=KALKI_OS rw rootfstype=auto net.ifnames=0 quiet splash
    INITRD /%INSTALL_DIR%/boot/x86_64/initramfs-linux.img

LABEL archlinux-verbose
    MENU LABEL Boot Kalki OS (verbose)
    LINUX /%INSTALL_DIR%/boot/x86_64/vmlinuz-linux
    APPEND root=live:LABEL=KALKI_OS rw rootfstype=auto net.ifnames=0
    INITRD /%INSTALL_DIR%/boot/x86_64/initramfs-linux.img

LABEL memtest
    MENU LABEL Memory Test (memtest86+)
    LINUX /%INSTALL_DIR%/boot/memtest86+/memtest

LABEL reboot
    MENU LABEL Reboot
    COM32 reboot.c32

LABEL poweroff
    MENU LABEL Power Off
    COM32 poweroff.c32
EOF

# 3. Create UEFI boot entry
print_status "$YELLOW" "Creating UEFI boot configuration..."
cat > "$ISO_PROFILE/efiboot/loader/entries/01-archiso-x86_64-linux.conf" << 'EOF'
title   Kalki OS (x86_64)
linux   /%INSTALL_DIR%/boot/x86_64/vmlinuz-linux
initrd  /%INSTALL_DIR%/boot/x86_64/initramfs-linux.img
options archisobasedir=%INSTALL_DIR% archisolabel=KALKI_OS copytoram
EOF

# 4. Create loader.conf for systemd-boot
cat > "$ISO_PROFILE/efiboot/loader/loader.conf" << 'EOF'
default 01-archiso-x86_64-linux.conf
timeout 5
editor  yes
EOF

# 5. Create GRUB configuration
print_status "$YELLOW" "Creating GRUB configuration..."
cat > "$ISO_PROFILE/airootfs/boot/grub/grub.cfg" << 'EOF'
set default=0
set timeout=5

menuentry 'Boot Kalki OS (x86_64)' {
    linux /%INSTALL_DIR%/boot/x86_64/vmlinuz-linux root=live:LABEL=KALKI_OS rw rootfstype=auto net.ifnames=0 quiet splash
    initrd /%INSTALL_DIR%/boot/x86_64/initramfs-linux.img
}

menuentry 'Boot Kalki OS (verbose)' {
    linux /%INSTALL_DIR%/boot/x86_64/vmlinuz-linux root=live:LABEL=KALKI_OS rw rootfstype=auto net.ifnames=0
    initrd /%INSTALL_DIR%/boot/x86_64/initramfs-linux.img
}

menuentry 'Reboot' {
    reboot
}

menuentry 'Power Off' {
    halt
}
EOF

# 6. Ensure proper permissions
chmod 644 "$ISO_PROFILE/efiboot/loader/entries/01-archiso-x86_64-linux.conf"
chmod 644 "$ISO_PROFILE/efiboot/loader/loader.conf"
chmod 644 "$ISO_PROFILE/syslinux/syslinux.cfg"
chmod 644 "$ISO_PROFILE/airootfs/boot/grub/grub.cfg"

print_status "$GREEN" "Boot configuration updated successfully!"
print_status "$YELLOW" "Please rebuild the ISO to apply changes."
