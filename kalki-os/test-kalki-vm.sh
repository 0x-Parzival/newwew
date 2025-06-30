#!/bin/bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display section headers
section() {
    echo -e "\n${YELLOW}==> ${1}${NC}"
}

# Function to display success messages
success() {
    echo -e "${GREEN}[✓] ${1}${NC}"
}

# Function to display error messages
error() {
    echo -e "${RED}[✗] ${1}${NC}" >&2
    exit 1
}

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    error "This script should not be run as root. Please run as a regular user."
fi

# Check for KVM support
section "Checking KVM support..."
if ! grep -q -E '(vmx|svm)' /proc/cpuinfo; then
    echo "Warning: CPU does not support hardware virtualization (VT-x/AMD-V)"
    KVM_ENABLED=false
else
    if ! lsmod | grep -q kvm; then
        echo "KVM module not loaded. Attempting to load..."
        sudo modprobe kvm
        if [ $? -ne 0 ]; then
            echo "Failed to load KVM module. Falling back to TCG."
            KVM_ENABLED=false
        else
            KVM_ENABLED=true
        fi
    else
        KVM_ENABLED=true
    fi
fi

# Find the latest ISO file
ISO_FILE=$(find /home/xero/os/kalki-os/iso-profile/kalki-base/out -name "kalki-*.iso" -type f | sort -r | head -n 1)

if [ -z "$ISO_FILE" ]; then
    error "No ISO file found. Please build the ISO first."
fi

echo "Found ISO: $ISO_FILE"

# Configure QEMU parameters
QEMU_CMD=(
    qemu-system-x86_64
    -name "Kalki OS VM"
    -m 8G
    -smp 4
    -enable-kvm
    -cpu host
    -machine type=q35,accel=kvm
    -device virtio-vga-gl
    -display sdl,gl=on
    -device virtio-net,netdev=net0
    -netdev user,id=net0,hostfwd=tcp::2222-:22
    -drive file="$ISO_FILE",media=cdrom
    -boot d
    -rtc base=utc
    -vga virtio
    -usb
    -device usb-tablet
    -device virtio-scsi-pci,id=scsi
    -device scsi-hd,drive=hd0
    -drive if=none,id=hd0,file=/tmp/kalki-vm-disk.img,format=qcow2,size=40G
)

# Add KVM acceleration if available
if [ "$KVM_ENABLED" = true ]; then
    QEMU_CMD+=(-enable-kvm -cpu host)
    echo "Using KVM acceleration"
else
    QEMU_CMD+=(-accel tcg,tb-size=256)
    echo "Using TCG emulation (slower)"
fi

# Create disk image if it doesn't exist
if [ ! -f "/tmp/kalki-vm-disk.img" ]; then
    section "Creating virtual disk..."
    qemu-img create -f qcow2 /tmp/kalki-vm-disk.img 40G
    if [ $? -ne 0 ]; then
        error "Failed to create virtual disk"
    fi
fi

# Check for required packages
section "Checking for required packages..."
REQUIRED_PKGS=(
    qemu-full
    qemu-guest-agent
    libvirt
    virt-manager
    ebtables
    dnsmasq
    bridge-utils
    virt-viewer
    spice-vdagent
)

MISSING_PKGS=()
for pkg in "${REQUIRED_PKGS[@]}"; do
    if ! pacman -Qi "$pkg" &> /dev/null; then
        MISSING_PKGS+=("$pkg")
    fi
done

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo "The following packages are required but not installed:"
    printf ' - %s\n' "${MISSING_PKGS[@]}"
    
    read -p "Do you want to install them now? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo pacman -S --noconfirm "${MISSING_PKGS[@]}"
        if [ $? -ne 0 ]; then
            error "Failed to install required packages"
        fi
        
        # Enable and start libvirtd
        sudo systemctl enable --now libvirtd
        sudo usermod -aG libvirt "$USER"
        
        echo "Please log out and back in for group changes to take effect."
        read -p "Continue with VM launch? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
fi

# Start the VM
section "Starting Kalki OS VM..."
echo "Command: ${QEMU_CMD[*]}"
echo "To connect via SSH: ssh -p 2222 kalki@localhost"

exec "${QEMU_CMD[@]}"
