# SEAL Learning System Installation Guide

## Quick Installation

### One-Command Installer

The easiest way to install the SEAL learning system is using the one-command installer:

```bash
# Make sure you're in the Kalki OS project root directory
cd /path/to/kalki_structured

# Run the installer
./install-seal-learning.sh
```

This script will automatically:
- ✅ Install all Python dependencies
- ✅ Setup system directories
- ✅ Copy SEAL integration files
- ✅ Create configuration files
- ✅ Install systemd service
- ✅ Check Ollama installation
- ✅ Test the installation

## Manual Installation

If you prefer to install manually or need to customize the installation:

### 1. Prerequisites

#### Python Dependencies
```bash
# Install Python dependencies
pip3 install -r requirements-seal.txt
```

#### Ollama Installation
```bash
# Linux
curl -fsSL https://ollama.ai/install.sh | sh

# macOS
brew install ollama

# Start Ollama
ollama serve

# Pull dolphin-mistral model
ollama pull dolphin-mistral
```

### 2. Setup System Directories

```bash
# Create necessary directories
sudo mkdir -p /var/log/kalki /var/run/kalki /var/lib/kalki /etc/kalki /opt/kalki/src/ai-system/omnet-shell

# Set proper permissions
sudo chown -R kalki:kalki /var/log/kalki /var/run/kalki /var/lib/kalki /etc/kalki /opt/kalki
sudo chmod 755 /var/log/kalki /var/run/kalki /var/lib/kalki /etc/kalki /opt/kalki
```

### 3. Copy SEAL Files

```bash
# Copy SEAL integration files
sudo cp src/ai-system/omnet-shell/seal_adapter.py /opt/kalki/src/ai-system/omnet-shell/
sudo cp src/ai-system/omnet-shell/enhanced-llm-agent.py /opt/kalki/src/ai-system/omnet-shell/
sudo cp src/ai-system/omnet-shell/seal_learning_daemon.py /opt/kalki/src/ai-system/omnet-shell/

# Set ownership
sudo chown -R kalki:kalki /opt/kalki
```

### 4. Create Configuration

```bash
# Create default configuration
sudo tee /etc/kalki/seal_daemon.conf > /dev/null <<EOF
{
    "adaptation_interval": 3600,
    "learning_threshold": 10,
    "max_learning_data": 1000,
    "enable_continuous_learning": true,
    "enable_periodic_adaptation": true,
    "ollama_health_check_interval": 300,
    "log_level": "INFO"
}
EOF

sudo chown kalki:kalki /etc/kalki/seal_daemon.conf
```

### 5. Install Systemd Service

```bash
# Copy systemd service
sudo cp configs/systemd/seal-learning-daemon.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable service
sudo systemctl enable seal-learning-daemon.service
```

### 6. Start the Learning System

```bash
# Start the daemon
sudo systemctl start seal-learning-daemon.service

# Check status
sudo systemctl status seal-learning-daemon.service
```

## Dependencies

### Python Dependencies

The following Python packages are required:

```txt
requests>=2.28.0          # HTTP requests and API communication
numpy>=1.21.0             # Numerical computing
pandas>=1.4.0             # Data manipulation and analysis
scikit-learn>=1.1.0       # Machine learning algorithms
torch>=1.12.0             # PyTorch for deep learning
transformers>=4.20.0      # Hugging Face transformers
datasets>=2.0.0           # Dataset handling
accelerate>=0.12.0        # Accelerated training
matplotlib>=3.5.0         # Plotting and visualization
seaborn>=0.11.0           # Statistical data visualization
psutil>=5.8.0             # System and process utilities
pyyaml>=6.0               # YAML configuration files
```

### System Dependencies

- **Python 3.7+**: Core runtime
- **pip3**: Package manager
- **Ollama**: Local LLM server
- **systemd**: Service management (Linux)
- **curl**: HTTP client for API calls
- **sudo**: Administrative privileges

### Optional Dependencies

For advanced features:
- **tensorboard**: Learning visualization
- **wandb**: Experiment tracking
- **optuna**: Hyperparameter optimization

## Installation Verification

### Test Python Dependencies

```bash
python3 -c "import requests, numpy, sklearn, torch, transformers; print('All dependencies OK')"
```

### Test Ollama Connection

```bash
curl http://localhost:11434/api/tags
```

### Test SEAL Files

