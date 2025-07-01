#!/bin/bash
set -euo pipefail

echo "🕉️ Integrating Dharmic Applications into Kalki OS..."

# Create application directories
mkdir -p /usr/share/applications
mkdir -p /usr/share/pixmaps
mkdir -p /opt/kalki/apps

# Create desktop entries for all applications
create_desktop_entry() {
    local app_name="$1"
    local display_name="$2"
    local description="$3"
    local exec_path="$4"
    local icon="$5"
    local category="$6"
    
    cat > "/usr/share/applications/kalki-${app_name}.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=${display_name}
Comment=${description}
Exec=${exec_path}
Icon=${icon}
Terminal=false
Categories=${category};
StartupNotify=true
Keywords=kalki;dharmic;ai;
EOF
}

# BunniWrite
create_desktop_entry "bunniwrite" "BunniWrite" \
    "AI-assisted writing studio with dharmic mindfulness" \
    "python3 /opt/kalki/apps/bunniwrite/src/bunniwrite.py" \
    "text-editor" \
    "Office;WordProcessor;Writing"

# DesignDeva
create_desktop_entry "designdeva" "DesignDeva" \
    "AI-assisted design studio for dharmic aesthetics" \
    "python3 /opt/kalki/apps/designdeva/src/designdeva.py" \
    "applications-graphics" \
    "Graphics;DesignGraphics;Art"

# RoostyTime
create_desktop_entry "roostytime" "RoostyTime" \
    "Natural rhythm-based time management" \
    "python3 /opt/kalki/apps/roostytime/src/roostytime.py" \
    "office-calendar" \
    "Office;Calendar;ProjectManagement"

# AppMantra
create_desktop_entry "appmantra" "AppMantra" \
    "Intelligent application store for Kalki OS" \
    "python3 /opt/kalki/apps/appmantra/src/appmantra.py" \
    "system-software-install" \
    "System;PackageManager"

# Create application launcher script
cat > /usr/local/bin/kalki-apps << 'LAUNCHER_EOF'
#!/bin/bash
# Kalki OS Application Launcher

case "$1" in
    "bunni"|"write")
        python3 /opt/kalki/apps/bunniwrite/src/bunniwrite.py
        ;;
    "design"|"deva")
        python3 /opt/kalki/apps/designdeva/src/designdeva.py
        ;;
    "time"|"roosty")
        python3 /opt/kalki/apps/roostytime/src/roostytime.py
        ;;
    "store"|"apps")
        python3 /opt/kalki/apps/appmantra/src/appmantra.py
        ;;
    "list")
        echo "🕉️ Available Kalki OS Applications:"
        echo "  bunni/write  - BunniWrite (AI Writing Studio)"
        echo "  design/deva  - DesignDeva (AI Design Studio)"
        echo "  time/roosty  - RoostyTime (Time Management)"
        echo "  store/apps   - AppMantra (Application Store)"
        ;;
    *)
        echo "Usage: kalki-apps [bunni|design|time|store|list]"
        echo "       kalki-apps list  - Show all available applications"
        ;;
esac
LAUNCHER_EOF

chmod +x /usr/local/bin/kalki-apps

# Add aliases to shell configuration
cat >> /etc/skel/.bashrc << 'ALIAS_EOF'

# Kalki OS Application Aliases
alias bunni='kalki-apps bunni'
alias write='kalki-apps write'
alias design='kalki-apps design'
alias roostytime='kalki-apps time'
alias appstore='kalki-apps store'
ALIAS_EOF

echo "✅ Dharmic applications integrated successfully"
echo "🎯 Users can now launch apps via:"
echo "   - Application menu (GUI)"
echo "   - kalki-apps command (terminal)"
echo "   - Direct aliases (bunni, design, roostytime, appstore)"
