# Kalki AI Installation Assistant

## Overview
The Kalki AI Installation Assistant is an embedded AI system designed to guide users through the installation and setup of Kalki OS. It provides intelligent troubleshooting, system diagnostics, and step-by-step guidance for both new and experienced users.

## Features

### 🧠 AI-Powered Assistance
- Natural language understanding for installation guidance
- Context-aware troubleshooting and problem resolution
- Step-by-step installation walkthrough
- System diagnostics and health checks

### 🛠️ Key Commands
- `kia` - Launch the interactive installation assistant
- `kia --diagnose` - Get help with system issues
- `kia --install` - Start the guided installation process
- `kia --help` - Show help information

## System Requirements
- CPU: x86_64 (64-bit) processor
- RAM: Minimum 2GB (4GB recommended)
- Storage: 20GB free space
- Graphics: 1024x768 minimum resolution

## Integration
### System Services
The AI assistant runs as a systemd service that starts automatically:
```
systemctl status kalki-install-assistant
```

### Dependencies
- Python 3.8+
- llama-cpp-python
- PyTorch
- Transformers

## Development
### Building the Model
1. Place your GGUF model in `/opt/kalki/ai-assistant/`
2. Name it `install-assistant.gguf`
3. Ensure proper permissions:
   ```
   chmod 644 /opt/kalki/ai-assistant/install-assistant.gguf
   ```

### Testing
Run the assistant in test mode:
```
python3 /opt/kalki/ai-assistant/kia.py --test
```

## Troubleshooting
### Common Issues
1. **Assistant not starting**
   - Check service status: `systemctl status kalki-install-assistant`
   - View logs: `journalctl -u kalki-install-assistant`

2. **Model loading issues**
   - Verify model file exists and has correct permissions
   - Check available RAM and disk space

3. **Performance problems**
   - Close unnecessary applications
   - Ensure system meets minimum requirements

## License
Kalki AI Installation Assistant is part of the Kalki OS project and is distributed under the GPL-3.0 License.

---
*Kalki OS - Where Dharma Meets Technology*
