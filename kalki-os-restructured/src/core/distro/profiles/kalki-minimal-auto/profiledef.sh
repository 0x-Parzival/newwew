#!/usr/bin/env bash
iso_name="kalki-minimal-auto"
iso_label="KALKI_AUTO_$(date +%Y%m)"
iso_publisher="Krix Collective"
iso_application="Kalki OS - Auto-Installing Minimal Edition"
install_dir="arch"
bootmodes=('bios.syslinux.mbr' 'uefi-x64.systemd-boot.esp')
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15')