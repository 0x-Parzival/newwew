#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Validation functions
check_service() {
    local service_name=$1
    if systemctl is-active --quiet "$service_name"; then
        echo -e "${GREEN}✓${NC} $service_name is running"
        return 0
    else
        echo -e "${RED}✗${NC} $service_name is not running"
        return 1
    fi
}

check_websocket() {
    if ss -tulpn | grep -q ':8765'; then
        echo -e "${GREEN}✓${NC} WebSocket server is listening on port 8765"
        return 0
    else
        echo -e "${RED}✗${NC} WebSocket server is not running on port 8765"
        return 1
    fi
}

check_avatar_models() {
    local expected_models=12
    local installed_models=$(ollama list | grep -c -v '^NAME')
    
    if [ "$installed_models" -ge "$expected_models" ]; then
        echo -e "${GREEN}✓${NC} Found $installed_models avatar models (expected: $expected_models)"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} Found only $installed_models avatar models (expected: $expected_models)"
        return 1
    fi
}

check_voice_components() {
    local missing=0
    
    # Check for voice recognition
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}✗${NC} Python3 not found"
        missing=$((missing+1))
    fi
    
    # Check for required Python packages
    local required_pkgs=("speech_recognition" "pyttsx3" "pyaudio")
    for pkg in "${required_pkgs[@]}"; do
        if ! python3 -c "import ${pkg%%:*}" &> /dev/null; then
            echo -e "${RED}✗${NC} Python package missing: $pkg"
            missing=$((missing+1))
        fi
    done
    
    if [ $missing -eq 0 ]; then
        echo -e "${GREEN}✓${NC} All voice components are installed"
        return 0
    else
        echo -e "${RED}✗${NC} $missing voice components are missing"
        return 1
    fi
}

check_gesture_components() {
    if python3 -c "import mediapipe" &> /dev/null; then
        echo -e "${GREEN}✓${NC} MediaPipe is installed"
        return 0
    else
        echo -e "${RED}✗${NC} MediaPipe is not installed"
        return 1
    fi
}

# Main validation
echo "🔍 Validating AI Integration..."
echo "-------------------------------"

# Check services
check_service "omnet"
check_service "kalki-voice"
check_service "kalki-gesture"

echo ""

# Check WebSocket
check_websocket

# Check models
check_avatar_models

# Check voice components
check_voice_components

# Check gesture components
check_gesture_components

echo ""
echo "Validation Complete!"
echo "------------------"
echo "Run 'krix-term' to test the interactive AI terminal"
echo "Use 'kalki-ai status' to check model status"
echo "Check logs with 'journalctl -u kalki-* -f'"
