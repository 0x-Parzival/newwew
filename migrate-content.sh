#!/bin/bash
# Kalki OS Content Migration Script
set -euo pipefail

SOURCE_DIR="/app"
TARGET_DIR="/app/kalki-os-restructured"

echo "Starting Kalki OS content migration..."

# Function to copy with feedback
copy_with_feedback() {
  local src="$1"
  local dest="$2"
  local description="$3"
  
  if [ -e "$src" ]; then
    echo "Migrating $description: $src -> $dest"
    cp -r "$src" "$dest"
  else
    echo "Warning: $src not found, skipping $description"
  fi
}

# 1. Migrate Core OS Components
echo "=== Migrating Core Components ==="
copy_with_feedback "$SOURCE_DIR/iso-profile" "$TARGET_DIR/src/core/" "ISO profiles"
copy_with_feedback "$SOURCE_DIR/distro" "$TARGET_DIR/src/core/" "Distro configuration"
copy_with_feedback "$SOURCE_DIR/sessions" "$TARGET_DIR/src/core/" "Desktop sessions"

# 2. Migrate Applications
echo "=== Migrating Applications ==="
copy_with_feedback "$SOURCE_DIR/apps" "$TARGET_DIR/src/apps/" "Dharmic applications"

# 3. Migrate AI System Components
echo "=== Migrating AI System ==="
copy_with_feedback "$SOURCE_DIR/agent-ui" "$TARGET_DIR/src/ai-system/" "Agent UI"
copy_with_feedback "$SOURCE_DIR/external/SEAL" "$TARGET_DIR/src/ai-system/seal" "SEAL learning system"

# Check for AI-related files in kalki-os directory
if [ -d "$SOURCE_DIR/kalki-os/ai-tools" ]; then
  copy_with_feedback "$SOURCE_DIR/kalki-os/ai-tools" "$TARGET_DIR/src/ai-system/tools" "AI tools"
fi

# 4. Migrate Avatar System
echo "=== Migrating Avatar System ==="
copy_with_feedback "$SOURCE_DIR/src/avatar-system" "$TARGET_DIR/src/avatar-system/" "Avatar system source"
copy_with_feedback "$SOURCE_DIR/prompts" "$TARGET_DIR/src/avatar-system/prompts" "Avatar prompts"
copy_with_feedback "$SOURCE_DIR/memory" "$TARGET_DIR/src/avatar-system/memory" "Avatar memory"

# 5. Migrate Security Components
echo "=== Migrating Security ==="
copy_with_feedback "$SOURCE_DIR/kalki-os/security" "$TARGET_DIR/src/security/" "Security configuration"

# 6. Migrate System Configurations
echo "=== Migrating Configurations ==="
copy_with_feedback "$SOURCE_DIR/configs" "$TARGET_DIR/src/configs/" "System configurations"
copy_with_feedback "$SOURCE_DIR/templates" "$TARGET_DIR/src/configs/templates" "Configuration templates"

# 7. Migrate Build System
echo "=== Migrating Build System ==="
copy_with_feedback "$SOURCE_DIR/scripts" "$TARGET_DIR/build/scripts/" "Build scripts"
copy_with_feedback "$SOURCE_DIR/build" "$TARGET_DIR/build/tools/" "Build tools"

# Copy main build scripts
for script in build-*.sh *.sh; do
  if [ -f "$SOURCE_DIR/$script" ] && [[ "$script" == *build* || "$script" == setup-* || "$script" == run-* ]]; then
    copy_with_feedback "$SOURCE_DIR/$script" "$TARGET_DIR/build/scripts/" "Build script: $script"
  fi
done

# 8. Migrate Documentation
echo "=== Migrating Documentation ==="
copy_with_feedback "$SOURCE_DIR/docs" "$TARGET_DIR/docs/" "Documentation"
copy_with_feedback "$SOURCE_DIR/README.md" "$TARGET_DIR/docs/README.md" "Main README"
copy_with_feedback "$SOURCE_DIR/PHASE6_README.md" "$TARGET_DIR/docs/release-notes/" "Phase 6 README"
copy_with_feedback "$SOURCE_DIR/KALKI_OS_HANDBOOK.txt" "$TARGET_DIR/docs/user/" "User handbook"

# Copy other documentation files
for doc in *.md *.txt; do
  if [ -f "$SOURCE_DIR/$doc" ] && [ "$doc" != "README.md" ]; then
    copy_with_feedback "$SOURCE_DIR/$doc" "$TARGET_DIR/docs/developer/" "Documentation: $doc"
  fi
done

# 9. Migrate Testing Framework
echo "=== Migrating Testing ==="
copy_with_feedback "$SOURCE_DIR/tests" "$TARGET_DIR/tests/" "Test framework"
copy_with_feedback "$SOURCE_DIR/test" "$TARGET_DIR/tests/integration/" "Integration tests"

# 10. Migrate Development Tools
echo "=== Migrating Tools ==="
copy_with_feedback "$SOURCE_DIR/kalki-build-gui.py" "$TARGET_DIR/tools/gui/" "GUI build tool"
copy_with_feedback "$SOURCE_DIR/tools" "$TARGET_DIR/tools/utilities/" "Utility tools"

# Copy validation scripts
for script in validate-*.sh; do
  if [ -f "$SOURCE_DIR/$script" ]; then
    copy_with_feedback "$SOURCE_DIR/$script" "$TARGET_DIR/tools/validation/" "Validation script: $script"
  fi
done

# 11. Migrate Requirements and Configuration Files
echo "=== Migrating Configuration Files ==="
copy_with_feedback "$SOURCE_DIR/requirements*.txt" "$TARGET_DIR/" "Requirements files"
copy_with_feedback "$SOURCE_DIR/Dockerfile" "$TARGET_DIR/build/ci/" "Docker configuration"
copy_with_feedback "$SOURCE_DIR/Vagrantfile" "$TARGET_DIR/build/ci/" "Vagrant configuration"
copy_with_feedback "$SOURCE_DIR/custom-packages.lock" "$TARGET_DIR/dist/packages/" "Package lock file"

# 12. Handle the kalki-os main directory (most current version)
echo "=== Processing kalki-os main directory ==="
if [ -d "$SOURCE_DIR/kalki-os" ]; then
  # Copy specific important files from kalki-os
  copy_with_feedback "$SOURCE_DIR/kalki-os/iso-profile" "$TARGET_DIR/build/profiles/kalki-os" "Kalki OS profiles"
  copy_with_feedback "$SOURCE_DIR/kalki-os/scripts" "$TARGET_DIR/build/scripts/kalki-os" "Kalki OS scripts"
  
  # Copy build scripts from kalki-os
  for script in "$SOURCE_DIR/kalki-os"/*.sh; do
    if [ -f "$script" ]; then
      script_name=$(basename "$script")
      copy_with_feedback "$script" "$TARGET_DIR/build/scripts/$script_name" "Kalki OS build script: $script_name"
    fi
  done
fi

echo "=== Content Migration Complete ==="
echo "New structured directory: $TARGET_DIR"