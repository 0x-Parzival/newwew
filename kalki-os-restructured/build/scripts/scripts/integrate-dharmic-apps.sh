#!/bin/bash
# integrate-dharmic-apps.sh: Ensure all dharmic app folders and user data directories exist

APPS=(bunniwrite designdeva roostytime appmantra)
APP_ROOT="/opt/kalki/apps"
USER_DATA="$HOME/.kalki/apps"

for app in "${APPS[@]}"; do
  sudo mkdir -p "$APP_ROOT/$app"
  mkdir -p "$USER_DATA/$app"
done

echo "[integrate-dharmic-apps.sh] All app folders and user data directories ensured." 