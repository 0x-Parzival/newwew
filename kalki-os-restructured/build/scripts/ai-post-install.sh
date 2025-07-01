#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display section headers
section() {
    echo -e "\n${YELLOW}==> ${1}${NC}"
}

# Function to display success messages
success() {
    echo -e "${GREEN}[✓] ${1}${NC}"
}

# Function to display error messages
error() {
    echo -e "${RED}[✗] ${1}${NC}" >&2
    exit 1
}

# Start post-installation process
section "Starting AI Component Installation"

# Install Python packages
section "Installing Python packages..."
pip install --upgrade pip
pip install --no-cache-dir \
    torch torchvision torchaudio \
    numpy scipy opencv-python \
    mediapipe \
    SpeechRecognition \
    pyttsx3 \
    openai-whisper \
    aiohttp \
    websockets \
    transformers \
    rich \
    prompt_toolkit

# Verify installations
section "Verifying installations..."
if ! python3 -c "import torch, numpy, cv2, mediapipe, speech_recognition, pyttsx3, whisper, aiohttp, websockets, transformers, rich, prompt_toolkit; print('All required packages are installed')"; then
    error "Failed to verify all Python packages"
fi

# Create necessary directories
section "Creating system directories..."
sudo mkdir -p /etc/kalki/ai-models
sudo mkdir -p /var/log/kalki
sudo chown -R $USER:$USER /etc/kalki /var/log/kalki

# Create systemd service for AI components
section "Setting up systemd services..."
cat << EOF | sudo tee /etc/systemd/system/kalki-ai.service > /dev/null
[Unit]
Description=Kalki AI Services
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/opt/kalki
ExecStart=/usr/bin/python3 -m krix.omnet.omnet_core
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable kalki-ai

# Create desktop entry for Krix-Term
section "Creating desktop entry..."
cat << EOF | sudo tee /usr/share/applications/krix-term.desktop > /dev/null
[Desktop Entry]
Name=Krix Terminal
Comment=AI-Powered Terminal
Exec=krix-term
Icon=terminal
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
EOF

# Set permissions
sudo chmod +x /usr/local/bin/krix-term

success "AI component installation completed!"
echo -e "\n${YELLOW}Next steps:\n1. Reboot your system\n2. Run 'krix-term' to start the AI terminal\n${NC}"
