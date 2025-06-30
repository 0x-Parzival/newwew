#!/bin/bash
# Kalki OS Environment Setup Automation Script
# Logs actions to setup-build-env.log

LOGFILE="setup-build-env.log"
exec > >(tee -a "$LOGFILE") 2>&1

# --- GUI dialog helpers ---
show_dialog() {
    local msg="$1"
    if command -v zenity >/dev/null 2>&1; then
        zenity --info --text="$msg"
    elif command -v yad >/dev/null 2>&1; then
        yad --text="$msg" --button=OK
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e 'display dialog "'$msg'" buttons {"OK"} default button 1'
    else
        echo "$msg"
    fi
}

show_error() {
    local msg="$1"
    if command -v zenity >/dev/null 2>&1; then
        zenity --error --text="$msg"
    elif command -v yad >/dev/null 2>&1; then
        yad --text="$msg" --button=OK --title="Error"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e 'display dialog "'$msg'" buttons {"OK"} default button 1 with icon stop'
    else
        echo "ERROR: $msg" >&2
    fi
}

# --- OS Detection ---
if [[ -f /etc/arch-release ]]; then
    OS="arch"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
else
    OS="other"
fi

echo "[INFO] Detected OS: $OS"

# --- Arch Linux Setup ---
if [[ "$OS" == "arch" ]]; then
    echo "[INFO] Installing dependencies..."
    sudo pacman -Syu --noconfirm
    sudo pacman -S --needed --noconfirm base-devel git archiso mkinitcpio-archiso qemu libvirt zenity
    # Install paru (AUR helper) if not present
    if ! command -v paru >/dev/null 2>&1; then
        git clone https://aur.archlinux.org/paru.git || { show_error "Failed to clone paru AUR repo"; exit 1; }
        pushd paru
        makepkg -si --noconfirm || { show_error "Failed to install paru"; exit 1; }
        popd
        rm -rf paru
    fi
    # Install AUR packages
    paru -S --needed --noconfirm python-torch python-transformers python-llama-cpp q4wine || show_error "Some AUR packages failed to install. Please check manually."
    # Python dependencies
    if [[ -f requirements-all.txt ]]; then
        pip install -r requirements-all.txt || show_error "Some Python dependencies failed to install."
    fi
    # Directory and permission checks
    mkdir -p out work
    sudo chown -R $USER .
    echo "[INFO] Environment setup complete."
    show_dialog "Kalki OS build environment is ready!"
    exit 0
fi

# --- macOS or Other OS ---
if [[ "$OS" == "macos" || "$OS" == "other" ]]; then
    show_dialog "You are not on Arch Linux.\n\nKalki OS build requires an Arch Linux environment.\n\nWould you like to launch a Docker container or VM?"
    if command -v docker >/dev/null 2>&1; then
        echo "[INFO] Launching Arch Linux Docker container..."
        docker run -it --rm -v "$PWD":/build archlinux:latest /bin/bash
        exit 0
    else
        show_error "Docker is not installed. Please install Docker or set up an Arch Linux VM manually."
        exit 1
    fi
fi

show_error "Unsupported OS. Please use Arch Linux or set up an Arch Linux VM/Docker container."
exit 1 