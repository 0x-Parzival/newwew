#!/bin/bash
# Script to restructure the Kalki OS repository
set -euo pipefail

# Move ISO profiles
echo "Moving ISO profiles..."
git mv iso-profile/kalki-base distro/profiles/ 2>/dev/null || echo "kalki-base not found, skipping"
git mv iso-profile/kalki-ultimate distro/profiles/ 2>/dev/null || echo "kalki-ultimate not found, skipping"

# Move build scripts
echo "Moving build scripts..."
mkdir -p build/iso
git mv build-*.sh build/iso/ 2>/dev/null || true

# Move security layer
echo "Moving security components..."
mkdir -p src/security-layer
git mv phase7/* src/security-layer/ 2>/dev/null || echo "phase7 not found, skipping"

# Move AI components
echo "Moving AI components..."
git mv ai-tools/* src/ai-components/ 2>/dev/null || echo "ai-tools not found, skipping"

# Move avatar system
echo "Moving avatar system..."
git mv avatar-system/* src/avatar-system/ 2>/dev/null || echo "avatar-system not found, skipping"

# Move documentation
echo "Reorganizing documentation..."
git mv phase9-docs/* docs/ 2>/dev/null || echo "phase9-docs not found, skipping"

# Move existing scripts
if [ -d "scripts" ]; then
    git mv scripts/* scripts/maintenance/ 2>/dev/null || true
fi

# Create .gitignore if it doesn't exist
echo "Updating .gitignore..."
cat > .gitignore << 'EOL'
# Build artifacts
/out/
/work/
*.iso
*.img

# Python
__pycache__/
*.py[cod]
*$py.class

# Virtual Environment
venv/
ENV/

# IDE specific files
.vscode/
.idea/
*.swp
*.swo
EOL

echo "Restructuring complete. Please review the changes with 'git status'"
echo "Then commit with: git commit -m 'refactor: restructure repository to professional layout'"

chmod +x scripts/restructure-repo.sh 