# Dockerfile for Kalki OS reproducible build environment
# Usage:
#   docker build -t kalki-os-build .
#   docker run --rm -it -v "$PWD:/workspace" kalki-os-build
#
# This container is for building Kalki OS ISOs, not for running the OS itself.

FROM archlinux:latest

# Install dependencies (update as needed)
RUN pacman -Syu --noconfirm \
    archiso git base-devel squashfs-tools rsync dosfstools mtools syslinux wget curl zenity python docker podman

WORKDIR /workspace

# Optionally, add a non-root user (commented out for ISO builds)
# RUN useradd -m builder && echo 'builder ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# USER builder

# Copy and run dependency check
COPY scripts/check-dependencies.sh /tmp/check-dependencies.sh
RUN bash /tmp/check-dependencies.sh

ENTRYPOINT ["bash"] 