#!/bin/bash
# One-Command SEAL Learning Installer for Kalki OS
# Simple installer that handles everything automatically

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}🤖 SEAL Learning System Installer for Kalki OS${NC}"
echo "=================================================="
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}❌ This script should not be run as root${NC}"
    exit 1
fi

# Check if we're in the right directory
if [[ ! -f "requirements-seal.txt" ]]; then
    echo -e "${RED}❌ Please run this script from the Kalki OS project root directory${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Checking prerequisites...${NC}"

# Check Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed. Please install Python 3 first.${NC}"
    exit 1
fi

# Check pip
if ! command -v pip3 &> /dev/null; then
    echo -e "${RED}❌ pip3 is not installed. Please install pip3 first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Python and pip are available${NC}"

# Install Python dependencies
echo -e "${BLUE}📦 Installing Python dependencies...${NC}"
pip3 install -r requirements-seal.txt
echo -e "${GREEN}✅ Python dependencies installed${NC}"

# Setup system directories
echo -e "${BLUE}📁 Setting up system directories...${NC}"
sudo mkdir -p /var/log/kalki /var/run/kalki /var/lib/kalki /etc/kalki /opt/kalki/src/ai-system/omnet-shell
sudo chown -R kalki:kalki /var/log/kalki /var/run/kalki /var/lib/kalki /etc/kalki /opt/kalki
sudo chmod 755 /var/log/kalki /var/run/kalki /var/lib/kalki /etc/kalki /opt/kalki
echo -e "${GREEN}✅ System directories created${NC}"

# Copy SEAL files
echo -e "${BLUE}📋 Copying SEAL integration files...${NC}"
if [[ -f "src/ai-system/omnet-shell/seal_adapter.py" ]]; then
    sudo cp src/ai-system/omnet-shell/seal_adapter.py /opt/kalki/src/ai-system/omnet-shell/
fi

if [[ -f "src/ai-system/omnet-shell/enhanced-llm-agent.py" ]]; then
    sudo cp src/ai-system/omnet-shell/enhanced-llm-agent.py /opt/kalki/src/ai-system/omnet-shell/
fi

if [[ -f "src/ai-system/omnet-shell/seal_learning_daemon.py" ]]; then
    sudo cp src/ai-system/omnet-shell/seal_learning_daemon.py /opt/kalki/src/ai-system/omnet-shell/
fi

sudo chown -R kalki:kalki /opt/kalki
echo -e "${GREEN}✅ SEAL files copied${NC}"

# Create configuration
echo -e "${BLUE}⚙️ Creating configuration...${NC}"
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
echo -e "${GREEN}✅ Configuration created${NC}"

# Install systemd service
echo -e "${BLUE}🔧 Installing systemd service...${NC}"
if [[ -f "configs/systemd/seal-learning-daemon.service" ]]; then
    sudo cp configs/systemd/seal-learning-daemon.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable seal-learning-daemon.service
    echo -e "${GREEN}✅ Systemd service installed${NC}"
else
    echo -e "${YELLOW}⚠️ Systemd service file not found, skipping${NC}"
fi

# Check Ollama
echo -e "${BLUE}🤖 Checking Ollama...${NC}"
if ! command -v ollama &> /dev/null; then
    echo -e "${YELLOW}⚠️ Ollama not found. Please install Ollama manually:${NC}"
    echo "   Linux: curl -fsSL https://ollama.ai/install.sh | sh"
    echo "   macOS: brew install ollama"
    echo ""
else
    echo -e "${GREEN}✅ Ollama is installed${NC}"
    
    # Check if Ollama is running
    if curl -s http://localhost:11434/api/tags &> /dev/null; then
        echo -e "${GREEN}✅ Ollama is running${NC}"
        
        # Check for dolphin-mistral model
        if ollama list | grep -q "dolphin-mistral"; then
            echo -e "${GREEN}✅ dolphin-mistral model is available${NC}"
        else
            echo -e "${YELLOW}⚠️ dolphin-mistral model not found. Pulling...${NC}"
            ollama pull dolphin-mistral
            echo -e "${GREEN}✅ dolphin-mistral model pulled${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ Ollama is not running. Please start it manually:${NC}"
        echo "   ollama serve"
    fi
fi

# Test installation
echo -e "${BLUE}🧪 Testing installation...${NC}"
if python3 -c "import requests, numpy, sklearn; print('Python dependencies OK')" 2>/dev/null; then
    echo -e "${GREEN}✅ Python dependencies test passed${NC}"
else
    echo -e "${YELLOW}⚠️ Python dependencies test failed${NC}"
fi

if [[ -f "/opt/kalki/src/ai-system/omnet-shell/seal_adapter.py" ]]; then
    echo -e "${GREEN}✅ SEAL adapter file exists${NC}"
else
    echo -e "${YELLOW}⚠️ SEAL adapter file not found${NC}"
fi

echo ""
echo -e "${GREEN}🎉 SEAL Learning System Installation Complete!${NC}"
echo ""
echo -e "${BLUE}📁 Files installed:${NC}"
echo "   - /opt/kalki/src/ai-system/omnet-shell/seal_adapter.py"
echo "   - /opt/kalki/src/ai-system/omnet-shell/enhanced-llm-agent.py"
echo "   - /opt/kalki/src/ai-system/omnet-shell/seal_learning_daemon.py"
echo "   - /etc/kalki/seal_daemon.conf"
echo ""
echo -e "${BLUE}📊 Directories created:${NC}"
echo "   - /var/log/kalki (logs)"
echo "   - /var/run/kalki (runtime)"
echo "   - /var/lib/kalki (data)"
echo "   - /etc/kalki (config)"
echo "   - /opt/kalki (system files)"
echo ""
echo -e "${BLUE}🚀 Next steps:${NC}"
echo "   1. Start the learning system: sudo systemctl start seal-learning-daemon.service"
echo "   2. Test the enhanced agent: python3 /opt/kalki/src/ai-system/omnet-shell/enhanced-llm-agent.py"
echo "   3. Check status: sudo systemctl status seal-learning-daemon.service"
echo "   4. View logs: sudo journalctl -u seal-learning-daemon.service -f"
echo ""
echo -e "${GREEN}✨ The AI will now learn from your interactions!${NC}" 