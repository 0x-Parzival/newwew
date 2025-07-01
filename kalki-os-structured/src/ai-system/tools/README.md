# Dharma OS - AI Integration

This directory contains the AI integration components for Dharma OS, designed to provide a seamless AI experience while keeping the base ISO size manageable.

## Directory Structure

- `install-ai-dependencies.sh` - Installs system and Python dependencies
- `install-ollama.sh` - Sets up Ollama for local LLM inference
- `download-ai-models.sh` - Downloads pre-configured AI models
- `install-ai-foundation.sh` - Main installation script for AI components
- `post-install-setup.sh` - Runs after system installation to complete setup
- `start-ai-setup.sh` - Interactive setup assistant for AI components
- `krix-ai/` - Core AI application code
  - `main.py` - FastAPI-based AI service
  - `requirements.txt` - Python dependencies

## Installation Process

The AI integration is designed to be set up after the base system installation. Here's the recommended workflow:

1. **Base System Installation**
   - Install Dharma OS as usual
   - Complete the initial system setup

2. **AI Component Installation**
   ```bash
   # As root
   cd /home/kalki/ai-tools
   chmod +x *.sh
   ./install-ai-foundation.sh
   ```

3. **Interactive Setup (Recommended)**
   ```bash
   # As kalki user
   ~/ai-tools/start-ai-setup.sh
   ```

## Post-Installation

After installation, you can manage AI services using the following commands:

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

## Downloading AI Models

To download AI models (requires significant disk space):

```bash
# As kalki user
~/download-ai-models.sh
```

## Development

For developers working on the AI components:

1. **Python Virtual Environment**
   ```bash
   python -m venv ~/ai-venv
   source ~/ai-venv/bin/activate
   pip install -r krix-ai/requirements.txt
   ```

2. **Running the AI Service**
   ```bash
   cd krix-ai
   uvicorn main:app --reload
   ```

3. **API Documentation**
   - Swagger UI: http://localhost:8000/api/docs
   - ReDoc: http://localhost:8000/api/redoc

## Troubleshooting

Common issues and solutions:

1. **Missing Dependencies**
   ```bash
   # Reinstall dependencies
   sudo pacman -S --needed base-devel cmake python python-pip
   ```

2. **Permission Issues**
   ```bash
   # Fix permissions
   sudo chown -R kalki:kalki ~/ai-* ~/.ollama
   ```

3. **Service Not Starting**
   ```bash
   # Check service status
   sudo systemctl status krix-ai
   
   # View logs
   journalctl -u krix-ai -f
   ```

## License

This software is part of Dharma OS and is licensed under the MIT License.

## Support

For support, please visit our [community forum](https://community.krix-os.org) or open an issue on our [GitHub repository](https://github.com/krix-os/dharma-ai).
