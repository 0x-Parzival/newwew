#!/bin/bash
# Kalki OS Wrapper Build Script
# Builds Kalki OS as an ArchISO wrapper with overlays

set -e

WORK_DIR="/tmp/kalki-build"
ARCH_PROFILE="$WORK_DIR/archiso-profile"
OUTPUT_DIR="out"
KALKI_ROOT="$(dirname "$0")"

cleanup() {
    echo "🧹 Cleaning up..."
    sudo rm -rf "$WORK_DIR" 2>/dev/null || true
}

trap cleanup EXIT

prepare_archiso_base() {
    echo "📦 Preparing ArchISO base..."
    
    # Clone/update ArchISO if needed
    if [[ ! -d "$ARCH_PROFILE" ]]; then
        echo "📥 Downloading latest ArchISO..."
        git clone https://gitlab.archlinux.org/archlinux/archiso.git temp-archiso
        cp -r temp-archiso/configs/releng "$ARCH_PROFILE"
        rm -rf temp-archiso
    fi
}

apply_kalki_wrapper() {
    echo "🎨 Applying Kalki wrapper layer..."
    
    # Add Kalki packages to ArchISO
    cat >> "$ARCH_PROFILE/packages.x86_64" << 'EOF'
# Kalki OS packages
python-pip
python-torch
python-numpy
python-gymnasium
stable-baselines3
hyprland
waybar
wofi
EOF
    
    # Create Kalki initialization service
    mkdir -p "$ARCH_PROFILE/airootfs/etc/systemd/system"
    cat > "$ARCH_PROFILE/airootfs/etc/systemd/system/kalki-wrapper.service" << 'EOF'
[Unit]
Description=Kalki OS Wrapper Initialization
After=network.target

[Service]
Type=oneshot
ExecStart=/opt/kalki/wrapper/kalki-layer/init.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    
    # Enable Kalki wrapper service
    mkdir -p "$ARCH_PROFILE/airootfs/etc/systemd/system/multi-user.target.wants"
    ln -sf /etc/systemd/system/kalki-wrapper.service \
        "$ARCH_PROFILE/airootfs/etc/systemd/system/multi-user.target.wants/"
    
    # Copy Kalki files to ISO
    mkdir -p "$ARCH_PROFILE/airootfs/opt/kalki"
    cp -r "$KALKI_ROOT/src" "$ARCH_PROFILE/airootfs/opt/kalki/"
    cp -r "$KALKI_ROOT/configs" "$ARCH_PROFILE/airootfs/opt/kalki/"
    cp -r "$KALKI_ROOT/wrapper" "$ARCH_PROFILE/airootfs/opt/kalki/"
    cp -r "$KALKI_ROOT/scripts" "$ARCH_PROFILE/airootfs/opt/kalki/"
    
    # Make scripts executable
    chmod +x "$ARCH_PROFILE/airootfs/opt/kalki/wrapper/kalki-layer/init.sh"
    chmod +x "$ARCH_PROFILE/airootfs/opt/kalki/wrapper/overlays/"*/install.sh
}

build_iso() {
    echo "🔨 Building Kalki OS ISO..."
    
    mkdir -p "$OUTPUT_DIR"
    
    # Build using archiso
    sudo archiso -v -w "$WORK_DIR" -o "$OUTPUT_DIR" "$ARCH_PROFILE"
    
    echo "✅ ISO built successfully in $OUTPUT_DIR/"
}

main() {
    echo "🚀 Building Kalki OS Wrapper..."
    
    prepare_archiso_base
    apply_kalki_wrapper
    build_iso
    
    echo "🎉 Kalki OS Wrapper build complete!"
}

main "$@" 