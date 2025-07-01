#!/bin/bash
# AI Core Overlay Install Script
# Installs and configures the Agent57 AI system

set -e

KALKI_ROOT="/opt/kalki"

echo "🧠 Installing AI Core Overlay..."

# Create AI directories
mkdir -p "$KALKI_ROOT/agent57/{models,memory,logs,config}"

# Copy Agent57 components
if [[ -d "$KALKI_ROOT/src/ai-system/agent57" ]]; then
    cp -r "$KALKI_ROOT/src/ai-system/agent57"/* "$KALKI_ROOT/agent57/"
    echo "✅ Agent57 components copied"
else
    echo "⚠️ Agent57 source not found"
fi

# Create systemd service for Agent57
cat > /etc/systemd/system/kalki-agent57.service << 'EOF'
[Unit]
Description=Kalki OS Agent57 Multi-task Intelligence
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /opt/kalki/agent57/main.py
Restart=always
RestartSec=10
User=kalki
Group=kalki

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable kalki-agent57.service
systemctl start kalki-agent57.service

echo "✅ AI Core overlay installed and running" 