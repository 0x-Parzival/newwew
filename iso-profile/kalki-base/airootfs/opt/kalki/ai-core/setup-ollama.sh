#!/bin/bash
set -euo pipefail

echo "🧠 Initializing Kalki OS AI Core with the best open-source avatars..."

# Ensure Ollama is installed
if ! command -v ollama >/dev/null 2>&1; then
    echo "📦 Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
fi

# Enable Ollama system service
sudo systemctl enable ollama
sudo systemctl start ollama
sleep 5

echo "🔮 Pulling AI models for each Kalki OS avatar..."

# Avatar AI Models
ollama pull deepseek-coder:6.7b          # Krix, Mushak, Nag, Kalkian mode
ollama pull codellama:7b                 # Mushak (code assistant)
ollama pull llama3:8b-instruct           # Nandi, G.O.A.T.
ollama pull mistral:7b-instruct          # Bunni (writing), fallback
ollama pull openhermes:2.5-mistral       # Shera (security)
ollama pull phi3:mini                    # Roosty (light productivity)
ollama pull gemma:2b-it                  # Monki (casual Hinglish)
ollama pull tinyllama                    # Chew-Chew fallback
ollama pull dolphin-mixtral:8x7b         # Chill Pig (mood, vibe)

echo "✅ Verifying downloaded models..."
ollama list

# Install Python dependencies for AI integration (local tools)
pip install --user ollama rich prompt-toolkit typer websockets aiohttp

echo "🌌 Kalki AI Avatar Network successfully initialized — Dharma is online."
