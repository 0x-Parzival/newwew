#!/bin/bash
# Script to create the new Kalki OS directory structure

BASE_DIR="/app/kalki-os-restructured"

# Create main structure
mkdir -p "$BASE_DIR"/{src,build,dist,docs,tests,tools,workspace}

# Create src subdirectories
mkdir -p "$BASE_DIR/src"/{core,apps,ai-system,avatar-system,security,configs}

# Create build subdirectories
mkdir -p "$BASE_DIR/build"/{scripts,profiles,tools,ci}

# Create dist subdirectories
mkdir -p "$BASE_DIR/dist"/{iso,packages,keys}

# Create docs subdirectories
mkdir -p "$BASE_DIR/docs"/{user,developer,architecture,release-notes}

# Create tests subdirectories
mkdir -p "$BASE_DIR/tests"/{unit,integration,automation}

# Create tools subdirectories
mkdir -p "$BASE_DIR/tools"/{gui,validation,utilities}

# Create workspace subdirectories
mkdir -p "$BASE_DIR/workspace"/{work,temp,cache}

echo "Directory structure created successfully!"