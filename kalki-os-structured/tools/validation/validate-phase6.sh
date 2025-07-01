#!/bin/bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔍 Validating Phase 6 - Complete Dharmic Tools & Applications...${NC}"

# Function to check if a file exists and is executable
check_file() {
    if [ -f "$1" ]; then
        if [ -x "$1" ]; then
            echo -e "${GREEN}✅ $1 exists and is executable${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠️  $1 exists but is not executable${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ $1 does not exist${NC}"
        return 1
    fi
}

# Function to check if a directory exists
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✅ Directory exists: $1${NC}"
        return 0
    else
        echo -e "${RED}❌ Directory missing: $1${NC}"
        return 1
    fi
}

# Check main application files
check_file "/opt/kalki/apps/bunniwrite/src/bunniwrite.py"
check_file "/opt/kalki/apps/designdeva/src/designdeva.py"
check_file "/opt/kalki/apps/roostytime/src/roostytime.py"
check_file "/opt/kalki/apps/appmantra/src/appmantra.py"

# Check integration scripts
check_file "/opt/kalki/scripts/integrate-dharmic-apps.sh"
check_file "/opt/kalki/scripts/app-startup-manager.sh"

# Check launcher and desktop files
check_file "/usr/local/bin/kalki-apps"
check_file "/usr/share/applications/kalki-bunniwrite.desktop"
check_file "/usr/share/applications/kalki-designdeva.desktop"
check_file "/usr/share/applications/kalki-roostytime.desktop"
check_file "/usr/share/applications/kalki-appmantra.desktop"

# Check systemd service
if [ -f "/etc/systemd/user/kalki-apps.service" ]; then
    echo -e "${GREEN}✅ Systemd service file exists${NC}
  $(ls -la /etc/systemd/user/kalki-apps.service)"
    
    # Check if service is enabled
    if systemctl --user is-enabled kalki-apps.service >/dev/null 2>&1; then
        echo -e "${GREEN}✅ kalki-apps service is enabled${NC}
  $(systemctl --user status kalki-apps.service | head -n 3)"
    else
        echo -e "${YELLOW}⚠️  kalki-apps service is not enabled${NC}"
    fi
else
    echo -e "${RED}❌ Systemd service file missing${NC}"
fi

# Check desktop integration
echo -e "\n${GREEN}🔍 Checking desktop integration...${NC}"

# Check if applications appear in the menu
if command -v xdg-desktop-menu >/dev/null 2>&1; then
    echo -e "${GREEN}✅ xdg-desktop-menu is available${NC}"
    
    # Check if applications are registered
    echo -e "\n${GREEN}📋 Registered applications:${NC}"
    xdg-desktop-menu list | grep -i "kalki\|bunni\|deva\|roosty" || 
        echo -e "${YELLOW}⚠️  No kalki applications found in menu${NC}"
else
    echo -e "${YELLOW}⚠️  xdg-desktop-menu not available, cannot verify menu integration${NC}"
fi

# Check shell integration
echo -e "\n${GREEN}🔍 Checking shell integration...${NC}"

# Check if aliases are set
if grep -q "# Kalki OS Application Aliases" "/etc/skel/.bashrc" 2>/dev/null; then
    echo -e "${GREEN}✅ Shell aliases are configured in /etc/skel/.bashrc${NC}"
    grep -A 5 "# Kalki OS Application Aliases" "/etc/skel/.bashrc" | grep -v "^#"
else
    echo -e "${YELLOW}⚠️  Shell aliases not found in /etc/skel/.bashrc${NC}"
fi

# Check application directories
echo -e "\n${GREEN}📁 Checking application directories...${NC}"
check_dir "/opt/kalki/apps"
check_dir "/opt/kalki/scripts"
check_dir "/usr/share/applications"

# Check user data directories
echo -e "\n${GREEN}📂 Checking user data directories...${NC}"
check_dir "$HOME/.kalki"
check_dir "$HOME/.kalki/apps"
check_dir "$HOME/.kalki/data"
check_dir "$HOME/.kalki/logs"

# Final status
echo -e "\n${GREEN}✅ Phase 6 validation complete!${NC}"
echo -e "If you see any ${RED}❌${NC} or ${YELLOW}⚠️${NC} items above, please address them before proceeding."
echo -e "Otherwise, your Phase 6 installation appears to be complete and properly integrated."
