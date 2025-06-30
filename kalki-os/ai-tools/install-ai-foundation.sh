#!/bin/bash

# Dharma OS - AI Foundation Installer
# This script sets up the AI infrastructure for Dharma OS

# Exit on error and print commands
set -e
set -x

# Configuration
AI_USER="kalki"
AI_HOME="/home/${AI_USER}"
AI_DIR="${AI_HOME}/ai"
VENV_DIR="${AI_HOME}/ai-venv"
MODEL_DIR="${AI_HOME}/ai-models"
LOG_DIR="/var/log/krix-ai"
CONFIG_DIR="/etc/krix-ai"

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Create necessary directories
echo "Creating directories..."
mkdir -p "${AI_DIR}" "${MODEL_DIR}" "${LOG_DIR}" "${CONFIG_DIR}"
chown -R ${AI_USER}:${AI_USER} "${AI_DIR}" "${MODEL_DIR}" "${LOG_DIR}" "${CONFIG_DIR}"
chmod 755 "${AI_DIR}" "${LOG_DIR}" "${CONFIG_DIR}"
chmod 700 "${MODEL_DIR}"

# Install system dependencies
echo "Installing system dependencies..."
./install-ai-dependencies.sh

# Install Ollama
echo "Installing Ollama..."
./install-ollama.sh

# Set up Python virtual environment
echo "Setting up Python virtual environment..."
sudo -u ${AI_USER} python3 -m venv "${VENV_DIR}"
sudo -u ${AI_USER} "${VENV_DIR}/bin/pip" install --upgrade pip

# Install Python dependencies
echo "Installing Python dependencies..."
sudo -u ${AI_USER} "${VENV_DIR}/bin/pip" install -r krix-ai/requirements.txt

