#!/bin/bash

# Dharma OS - AI Dependencies Installer
# This script installs system dependencies required for AI components

# Exit on error
set -e

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Update package database
echo "Updating package database..."
pacman -Syu --noconfirm

# Install system dependencies
echo "Installing system dependencies..."
pacman -S --needed --noconfirm \
    base-devel \
    cmake \
    python \
    python-pip \
    python-venv \
    python-numpy \
    python-pytorch \
    python-torchvision \
    python-torchaudio \
    cuda \
    cudnn \
    openblas \
    git \
    wget \
    curl \
    jq \
    unzip \
    protobuf \
    onnxruntime \
    python-pipx \
    python-setuptools \
    python-wheel

# Install Python packages in a virtual environment
echo "Setting up Python virtual environment..."
sudo -u kalki mkdir -p /home/kalki/ai-venv
sudo -u kalki python -m venv /home/kalki/ai-venv

# Activate virtual environment and install Python packages
sudo -u kalki bash -c '
    source /home/kalki/ai-venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir \
        numpy \
        pandas \
        scikit-learn \
        matplotlib \
        seaborn \
        transformers \
        datasets \
        accelerate \
        bitsandbytes \
        xformers \
        sentencepiece \
        protobuf \
        fastapi \
        uvicorn \
        python-multipart \
        python-jose[cryptography] \
        passlib[bcrypt] \
        python-dotenv \
        tqdm \
        requests \
        aiohttp \
        openai \
        langchain \
        llama-cpp-python \
        chromadb \
        pydantic \
        typer \
        rich \
        python-multipart \
        python-jose[cryptography] \
        passlib[bcrypt] \
        python-dotenv'

echo "System dependencies and Python packages installed successfully!"
echo "Please run 'source /home/kalki/ai-venv/bin/activate' to activate the virtual environment."
