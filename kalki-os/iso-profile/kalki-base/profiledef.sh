#!/usr/bin/env bash
# shellcheck disable=SC2034

# Core ISO configuration
iso_name="kalki"
iso_label="KALKI_OS_$(date +%Y%m)"
iso_publisher="Krix Collective <dharma@kalki.os>"
iso_application="Kalki OS Live/Installation Medium"
iso_version="$(date +%Y.%m.%d)"
install_dir="kalki"

# Build and boot configuration
buildmodes=('iso')
bootmodes=(
    'bios.syslinux.mbr'
    'bios.syslinux.eltorito'
    'uefi-x64.systemd-boot.esp'
    'uefi-x64.systemd-boot.eltorito'
)

# System architecture and package management
arch="x86_64"
pacman_conf="pacman.conf"

# Filesystem and compression settings
airootfs_image_type="squashfs"
airootfs_image_tool_options=(
    '-comp' 'zstd'
    '-Xcompression-level' '19'
    '-b' '1M'
    '-mem' '4G'
)

# Bootstrap tarball settings
bootstrap_tarball_compression=(
    'zstd'
    '-c'
    '-T0'
    '--auto-threads=logical'
    '--ultra'
    '-22'
)

# Set secure file permissions
file_permissions=(
  # System security files
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/etc/sudoers"]="0:0:440"
  
  # Root directory permissions
  ["/root"]="0:0:750"
  ["/root/.ssh"]="0:0:700"
  ["/root/.gnupg"]="0:0:700"
  
  # Executable scripts
  ["/root/.automated_script.sh"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  
  # System directories
  ["/etc/sudoers.d"]="0:0:750"
  ["/etc/polkit-1/rules.d"]="0:0:750"
)