# Install Krix AI application
echo "Installing Krix AI application..."
cp -r krix-ai/* "${AI_DIR}/"
chown -R ${AI_USER}:${AI_USER} "${AI_DIR}"
chmod +x "${AI_DIR}/main.py"

# Create systemd service for Krix AI
cat > /etc/systemd/system/krix-ai.service << EOF
[Unit]
Description=Krix AI Service
After=network.target ollama.service

[Service]
User=${AI_USER}
Group=${AI_USER}
WorkingDirectory=${AI_DIR}
Environment="PATH=${VENV_DIR}/bin:${PATH}"
Environment="PYTHONPATH=${AI_DIR}"
ExecStart=${VENV_DIR}/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=5

# Security
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=full
ProtectHome=true
ReadWritePaths=${MODEL_DIR} ${LOG_DIR}

[Install]
WantedBy=multi-user.target
EOF

# Create environment file
cat > "${CONFIG_DIR}/krix-ai.env" << EOF
# Krix AI Configuration
MODEL_DIR=${MODEL_DIR}
OLLAMA_HOST=http://localhost:11434
LOG_LEVEL=INFO
API_KEY=$(openssl rand -hex 32)
EOF

# Set permissions
chmod 640 "${CONFIG_DIR}/krix-ai.env"
chown ${AI_USER}:${AI_USER} "${CONFIG_DIR}/krix-ai.env"

# Enable and start services
echo "Enabling services..."
systemctl daemon-reload
systemctl enable krix-ai
systemctl start krix-ai

# Create a script to manage AI services
cat > /usr/local/bin/ai-manager << 'EOF'
#!/bin/bash

# Dharma OS - AI Service Manager
# Unified interface for managing AI services

SERVICES=("krix-ai" "ollama")

show_help() {
    echo "Usage: ai-manager [command] [service]"
    echo ""
    echo "Commands:"
    echo "  start     Start AI services"
    echo "  stop      Stop AI services"
    echo "  restart   Restart AI services"
    echo "  status    Show status of AI services"
    echo "  logs      Show logs for a service"
    echo "  update    Update AI models and services"
    echo "  help      Show this help message"
    echo ""
    echo "Available services: ${SERVICES[*]}"
}

manage_service() {
    local cmd=$1
    local svc=$2
    
    case $cmd in
        start|stop|restart|status)
            systemctl $cmd $svc
            ;;
        logs)
            journalctl -u $svc -f
            ;;
        *)
            echo "Unknown command: $cmd"
            show_help
            exit 1
            ;;
    esac
}

update_models() {
    echo "Updating AI models..."
    sudo -u ${AI_USER} ${AI_HOME}/ai-tools/download-ai-models.sh
    echo "Models updated successfully!"
}

# Main command processing
case "$1" in
    start|stop|restart|status|logs)
        if [ -z "$2" ]; then
            # Apply to all services if none specified
            for svc in "${SERVICES[@]}"; do
                echo "$1 $svc..."
                manage_service "$1" "$svc"
            done
        else
            # Apply to specified service
            if [[ " ${SERVICES[@]} " =~ " $2 " ]]; then
                manage_service "$1" "$2"
            else
                echo "Unknown service: $2"
                show_help
                exit 1
            fi
        fi
        ;;
    update)
        update_models
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
EOF

# Make the manager script executable
chmod +x /usr/local/bin/ai-manager

# Create a script to download models later
echo "Creating model download script..."
cat > "${AI_HOME}/download-ai-models.sh" << 'EOF'
#!/bin/bash
# Script to download AI models post-installation

MODEL_DIR="${HOME}/ai-models"

echo "This script will download AI models. This may take a while and require significant disk space."
read -p "Do you want to continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Model download cancelled."
    exit 0
fi

# Create model directory if it doesn't exist
mkdir -p "${MODEL_DIR}"

# Download models using the download script
if [ -f "$(dirname "$0")/ai-tools/download-ai-models.sh" ]; then
    "$(dirname "$0")/ai-tools/download-ai-models.sh"
else
    echo "Error: Could not find the model download script."
    exit 1
fi

echo "AI models have been downloaded to ${MODEL_DIR}"
echo "You can manage AI services using: ai-manager"
EOF

# Set permissions
chmod +x "${AI_HOME}/download-ai-models.sh"
chown ${AI_USER}:${AI_USER} "${AI_HOME}/download-ai-models.sh"

# Create a README file
cat > "${AI_HOME}/README.md" << 'EOF'
# Dharma OS - AI Integration

This directory contains the AI integration components for Dharma OS.

## Directory Structure

- `ai/` - Krix AI application code
- `ai-models/` - AI models (downloaded separately)
- `ai-venv/` - Python virtual environment

## Managing AI Services

Use the `ai-manager` command to control AI services:

```bash
# Start all AI services
sudo ai-manager start

# Stop all AI services
sudo ai-manager stop

# Check service status
sudo ai-manager status

# View logs for a specific service
sudo ai-manager logs ollama
```

## Downloading Models

To download AI models, run:

```bash
cd ~
./download-ai-models.sh
```

This will download the default set of models. Make sure you have sufficient disk space.

## API Access

The Krix AI service provides a REST API at `http://localhost:8000/api`.

- API Documentation: http://localhost:8000/api/docs
- Redoc Documentation: http://localhost:8000/api/redoc

## Configuration

Configuration files are located in `/etc/krix-ai/`.

## Troubleshooting

If you encounter issues, check the service logs:

```bash
journalctl -u krix-ai -f
journalctl -u ollama -f
```

## License

This software is part of Dharma OS and is licensed under the MIT License.
EOF

# Set final permissions
chown -R ${AI_USER}:${AI_USER} "${AI_HOME}"
chmod 700 "${AI_HOME}"

# Print completion message
echo ""
echo "========================================"
echo "  Dharma OS AI Foundation Installation"
echo "  Successfully Completed!"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Reboot your system to ensure all services start correctly"
echo "2. Log in as ${AI_USER}"
echo "3. Run '~/download-ai-models.sh' to download AI models"
echo "4. Use 'ai-manager' to manage AI services"
echo ""
echo "Documentation: ${AI_HOME}/README.md"
echo ""

exit 0
