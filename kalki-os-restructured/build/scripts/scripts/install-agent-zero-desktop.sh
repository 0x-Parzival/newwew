#!/bin/bash
# Automate Agent Zero desktop integration for Kalki OS
set -euo pipefail

ICON_SRC="$(dirname "$0")/kalki-agent-zero.png"
ICON_DEST="/usr/share/icons/hicolor/128x128/apps/kalki-agent-zero.png"
DESKTOP_SRC="$(dirname "$0")/agent-zero.desktop"
DESKTOP_DEST="/usr/share/applications/agent-zero.desktop"

# Copy icon
if [ -f "$ICON_SRC" ]; then
  sudo install -Dm644 "$ICON_SRC" "$ICON_DEST"
else
  echo "[WARN] Icon not found at $ICON_SRC. Using default system icon."
fi

# Copy .desktop file
sudo install -Dm644 "$DESKTOP_SRC" "$DESKTOP_DEST"

# Update icon cache (if available)
if command -v gtk-update-icon-cache &>/dev/null; then
  sudo gtk-update-icon-cache -f /usr/share/icons/hicolor
fi

echo "[OK] Agent Zero desktop integration complete!"
echo "You can now launch Agent Zero from your application menu." 