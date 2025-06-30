#!/bin/bash
set -euo pipefail

echo "🕉️ Building Kalki OS Minimal Auto-Install ISO..."

PROFILE="distro/profiles/kalki-minimal-auto"
WORK_DIR="work-minimal"
OUT_DIR="out"

# Clean previous builds
sudo rm -rf "$WORK_DIR" "$OUT_DIR"
mkdir -p "$OUT_DIR"

# Build ISO
sudo mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$PROFILE"

if [[ $? -eq 0 ]]; then
    ISO_FILE=$(find "$OUT_DIR" -name "*.iso" -type f | head -1)
    ISO_SIZE=$(du -h "$ISO_FILE" | cut -f1)
    
    echo "✅ Kalki OS Minimal Auto-Install ISO completed"
    echo "📦 ISO: $ISO_FILE ($ISO_SIZE)"
    echo "🚀 Ready for VM testing!"
else
    echo "❌ Build failed"
    exit 1
fi
