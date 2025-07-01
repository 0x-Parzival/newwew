#!/bin/bash

ISO_FILE=$(find out -name "kalki-*.iso" -type f | head -1)

if [[ ! -f "$ISO_FILE" ]]; then
    echo "❌ No AI-integrated Kalki OS ISO found for testing"
    exit 1
fi

echo "🧪 Testing AI-Integrated Kalki OS..."
echo ""
echo "🔍 AI Integration Validation Checklist:"
echo "   □ OMNet neural core starts automatically"
echo "   □ Krix-Term connects to OMNet via WebSocket"
echo "   □ Avatar switching works correctly"
echo "   □ AI conversation responses are contextual"
echo "   □ Voice recognition activates with wake words"
echo "   □ Gesture recognition detects hand movements"
echo "   □ System status shows all AI components active"
echo ""

# Launch QEMU with enhanced specs for AI processing
echo "🚀 Starting QEMU with optimized settings for AI processing..."
echo "   ISO: $ISO_FILE"
echo "   Memory: 8GB | vCPUs: 6 | GPU: virtio-vga-gl"
echo ""
echo "Note: Make sure KVM is enabled and you have sufficient system resources."
echo ""

qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -m 8G \
    -smp 6 \
    -device virtio-vga-gl \
    -display gtk,gl=on \
    -device intel-hda \
    -device hda-duplex \
    -usb \
    -device usb-tablet \
    -netdev user,id=net0 \
    -device virtio-net,netdev=net0 \
    -cdrom "$ISO_FILE" \
    -name "AI-Integrated Kalki OS - Phase 3 Testing"
