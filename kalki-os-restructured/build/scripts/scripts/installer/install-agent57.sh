#!/bin/bash

set -e

echo "🧠 Installing Kalki OS Agent57 System..."

# Install Python dependencies
pip install torch numpy gymnasium stable-baselines3

# Create Agent57 directories
mkdir -p /opt/kalki/agent57/{models,memory,logs,config}

# Install Agent57 components
cp -r src/ai-system/agent57/* /opt/kalki/agent57/

# Create systemd service
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
systemctl enable kalki-agent57.service
systemctl start kalki-agent57.service

echo "✅ Agent57 installed and running" 