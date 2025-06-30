#!/bin/bash
set -euo pipefail

# Kalki OS - Make Ventoy USB Script
# This script helps you create a Ventoy USB drive from the live ISO

VENTOY_VERSION="1.0.99" # Update as needed
VENTOY_URL="https://github.com/ventoy/Ventoy/releases/download/v${VENTOY_VERSION}/ventoy-${VENTOY_VERSION}-linux.tar.gz"
VENTOY_DIR="/opt/ventoy"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
  echo -e "${RED}Please run as root (sudo).${NC}"
  exit 1
fi

# Download or use bundled Ventoy
if [ ! -d "$VENTOY_DIR" ]; then
  echo -e "${YELLOW}Downloading Ventoy...${NC}"
  mkdir -p /opt
  wget -O /tmp/ventoy.tar.gz "$VENTOY_URL"
  tar -xzf /tmp/ventoy.tar.gz -C /opt
  mv /opt/ventoy-${VENTOY_VERSION} "$VENTOY_DIR"
fi

# List available USB drives
echo -e "${YELLOW}Available USB drives:${NC}"
lsblk -d -o NAME,SIZE,MODEL,TRAN | grep usb || echo "(No USB drives detected)"
echo
read -rp "Enter the device name for your USB drive (e.g., sdb): " USB_DEV
USB_PATH="/dev/$USB_DEV"

if [ ! -b "$USB_PATH" ]; then
  echo -e "${RED}Device $USB_PATH not found.${NC}"
  exit 1
fi

# Confirm with user
echo -e "${RED}WARNING: This will erase all data on $USB_PATH!${NC}"
read -rp "Are you sure you want to install Ventoy to $USB_PATH? (y/N): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

# Install Ventoy
cd "$VENTOY_DIR"
./Ventoy2Disk.sh -i "$USB_PATH"

# Optionally copy ISOs
read -rp "Do you want to copy ISOs to the USB now? (y/N): " COPY_ISO
if [[ "$COPY_ISO" =~ ^[Yy]$ ]]; then
  mount | grep "/dev/$USB_DEV" || sudo mount "/dev/${USB_DEV}1" /mnt
  echo -e "${YELLOW}Copying ISOs...${NC}"
  ls /mnt/hostshare/*.iso 2>/dev/null || echo "No ISOs found in /mnt/hostshare."
  read -rp "Enter the path to the ISO(s) to copy (space-separated): " ISO_PATHS
  cp $ISO_PATHS /mnt/
  sync
  umount /mnt
fi

echo -e "${GREEN}Ventoy USB is ready! Boot from it to use the Ventoy menu.${NC}" 