# Ensure build/work directory is on the best partition
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../scripts/auto-move-build-dir.sh" ]; then
  bash "$SCRIPT_DIR/../scripts/auto-move-build-dir.sh"
  echo "[build-kalki.sh] Auto-move build dir script executed."
fi

# Check build dependencies before proceeding
if [ -f "$SCRIPT_DIR/../scripts/check-dependencies.sh" ]; then
  bash "$SCRIPT_DIR/../scripts/check-dependencies.sh" || exit 1
  echo "[build-kalki.sh] Dependency check passed."
else
  echo "[build-kalki.sh] Dependency check script not found!"
  exit 1
fi 