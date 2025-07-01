#!/bin/bash
set -e

# Create a mount point for the chroot
MNT_DIR="/mnt/kalki-chroot"

# Function to run commands in chroot
run_in_chroot() {
    sudo arch-chroot "$MNT_DIR" /bin/bash -c "$1"
}

# Mount the target filesystem
sudo mkdir -p "$MNT_DIR"

# Install additional packages in chroot
echo "Installing additional packages in chroot..."
run_in_chroot "pacman -Syu --noconfirm"
run_in_chroot "pacman -S --needed --noconfirm $(cat /home/xero/os/kalki-os/iso-profile/kalki-base/packages.x86_64 | tr '\n' ' ')"

# Clean up package cache to reduce ISO size
echo "Cleaning up package cache..."
run_in_chroot "pacman -Scc --noconfirm"

# Update systemd services
echo "Enabling systemd services..."
run_in_chroot "systemctl enable sddm"
run_in_chroot "systemctl enable NetworkManager"
run_in_chroot "systemctl enable bluetooth"
run_in_chroot "systemctl enable sshd"

echo "Post-installation setup completed successfully!"
