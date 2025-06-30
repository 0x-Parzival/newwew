# OMNet-Shell (Krix-Term)

OMNet-Shell (also known as Krix-Term) is the AI-powered terminal agent and avatar system for Kalki OS. It serves as the primary user interface, inspired by SmolagentS, and is designed for speed, modularity, and a stunning visual experience.

## Features
- Zsh shell with Starship prompt
- Synthwave + Vedic color scheme, glass blur, and custom fonts
- Avatar system: 12 unique AI personalities, each with cinematic intros and LLM backend
- Default LLM: Dolphin3, with "Pro" option for best free LLM per avatar
- Avatar switching, prompt customization, and in-terminal help
- Fast startup, autostart in Hyprland, and security sandboxing

## Directory Structure
- `avatars/` — Avatar configs, scripts, and assets
- `krix-term` — Main launcher script
- `ai-setup` — AI setup and configuration script
- `generate-avatars.sh` — Avatar config generator

## Usage
OMNet-Shell is autostarted as the main terminal in Hyprland. Users can switch avatars, manage LLMs, and control the OS through this interface.

## OMNet Root Agent: Autonomous OS Editing

- The OMNet Root Agent is a privileged backend service that allows the AI agent to autonomously edit the OS, install packages, and reconfigure the system.
- It creates a BTRFS (or rsync) snapshot before every change, and will automatically roll back if anything goes wrong.
- Only Arch Linux/Archiso-compatible commands are allowed.
- All actions are logged to /var/log/omnet-root-agent.log.
- Runs as a systemd service for security and reliability.

### Usage
- Enable the service: `sudo systemctl enable --now omnet-root-agent`
- The AI agent sends commands via `/run/omnet-root-agent.cmd`.
- To manually send a command: `echo 'pacman -Syu' | sudo tee /run/omnet-root-agent.cmd`

### Security
- Only root can run the agent and send commands.
- All actions are logged and can be audited.
- Rollback is automatic on error.

### Integration
- The AI agent (OMNet-Shell) will use this backend for all system-level changes.
- Each avatar is aware it is running on Archiso and uses only Arch tools. 