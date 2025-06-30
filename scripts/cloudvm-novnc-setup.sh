#!/bin/bash
set -euo pipefail

# Kalki OS Cloud VM Web VNC Setup Script - Fully Automated
# For Oracle Cloud Free Tier (or any Ubuntu/Debian/Oracle Linux VM)
# Installs XFCE, TigerVNC, and noVNC for browser-based desktop access

# 0. Ensure running as root or use sudo
if [ "$(id -u)" -ne 0 ]; then
  SUDO=sudo
else
  SUDO=""
fi

# 1. Update and install desktop + VNC
$SUDO apt update
$SUDO apt install -y xfce4 xfce4-goodies tigervnc-standalone-server git python3-websockify

# 2. Set VNC password (use env var or default)
VNC_PASS="${VNC_PASS:-kalkios}"
echo -e "$VNC_PASS\n$VNC_PASS\n" | vncpasswd

# 3. Start VNC server (display :1)
vncserver -kill :1 2>/dev/null || true
vncserver :1

# 4. Install and start noVNC
if [ ! -d "$HOME/noVNC" ]; then
  git clone https://github.com/novnc/noVNC.git $HOME/noVNC
fi
cd $HOME/noVNC
nohup ./utils/novnc_proxy --vnc localhost:5901 --listen 6080 &

# 5. Open firewall ports automatically (if ufw present)
if $SUDO which ufw &>/dev/null; then
  $SUDO ufw allow 5901/tcp || true
  $SUDO ufw allow 6080/tcp || true
fi

# 6. Set up systemd user services for auto-start on boot
mkdir -p $HOME/.config/systemd/user
cat > $HOME/.config/systemd/user/vncserver.service <<EOF
[Unit]
Description=TigerVNC Server

[Service]
Type=forking
ExecStart=/usr/bin/vncserver :1
ExecStop=/usr/bin/vncserver -kill :1

[Install]
WantedBy=default.target
EOF

cat > $HOME/.config/systemd/user/novnc.service <<EOF
[Unit]
Description=noVNC Proxy
After=vncserver.service

[Service]
Type=simple
ExecStart=$HOME/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now vncserver.service novnc.service

# 7. Print final access info
IP=$(curl -s ifconfig.me || hostname -I | awk '{print $1}')
echo "\n--- Kalki OS Web VNC Setup Complete ---"
echo "Access your desktop at: http://$IP:6080"
echo "Login with VNC password: $VNC_PASS"
echo "(You can change the password by running vncpasswd)"
echo "To restart: systemctl --user restart vncserver.service novnc.service"
echo "(Firewall ports 5901 and 6080 are open if ufw is present)"
echo "(Optional) Install your AI agent and avatars as per your Kalki OS setup." 