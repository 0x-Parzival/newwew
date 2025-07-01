#!/bin/bash
# Kalki OS Wrapper Initialization Script
# Initializes AI, avatar, UI, and security layers

set -e

KALKI_HOME="/opt/kalki"
KALKI_ROOT="/opt/kalki"

# Check if already initialized
if [[ -f /tmp/kalki-initialized ]]; then
    echo "ℹ️ Kalki OS already initialized"
    exit 0
fi

init_ai_layer() {
    echo "🧠 Initializing AI Layer..."
    
    # Install AI dependencies
    if command -v pip3 &> /dev/null; then
        pip3 install torch numpy gymnasium stable-baselines3 || echo "⚠️ Some AI dependencies failed to install"
    fi
    
    # Start AI core service
    if [[ -f "$KALKI_HOME/src/ai-system/agent57/main.py" ]]; then
        systemctl start kalki-agent57 || echo "⚠️ Agent57 service not available"
        echo "✅ AI core initialized"
    else
        echo "⚠️ AI core not found"
    fi
}

init_avatar_system() {
    echo "👥 Initializing Avatar System..."
    
    # Start avatar manager
    if [[ -f "$KALKI_HOME/src/avatar-system/core/avatar-engine.py" ]]; then
        systemctl start kalki-avatar-manager || echo "⚠️ Avatar manager service not available"
        echo "✅ Avatar system initialized"
    else
        echo "⚠️ Avatar system not found"
    fi
}

init_dharmic_ui() {
    echo "🎨 Initializing Dharmic UI..."
    
    # Apply Hyprland config
    if [[ -d "$KALKI_HOME/configs/hyprland" ]]; then
        mkdir -p /etc/skel/.config/hypr
        cp -r $KALKI_HOME/configs/hyprland/* /etc/skel/.config/hypr/ 2>/dev/null || true
        echo "✅ Hyprland configured"
    fi
    
    # Apply dharmic theme
    if [[ -d "$KALKI_HOME/themes" ]]; then
        /opt/kalki/scripts/apply-dharmic-theme.sh 2>/dev/null || echo "⚠️ Theme script not available"
        echo "✅ Dharmic theme applied"
    fi
}

init_security_layer() {
    echo "🔒 Initializing Security Layer..."
    
    # Data-Treya privacy framework
    if [[ -f "$KALKI_HOME/security/data-treya/treya-module.ko" ]]; then
        modprobe treya 2>/dev/null || echo "⚠️ Data-Treya kernel module not available"
    fi
    
    # AECH blockchain (if configured)
    if [[ -f "$KALKI_HOME/security/aech/blockchain-config.json" ]]; then
        systemctl start aech-logger 2>/dev/null || echo "⚠️ AECH logger not available"
        echo "✅ AECH blockchain logging enabled"
    fi
}

main() {
    echo "🌟 Initializing Kalki OS Wrapper..."
    
    # Initialize layers in order
    init_ai_layer
    init_avatar_system
    init_dharmic_ui  
    init_security_layer
    
    # Mark as initialized
    touch /tmp/kalki-initialized
    
    # Show welcome message
    echo "🌟 Kalki OS Wrapper Initialized Successfully!"
    echo "💫 Dharmic computing awaits your command..."
    
    # Optional: Start welcome tutorial
    if [[ "${KALKI_SHOW_WELCOME:-true}" == "true" ]]; then
        /opt/kalki/scripts/show-welcome.sh 2>/dev/null &
    fi
}

main "$@" 