#!/bin/bash

# This script configures the boot parameters for Plymouth

# Set the boot parameters for GRUB
cat > /etc/default/grub << 'EOF'
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Kalki OS"
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 udev.log_priority=3 vt.global_cursor_default=0 plymouth.boot-log=/dev/null"
GRUB_CMDLINE_LINUX=""
GRUB_PRELOAD_MODULES="part_gpt part_msdos"
GRUB_TERMINAL_INPUT=console
GRUB_TERMINAL_OUTPUT=console
GRUB_GFXMODE=auto
GRUB_GFXPAYLOAD_LINUX=keep
GRUB_DISABLE_OS_PROBER=false
GRUB_THEME="/boot/grub/themes/kalki/theme.txt"
EOF

# Update GRUB configuration
grub-mkconfig -o /boot/grub/grub.cfg

# Ensure Plymouth is enabled on boot
systemctl enable plymouth-quit-wait.service
systemctl enable plymouth-start.service
systemctl enable plymouth-read-write.service

# Update initramfs with Plymouth
mkinitcpio -P
