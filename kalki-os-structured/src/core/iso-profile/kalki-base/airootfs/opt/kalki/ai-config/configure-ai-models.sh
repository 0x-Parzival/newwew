#!/bin/bash
set -euo pipefail

# Configuration
CONFIG_FILE="/etc/kalki/ai-models.conf"
DEFAULT_MODEL="deepseek-coder:6.7b"
POWER_MODEL="deepseek-coder:33b"

# Ensure config directory exists
sudo mkdir -p "$(dirname "$CONFIG_FILE")"

# Function to check disk space (in GB)
check_disk_space() {
    local required_gb=$1
    local available_kb
    available_kb=$(df -k / | awk 'NR==2 {print $4}')
    local available_gb=$((available_kb / 1024 / 1024))
    [ $available_gb -ge $required_gb ]
}

# Function to install a model with progress
install_model() {
    local model=$1
    echo "📦 Installing $model..."
    if ! ollama pull "$model"; then
        echo "⚠️ Failed to install $model"
        return 1
    fi
    return 0
}

# Main function
main() {
    echo "🤖 Kalki OS AI Model Configuration"
    echo "--------------------------------"
    
    # Check if already configured
    if [ -f "$CONFIG_FILE" ]; then
        echo "ℹ️ AI models are already configured."
        echo "   Run 'sudo kalki-ai --reconfigure' to change settings."
        exit 0
    fi
    
    # Ask about developer needs
    echo "\n🧠 Do you plan to use advanced code generation or AI development tools?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) IS_DEVELOPER=true; break;;
            No ) IS_DEVELOPER=false; break;;
        esac
done

    # Configure models based on selection
    if [ "$IS_DEVELOPER" = true ]; then
        echo "\n🚀 Enabling developer mode with optimized AI models"
        
        # Check for power model installation
        if check_disk_space 70; then
            echo "\n💾 Disk space check: Sufficient space available"
            echo "   Would you like to install the full ${POWER_MODEL} model? (60GB+)"
            echo "   This provides the best coding assistance but requires significant space."
            
            select choice in "Install Full Model" "Use Lighter Model" "View Requirements"; do
                case $choice in
                    "Install Full Model" )
                        install_model "$POWER_MODEL" && {
                            echo "USE_POWER_MODEL=true" | sudo tee "$CONFIG_FILE" >/dev/null
                            echo "✅ ${POWER_MODEL} will be used for development"
                        }
                        break;;
                    "Use Lighter Model" )
                        install_model "$DEFAULT_MODEL"
                        echo "USE_POWER_MODEL=false" | sudo tee "$CONFIG_FILE" >/dev/null
                        echo "✅ ${DEFAULT_MODEL} will be used for development"
                        break;;
                    "View Requirements" )
                        echo "\n📋 Requirements for ${POWER_MODEL}:"
                        echo "   - 70GB+ free disk space"
                        echo "   - 16GB+ RAM recommended"
                        echo "   - Fast internet connection (60GB download)"
                        ;;
                esac
done
        else
            echo "⚠️ Insufficient disk space for ${POWER_MODEL}"
            echo "   Falling back to ${DEFAULT_MODEL}"
            install_model "$DEFAULT_MODEL"
            echo "USE_POWER_MODEL=false" | sudo tee "$CONFIG_FILE" >/dev/null
        fi
    else
        # Standard user setup
        echo "\n🎯 Setting up lightweight AI models..."
        install_model "$DEFAULT_MODEL"
        echo "USE_POWER_MODEL=false" | sudo tee "$CONFIG_FILE" >/dev/null
        echo "✅ Optimized for general use with ${DEFAULT_MODEL}"
    fi
    
    echo "\n🌌 Configuration complete. You can change these settings later with:"
    echo "   sudo kalki-ai --reconfigure"
}

# Run main function
main "$@"
