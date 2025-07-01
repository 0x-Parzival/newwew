#!/bin/bash

echo "🚀 Testing Kalki OS Minimal Auto-Install in VM..."

# Find the latest ISO in the out directory
ISO_FILE=$(find ../out -name "*.iso" -type f | head -1)

if [[ ! -f "$ISO_FILE" ]]; then
    echo "❌ No ISO found. Run ./build/build-minimal-auto.sh first"
    exit 1
fi

echo "📀 Using ISO: $ISO_FILE"

# Create VM disk if it doesn't exist
if [[ ! -f "kalki-test.qcow2" ]]; then
    echo "💾 Creating new VM disk..."
    qemu-img create -f qcow2 kalki-test.qcow2 20G
fi

# Launch VM with auto-install ISO
echo "🚀 Starting QEMU VM..."
qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -m 4G \
    -smp 2 \
    -cdrom "$ISO_FILE" \
    -drive file=kalki-test.qcow2,format=qcow2 \
    -boot d \
    -vga virtio \
    -display gtk,gl=on \
    -netdev user,id=net0 \
    -device virtio-net-pci,netdev=net0

echo "✅ VM launched. Follow AI installer prompts!"
