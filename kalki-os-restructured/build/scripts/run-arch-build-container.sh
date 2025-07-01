#!/bin/bash
# Run an Arch Linux Docker container for Kalki OS building
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="kalki-os-build"
ARCH_IMAGE="archlinux:latest"

# Check for Docker
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed. Please install Docker Desktop or Docker Engine."
  exit 1
fi

# Pull latest Arch image
docker pull $ARCH_IMAGE

# Create a Dockerfile for AUR and GUI support
cat > "$PROJECT_DIR/Dockerfile.kalki" <<EOF
FROM $ARCH_IMAGE

# Install base tools and dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel git sudo python python-pip tk xorg-xauth xorg-xhost xorg-xeyes xorg-xclock zenity

# Add build user
RUN useradd -m builder && echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER builder
WORKDIR /home/builder

# Install paru (AUR helper)
RUN git clone https://aur.archlinux.org/paru.git && \
    cd paru && \
    makepkg -si --noconfirm && \
    cd .. && rm -rf paru

# Set up project mount point
RUN mkdir -p /home/builder/project
WORKDIR /home/builder/project

# Install Python requirements if present
COPY requirements-all.txt /tmp/requirements-all.txt
RUN pip install --user -r /tmp/requirements-all.txt || true

EOF

# Build the Docker image
docker build -f "$PROJECT_DIR/Dockerfile.kalki" -t kalki-os-build-img "$PROJECT_DIR"

# Run the container with X11 forwarding for GUI support (Linux host)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  xhost +local:docker
  docker run --rm -it \
    --name $CONTAINER_NAME \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "$PROJECT_DIR":/home/builder/project \
    kalki-os-build-img \
    bash
else
  echo "For GUI support on macOS/Windows, use VNC or run CLI builds. Entering container shell..."
  docker run --rm -it \
    --name $CONTAINER_NAME \
    -v "$PROJECT_DIR":/home/builder/project \
    kalki-os-build-img \
    bash
fi 