#!/bin/bash
# Avatars Overlay Install Script
# Installs and configures the 12-avatar system

set -e

KALKI_ROOT="/opt/kalki"

echo "👥 Installing Avatars Overlay..."

# Create avatar directories
mkdir -p "$KALKI_ROOT/avatars" "$KALKI_ROOT/configs/avatars"

# Copy avatar components
if [[ -d "$KALKI_ROOT/src/avatar-system" ]]; then
    cp -r "$KALKI_ROOT/src/avatar-system"/* "$KALKI_ROOT/avatars/"
    echo "✅ Avatar system components copied"
else
    echo "⚠️ Avatar system source not found"
fi

# Copy avatar configs
if [[ -d "$KALKI_ROOT/configs/ai" ]]; then
    cp "$KALKI_ROOT/configs/ai/avatar-personalities.json" "$KALKI_ROOT/configs/avatars/" 2>/dev/null || true
    echo "✅ Avatar configs copied"
fi

# Create systemd service for avatar manager
cat > /etc/systemd/system/kalki-avatar-manager.service << 'EOF'
[Unit]
Description=Kalki OS Avatar Manager
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /opt/kalki/avatars/core/avatar-engine.py
Restart=always
RestartSec=10
User=kalki
Group=kalki

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable kalki-avatar-manager.service
systemctl start kalki-avatar-manager.service

echo "✅ Avatars overlay installed and running" 