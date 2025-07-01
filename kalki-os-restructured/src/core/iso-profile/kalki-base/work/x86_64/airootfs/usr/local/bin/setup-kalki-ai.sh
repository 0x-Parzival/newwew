#!/bin/bash
echo "🧠 Setting up Kalki OS AI Framework..."

# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Start Ollama service
systemctl enable --now ollama

# Download essential models
ollama pull phi3:mini
ollama pull tinyllama

# Install Python AI dependencies
pip install ollama rich prompt-toolkit typer mediapipe opencv-python

echo "✅ AI Framework initialized successfully"
