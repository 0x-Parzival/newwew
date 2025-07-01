#!/bin/bash
# Migration script: Move content from legacy kalki-os to kalki-os-new
# Usage: ./migrate-from-legacy.sh /path/to/legacy-kalki-os

set -e

LEGACY_DIR=${1:-"../kalki-os"}
NEW_ROOT=$(dirname "$0")
LOGFILE="$NEW_ROOT/migration.log"

if [[ ! -d "$LEGACY_DIR" ]]; then
    echo "Legacy directory $LEGACY_DIR not found!" | tee -a "$LOGFILE"
    exit 1
fi

mkdir -p "$NEW_ROOT/src/ai-tools" "$NEW_ROOT/src/ai-system" "$NEW_ROOT/docs" "$NEW_ROOT/scripts/maintenance"

# 1. Migrate AI components
if [[ -d "$LEGACY_DIR/ai-tools" ]]; then
    echo "🧠 Migrating AI tools..." | tee -a "$LOGFILE"
    rsync -av "$LEGACY_DIR/ai-tools/" "$NEW_ROOT/src/ai-tools/" | tee -a "$LOGFILE"
fi
if [[ -f "$LEGACY_DIR/ai-post-install.sh" ]]; then
    echo "🧠 Migrating ai-post-install.sh..." | tee -a "$LOGFILE"
    cp "$LEGACY_DIR/ai-post-install.sh" "$NEW_ROOT/src/ai-system/" | tee -a "$LOGFILE"
fi

# 2. Migrate documentation
echo "📚 Migrating documentation..." | tee -a "$LOGFILE"
find "$LEGACY_DIR" -name "*.md" -not -path "*/.git/*" | while read doc; do
    target_dir="$NEW_ROOT/docs/$(dirname ${doc#$LEGACY_DIR/})"
    mkdir -p "$target_dir"
    cp "$doc" "$target_dir/"
    echo "Copied $doc to $target_dir/" | tee -a "$LOGFILE"
done

# 3. Migrate utility scripts
echo "🛠️ Migrating utility scripts..." | tee -a "$LOGFILE"
find "$LEGACY_DIR" -name "*.sh" -not -path "*/.git/*" -not -name "build-*" | while read script; do
    if [[ "$script" =~ (test|validate|setup|fix) ]]; then
        cp "$script" "$NEW_ROOT/scripts/maintenance/"
        echo "Copied $script to scripts/maintenance/" | tee -a "$LOGFILE"
    fi
done

echo "✅ Migration complete. See $LOGFILE for details." 