#!/bin/bash
# Kalki OS VM Launch Script
#
# Usage:
#   ./test-kalki-vm.sh [--iso /path/to/kalki.iso] [--ram 8G] [--cpus 4] [--skip-validations] [--help]
#
# Flags:
#   --iso PATH           Path to the Kalki OS ISO (default: latest in out/)
#   --ram SIZE           RAM for VM (default: 8G)
#   --cpus N             Number of CPU cores (default: 4)
#   --skip-validations   Skip hardware and dependency checks (warn only)
#   --help               Show this help message

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Defaults
ISO_PATH=""
RAM="8G"
CPUS=4
SKIP_VALIDATIONS=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --iso)
      ISO_PATH="$2"; shift 2;;
    --ram)
      RAM="$2"; shift 2;;
    --cpus)
      CPUS="$2"; shift 2;;
    --skip-validations)
      SKIP_VALIDATIONS=true; shift;;
    --help|-h)
      echo -e "\nKalki OS VM Launch Script\n\nUsage: $0 [--iso /path/to/kalki.iso] [--ram 8G] [--cpus 4] [--skip-validations] [--help]\n"
      exit 0;;
    *)
      echo -e "${RED}[ERROR] Unknown argument: $1${NC}"; exit 1;;
  esac
done

# Path resolution
resolve_path() {
  if command -v realpath >/dev/null 2>&1; then
    realpath "$1"
  elif command -v readlink >/dev/null 2>&1; then
    readlink -f "$1"
  else
    # Portable fallback: works in all POSIX shells
    dir=$(dirname -- "$1")
    base=$(basename -- "$1")
    echo "$(cd "$dir" 2>/dev/null && pwd)/$base"
  fi
}
echo "[DEBUG] Running shell: $SHELL"
SCRIPT_PATH="$(resolve_path "$0")"
PROJECT_ROOT="$(dirname "$SCRIPT_PATH")"
OUT_DIR="$PROJECT_ROOT/out"

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

# Function to display warning messages
warn() {
    echo -e "${YELLOW}[!] ${1}${NC}" >&2
}

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    error "This script should not be run as root. Please run as a regular user."
fi

# Find ISO if not specified
if [ -z "$ISO_PATH" ]; then
  ISO_PATH=$(find "$OUT_DIR" -name "kalki-*.iso" -type f | sort -r | head -n 1)
  if [ -z "$ISO_PATH" ]; then
    error "No ISO file found in $OUT_DIR. Please build the ISO first or specify with --iso."
  fi
fi
ISO_PATH="$(resolve_path "$ISO_PATH")"
echo "Using ISO: $ISO_PATH"

# Check for KVM support
KVM_ENABLED=true
if grep -q -E '(vmx|svm)' /proc/cpuinfo; then
  if ! lsmod | grep -q kvm; then
    warn "KVM module not loaded. Attempting to load..."
    if ! sudo modprobe kvm; then
      warn "Failed to load KVM module. Falling back to TCG."
      KVM_ENABLED=false
    fi
  fi
else
  warn "CPU does not support hardware virtualization (VT-x/AMD-V). Falling back to TCG."
  KVM_ENABLED=false
fi

# Set QEMU accelerator
if [ "$KVM_ENABLED" = true ]; then
  ACCEL="kvm"
else
  ACCEL="tcg"
fi

# Check for required packages (Arch Linux)
REQUIRED_PKGS=(qemu-full qemu-guest-agent libvirt virt-manager ebtables dnsmasq bridge-utils virt-viewer spice-vdagent)
MISSING_PKGS=()
for pkg in "${REQUIRED_PKGS[@]}"; do
  if ! pacman -Qi "$pkg" &> /dev/null; then
    MISSING_PKGS+=("$pkg")
  fi
done
if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
  if [ "$SKIP_VALIDATIONS" = true ]; then
    warn "Missing packages: ${MISSING_PKGS[*]}. VM may not work correctly."
  else
    echo "The following packages are required but not installed:"
    printf ' - %s\n' "${MISSING_PKGS[@]}"
    read -p "Do you want to install them now? [y/N] " -n 1 -r; echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      sudo pacman -S --noconfirm "${MISSING_PKGS[@]}"
      if [ $? -ne 0 ]; then error "Failed to install required packages"; fi
      sudo systemctl enable --now libvirtd
      sudo usermod -aG libvirt "$USER"
      echo "Please log out and back in for group changes to take effect."
      read -p "Continue with VM launch? [y/N] " -n 1 -r; echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then exit 0; fi
    else
      error "Cannot continue without required packages. Use --skip-validations to override."
    fi
  fi
fi

# Check libvirtd status and group
if ! systemctl is-active --quiet libvirtd; then
  if [ "$SKIP_VALIDATIONS" = true ]; then
    warn "libvirtd is not running. VM networking may not work."
  else
    error "libvirtd is not running. Start it with: sudo systemctl start libvirtd"
  fi
fi
if ! groups "$USER" | grep -q libvirt; then
  if [ "$SKIP_VALIDATIONS" = true ]; then
    warn "User $USER is not in libvirt group. VM management may be limited."
  else
    error "User $USER is not in libvirt group. Add with: sudo usermod -aG libvirt $USER && log out/in."
  fi
fi

# Create disk image if it doesn't exist
DISK_IMG="/tmp/kalki-vm-disk.img"
if [ ! -f "$DISK_IMG" ]; then
  section "Creating virtual disk..."
  qemu-img create -f qcow2 "$DISK_IMG" 40G
  if [ $? -ne 0 ]; then error "Failed to create virtual disk"; fi
fi

# Configure QEMU parameters
QEMU_CMD=(
    qemu-system-x86_64
    -name "Kalki OS VM"
    -m "$RAM"
    -smp "$CPUS"
    -machine type=q35,accel=$ACCEL
    -cpu host
    -device virtio-vga-gl
    -display sdl,gl=on
    -device virtio-net,netdev=net0
    -netdev user,id=net0,hostfwd=tcp::2222-:22
    -drive file="$ISO_PATH",media=cdrom
    -boot d
    -rtc base=utc
    -vga virtio
    -usb
    -device usb-tablet
    -device virtio-scsi-pci,id=scsi
    -device scsi-hd,drive=hd0
    -drive if=none,id=hd0,file="$DISK_IMG",format=qcow2,size=40G
)

# Start the VM
section "Starting Kalki OS VM..."
echo "Command: ${QEMU_CMD[*]}"
echo "To connect via SSH: ssh -p 2222 kalki@localhost"

exec "${QEMU_CMD[@]}"
