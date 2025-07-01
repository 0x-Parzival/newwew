#!/bin/bash
# test-kalki-vm.sh: Automated VM testing for Kalki OS ISO
set -euo pipefail

ISO_PATH="${1:-./out/$(ls -1t ./out/*.iso 2>/dev/null | head -n 1)}"

if [[ ! -f "$ISO_PATH" ]]; then
  echo "Error: ISO not found at $ISO_PATH"
  exit 1
fi

# QEMU options (customize as needed)
RAM=4096
CPUS=2
SHAREDFOLDER="$(pwd)/shared"

mkdir -p "$SHAREDFOLDER"

# Boot the ISO in QEMU
qemu-system-x86_64 \
  -m $RAM \
  -smp $CPUS \
  -cdrom "$ISO_PATH" \
  -boot d \
  -enable-kvm \
  -vga virtio \
  -net nic -net user \
  -virtfs local,path="$SHAREDFOLDER",mount_tag=hostshare,security_model=passthrough,id=hostshare \
  -display sdl \
  -no-reboot

# (Optional) Add smoke test automation here
# e.g., use expect or guestfish for automated checks

echo "VM test completed. Review the VM output for results." 