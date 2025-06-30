#!/bin/bash
echo "🕉️ Welcome to Kalki OS! Setting up your AI companions..."

# Check internet connection
if ping -c 1 google.com >/dev/null 2>&1; then
    echo "🌐 Internet connection detected. Downloading AI models..."
    
    # Run the AI setup
    sudo /opt/kalki/ai-core/setup-ollama.sh
    
    # Start OMNet
    sudo systemctl start omnet
    
    echo "✅ AI setup complete! Your digital companions are ready."
    echo ""
    echo "Try these commands:"
    echo "  krix-term                    # Enter the sentient terminal"
    echo "  krix-term --avatar=bunni     # Talk to Bunni, the creative muse"
    echo "  krix-term --avatar=mushak    # Summon Mushak for debugging"
    echo ""
    echo "🌌 Welcome to dharmic computing!"
else
    echo "⚠️  No internet connection detected."
    echo "Connect to the internet and run this script again to enable AI features."
fi
