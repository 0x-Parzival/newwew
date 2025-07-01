#!/bin/bash
# Install and run Agent Zero in Docker (Kalki OS)
set -euo pipefail

# Ensure Docker is installed
if ! command -v docker &>/dev/null; then
  echo "[INFO] Installing Docker..."
  sudo pacman -S --noconfirm docker
  sudo systemctl enable --now docker
fi

# Pull and run Agent Zero
sudo docker pull frdel/agent-zero-run
sudo docker rm -f agent-zero 2>/dev/null || true
sudo docker run -d -p 50001:80 --name agent-zero frdel/agent-zero-run

# Open the web UI
if command -v xdg-open &>/dev/null; then
  xdg-open http://localhost:50001
else
  echo "[INFO] Please open http://localhost:50001 in your browser."
fi 