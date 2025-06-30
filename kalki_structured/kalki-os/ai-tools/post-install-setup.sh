# Add Avatar Control Panel shortcut to Desktop
USER_DESKTOP="/home/${AI_USER}/Desktop"
mkdir -p "$USER_DESKTOP"
cp /opt/kalki/scripts/avatar-control-panel.desktop "$USER_DESKTOP/"
chmod +x "$USER_DESKTOP/avatar-control-panel.desktop"
chown ${AI_USER}:${AI_USER} "$USER_DESKTOP/avatar-control-panel.desktop" 