```bash
ls -la /opt/kalki/src/ai-system/omnet-shell/seal_adapter.py
ls -la /opt/kalki/src/ai-system/omnet-shell/enhanced-llm-agent.py
ls -la /opt/kalki/src/ai-system/omnet-shell/seal_learning_daemon.py
```

### Test Systemd Service

```bash
sudo systemctl is-enabled seal-learning-daemon.service
sudo systemctl is-active seal-learning-daemon.service
```

## Post-Installation Setup

### 1. Start the Learning System

```bash
sudo systemctl start seal-learning-daemon.service
```

### 2. Test the Enhanced Agent

```bash
python3 /opt/kalki/src/ai-system/omnet-shell/enhanced-llm-agent.py
```

### 3. Monitor Learning Progress

```bash
# View daemon logs
sudo journalctl -u seal-learning-daemon.service -f

# Check learning statistics
python3 /opt/kalki/src/ai-system/omnet-shell/seal_learning_daemon.py status
```

### 4. Configure Learning Parameters

Edit the configuration file:
```bash
sudo nano /etc/kalki/seal_daemon.conf
```

## Troubleshooting

### Common Issues

#### Python Dependencies Not Found
```bash
# Reinstall dependencies
pip3 install -r requirements-seal.txt --force-reinstall
```

#### Ollama Not Running
```bash
# Start Ollama
ollama serve

# Check if it's running
curl http://localhost:11434/api/tags
```

#### Permission Denied
```bash
# Fix permissions
sudo chown -R kalki:kalki /var/log/kalki /var/run/kalki /var/lib/kalki /etc/kalki /opt/kalki
```

#### Service Not Starting
```bash
# Check service status
sudo systemctl status seal-learning-daemon.service

# View detailed logs
sudo journalctl -u seal-learning-daemon.service -n 50
```

### Log Files

- `/var/log/kalki/seal_daemon.log` - Main daemon log
- `/var/log/kalki/seal_adapter.log` - SEAL adapter log
- `~/.config/omnet-shell/enhanced-llm-agent.log` - Enhanced agent log

### Health Checks

```bash
# Check if all components are working
./scripts/test-seal-learning.py

# Check system health
python3 /opt/kalki/src/ai-system/omnet-shell/seal_learning_daemon.py status
```

## Configuration Options

### Daemon Configuration

The daemon configuration file (`/etc/kalki/seal_daemon.conf`) supports the following options:

```json
{
    "adaptation_interval": 3600,        // Adaptation interval in seconds
    "learning_threshold": 10,           // Minimum interactions before adaptation
    "max_learning_data": 1000,          // Maximum learning data points to keep
    "enable_continuous_learning": true, // Enable continuous learning
    "enable_periodic_adaptation": true, // Enable periodic adaptation
    "ollama_health_check_interval": 300, // Health check interval in seconds
    "log_level": "INFO"                 // Logging level (DEBUG, INFO, WARNING, ERROR)
}
```

### Environment Variables

You can also set environment variables:

```bash
export KALKI_SEAL_ENABLED=1
export KALKI_SEAL_LOG_LEVEL=DEBUG
export KALKI_SEAL_ADAPTATION_INTERVAL=1800
```

## Uninstallation

To remove the SEAL learning system:

```bash
# Stop and disable the service
sudo systemctl stop seal-learning-daemon.service
sudo systemctl disable seal-learning-daemon.service

# Remove systemd service
sudo rm /etc/systemd/system/seal-learning-daemon.service
sudo systemctl daemon-reload

# Remove system files
sudo rm -rf /opt/kalki/src/ai-system/omnet-shell/seal_*.py
sudo rm -rf /var/log/kalki/seal_*.log
sudo rm -rf /var/lib/kalki/seal_*.jsonl
sudo rm -rf /etc/kalki/seal_daemon.conf

# Remove Python packages (optional)
pip3 uninstall requests numpy scikit-learn pandas matplotlib seaborn torch transformers datasets accelerate psutil pyyaml
```

## Support

For issues and questions:

1. Check the troubleshooting section
2. Review log files for errors
3. Test individual components
4. Consult the SEAL framework documentation
5. Check the Kalki OS community

## Next Steps

After successful installation:

1. **Test the system**: Use the test script to verify functionality
2. **Configure settings**: Adjust learning parameters to suit your needs
3. **Monitor progress**: Watch the learning system improve over time
4. **Explore features**: Try different learning configurations
5. **Provide feedback**: Share experiences and suggestions

The SEAL learning system is now ready to make your Kalki OS more intelligent and personalized! 🚀 