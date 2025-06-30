#!/bin/bash
# check-hardware.sh: Hardware compatibility check for Kalki OS
set -euo pipefail

REQUIRED_MODULES=(overlay loop squashfs)
fail=0

# Check UEFI/BIOS
if [ -d /sys/firmware/efi ]; then
  echo "[OK] UEFI firmware detected."
else
  echo "[WARN] UEFI not detected. System may be using legacy BIOS."
fi

# Check kernel modules
for mod in "${REQUIRED_MODULES[@]}"; do
  if ! lsmod | grep -q "^$mod"; then
    echo "[ERROR] Required kernel module '$mod' is not loaded."
    fail=1
  else
    echo "[OK] Kernel module '$mod' loaded."
  fi
done

# Hardware summary
echo "[INFO] CPU: $(lscpu | grep 'Model name' | awk -F: '{print $2}' | xargs)"
echo "[INFO] RAM: $(free -h | awk '/Mem:/ {print $2}')"
echo "[INFO] Disk: $(lsblk -d -o NAME,SIZE,TYPE | grep disk)"

if (( fail )); then
  echo "[ERROR] Hardware compatibility check failed. Fix above issues."
  exit 1
else
  echo "[OK] Hardware compatibility check passed."
fi 