#!/bin/bash

# Find the latest ISO file
ISO_FILE=$(find out -name "kalki-*.iso" -type f | head -1)

if [[ ! -f "$ISO_FILE" ]]; then
    echo "❌ No enhanced Kalki OS ISO found for testing"
    echo "   Please run ./build-kalki-enhanced.sh first"
    exit 1
fi

echo "🧪 Testing Enhanced Kalki OS in QEMU..."
echo "🔍 Validation checklist:"
echo "   □ Plymouth boot animation with OM chanting"
echo "   □ Auto-login to Hyprland desktop"
echo "   □ Glass Dharma UI theme active"
echo "   □ Krix-Term launches and responds"
echo "   □ Avatar system accessible"
echo "   □ Network connectivity functional"
echo ""
echo "🚀 Starting QEMU with hardware acceleration..."
echo "   Press Ctrl+Alt+G to release mouse from VM"
echo "   Press Ctrl+Alt+2 then type 'quit' to exit QEMU"
echo ""

# Launch QEMU with enhanced hardware emulation
qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -m 8G \
    -smp 4 \
    -device virtio-vga-gl \
    -display gtk,gl=on \
    -device intel-hda \
    -device hda-duplex \
    -usb \
    -device usb-tablet \
    -netdev user,id=net0 \
    -device virtio-net,netdev=net0 \
    -cdrom "$ISO_FILE" \
    -name "Enhanced Kalki OS - Phase 2 Testing" \
    -boot d
