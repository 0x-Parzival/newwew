#!/bin/bash

# Dharma OS - Ollama Installer
# This script installs and configures Ollama for local LLM inference

# Exit on error
set -e

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
pacman -S --needed --noconfirm curl wget

# Download and install Ollama
echo "Downloading Ollama..."
curl -fsSL https://ollama.ai/install.sh | sh

# Create systemd service for Ollama
echo "Creating Ollama systemd service..."
cat > /etc/systemd/system/ollama.service << 'EOF'
[Unit]
Description=Ollama Service
After=network-online.target

[Service]
User=kalki
Group=kalki
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/bin"
ExecStart=/usr/local/bin/ollama serve
Restart=always
RestartSec=3
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_ORIGINS=*"
Environment="HOME=/home/kalki"

[Install]
WantedBy=multi-user.target
EOF

# Create Ollama models directory
mkdir -p /home/kalki/.ollama
chown -R kalki:kalki /home/kalki/.ollama

# Enable and start Ollama service
systemctl daemon-reload
systemctl enable ollama
systemctl start ollama

# Create a script to download models
cat > /usr/local/bin/download-ollama-models << 'EOF'
#!/bin/bash

# Dharma OS - Ollama Model Downloader
# This script downloads pre-configured Ollama models

MODELS=(
    "llama3"
    "mistral"
    "phi3"
)

echo "Downloading Ollama models..."
for model in "${MODELS[@]}"; do
    echo "Downloading $model..."
    sudo -u kalki ollama pull $model
    echo "$model downloaded successfully!"
done

echo "All models downloaded!"
EOF

# Make the script executable
chmod +x /usr/local/bin/download-ollama-models

# Create a script to manage Ollama service
cat > /usr/local/bin/ollama-ctl << 'EOF'
#!/bin/bash

# Dharma OS - Ollama Service Control
# Simple wrapper for managing the Ollama service

case "$1" in
    start)
        systemctl start ollama
        ;;
    stop)
        systemctl stop ollama
        ;;
    restart)
        systemctl restart ollama
        ;;
    status)
        systemctl status ollama
        ;;
    logs)
        journalctl -u ollama -f
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs}"
        exit 1
        ;;
esac
EOF

# Make the control script executable
chmod +x /usr/local/bin/ollama-ctl

echo "Ollama installation complete!"
echo "To download models, run: download-ollama-models"
echo "To manage the Ollama service: ollama-ctl {start|stop|restart|status|logs}"
