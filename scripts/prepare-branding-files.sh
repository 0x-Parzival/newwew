#!/bin/bash
# prepare-branding-files.sh: Prepare branding and first boot wizard for Kalki OS ISO
set -euo pipefail

# Robust path resolution (symlink-safe)
resolve_path() {
    if command -v realpath >/dev/null 2>&1; then
        realpath "$1"
    elif command -v readlink >/dev/null 2>&1; then
        readlink -f "$1"
    else
        echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
    fi
}
SCRIPT_PATH="$(resolve_path "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
ROOT_DIR="${SCRIPT_DIR}/.."
AIROOTFS_DIR="${ROOT_DIR}/iso-profile/kalki-base/airootfs"
# Dependency check at the start
if [ -f "$SCRIPT_DIR/check-dependencies.sh" ]; then
  bash "$SCRIPT_DIR/check-dependencies.sh" || exit 1
  echo "[prepare-branding-files.sh] Dependency check passed."
else
  echo "[prepare-branding-files.sh] Dependency check script not found!"
  exit 1
fi

# Create necessary directories
mkdir -p "${AIROOTFS_DIR}/usr/share/grub/themes/kalki"
mkdir -p "${AIROOTFS_DIR}/usr/share/plymouth/themes/kalki"
mkdir -p "${AIROOTFS_DIR}/usr/share/backgrounds/kalki"
mkdir -p "${AIROOTFS_DIR}/etc/skel/.config/autostart"

# Remove old CLI wizard entry if present
rm -f "${AIROOTFS_DIR}/etc/skel/.config/autostart/kalki-first-run.desktop"

# Create a desktop entry for the GUI first boot wizard
cat > "${AIROOTFS_DIR}/etc/skel/.config/autostart/kalki-first-boot-wizard.desktop" << 'EOF'
[Desktop Entry]
Type=Application
Name=Kalki OS First Boot Wizard
Exec=python3 /usr/local/bin/first-boot-wizard-gui.py
X-GNOME-Autostart-enabled=true
EOF

# Copy the GUI wizard script to the right place
install -Dm755 "${ROOT_DIR}/scripts/first-boot-wizard-gui.py" "${AIROOTFS_DIR}/usr/local/bin/first-boot-wizard-gui.py"

# (Optional) Copy branding scripts/assets as needed

echo "Branding files and GUI first boot wizard preparation complete!" 