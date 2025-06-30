#!/bin/bash
# Automated Wine setup for Kalki OS
set -e

# Create default Wine prefix
export WINEPREFIX="$HOME/.wine"
wineboot --init

# Install common dependencies
winetricks -q corefonts vcrun2019 dotnet48

# Set .exe file association (for Thunar and others)
xdg-mime default wine.desktop application/x-ms-dos-executable

# Optionally install Notepad++ as a test
winetricks -q notepadplusplus

echo "Wine setup complete! You can now run Windows apps by double-clicking .exe files." 