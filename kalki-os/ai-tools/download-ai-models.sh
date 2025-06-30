#!/bin/bash

# Dharma OS - AI Model Downloader
# This script handles downloading and managing AI models

# Exit on error
set -e

# Configuration
MODEL_DIR="/home/kalki/ai-models"
MODEL_LIST=(
    "TheBloke/Llama-3-8B-Instruct-GGUF"
    "TheBloke/Mistral-7B-Instruct-v0.2-GGUF"
    "TheBloke/Phi-3-mini-4k-instruct-GGUF"
    "Xenova/all-MiniLM-L6-v2"
)

# Create model directory if it doesn't exist
mkdir -p "$MODEL_DIR"
chown -R kalki:kalki "$MODEL_DIR"

# Install huggingface_hub if not already installed
if ! pip show huggingface-hub >/dev/null 2>&1; then
    echo "Installing huggingface_hub..."
    pip install --user huggingface-hub
fi

# Function to download a model
download_model() {
    local model_name="$1"
    local model_path="${MODEL_DIR}/${model_name##*/}"
    
    echo "Downloading ${model_name}..."
    
    # Use huggingface_hub for downloading
    python3 -c "
import os
from huggingface_hub import hf_hub_download

model = '$model_name'
local_dir = '$MODEL_DIR'

# Create model directory if it doesn't exist
os.makedirs(os.path.join(local_dir, os.path.basename(model)), exist_ok=True)

# Download model files (adjust patterns as needed)
try:
    # Try to download GGUF files for LLMs
    hf_hub_download(
        repo_id=model,
        filename="*.gguf",
        local_dir=os.path.join(local_dir, os.path.basename(model)),
        local_dir_use_symlinks=False
    )
except:
    try:
        # If no GGUF files, try to download all files
        from huggingface_hub import snapshot_download
        snapshot_download(
            repo_id=model,
            local_dir=os.path.join(local_dir, os.path.basename(model)),
            local_dir_use_symlinks=False
        )
    except Exception as e:
        print(f"Error downloading {model}: {str(e)}")
"
    
    # Set correct permissions
    chown -R kalki:kalki "$MODEL_DIR"
    echo "Downloaded ${model_name}"
}

# Export the function for parallel processing
export -f download_model
export MODEL_DIR

# Download models in parallel
printf "%s\n" "${MODEL_LIST[@]}" | xargs -I{} -P 4 bash -c 'download_model "$@"' _ {}

echo "All models downloaded to ${MODEL_DIR}"

# Create a simple model manager script
cat > /usr/local/bin/ai-model-manager << 'EOF'
#!/bin/bash

# Dharma OS - AI Model Manager
# Simple interface for managing AI models

MODEL_DIR="/home/kalki/ai-models"

list_models() {
    echo "Available models:"
    find "$MODEL_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;
}

model_info() {
    local model="$1"
    local model_path="${MODEL_DIR}/${model}"
    
    if [ ! -d "$model_path" ]; then
        echo "Model not found: $model"
        return 1
    fi
    
    echo "Model: $model"
    echo "Location: $model_path"
    echo "Size: $(du -sh "$model_path" | cut -f1)"
    echo "Files:"
    find "$model_path" -type f -exec ls -lh {} \;
}

case "$1" in
    list)
        list_models
        ;;
    info)
        if [ -z "$2" ]; then
            echo "Usage: $0 info <model_name>"
            exit 1
        fi
        model_info "$2"
        ;;
    *)
        echo "Usage: $0 {list|info <model_name>}"
        exit 1
        ;;
esac
EOF

chmod +x /usr/local/bin/ai-model-manager

echo "Installation complete! Use 'ai-model-manager' to manage your AI models."
