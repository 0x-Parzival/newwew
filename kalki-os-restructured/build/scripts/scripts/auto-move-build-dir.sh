#!/bin/bash
# auto-move-build-dir.sh: Automatic script to move/symlink build dir to best partition (SSD/HDD, free space)
set -euo pipefail

BUILD_DIR="$(pwd)/work"  # Change as needed
LOG_FILE="$(pwd)/auto-move-build-dir.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Get candidate partitions (exclude system, boot, readonly, etc.)
get_candidates() {
  lsblk -rno NAME,MOUNTPOINT,FSTYPE,SIZE,ROTA | \
    awk '$2!="" && $2!="[SWAP]" && $2!~"/boot|/efi|/cdrom|/snap|/proc|/sys|/run|/var|/tmp" {print $0}'
}

# Get free space for a mountpoint
get_free_space() {
  df -k --output=avail "$1" 2>/dev/null | tail -1
}

# Build candidate list
CANDIDATES=()
while IFS= read -r line; do
  DEV=$(echo "$line" | awk '{print $1}')
  MNT=$(echo "$line" | awk '{print $2}')
  FSTYPE=$(echo "$line" | awk '{print $3}')
  SIZE=$(echo "$line" | awk '{print $4}')
  ROTA=$(echo "$line" | awk '{print $5}')
  FREE=$(get_free_space "$MNT")
  [ -z "$FREE" ] && continue
  [ -w "$MNT" ] || continue
  TYPE="SSD"
  [ "$ROTA" = "1" ] && TYPE="HDD"
  CANDIDATES+=("$MNT|$DEV|$TYPE|$SIZE|$FREE|$FSTYPE")
done < <(get_candidates)

if [ ${#CANDIDATES[@]} -eq 0 ]; then
  log "No suitable partitions found."
  exit 1
fi

# Sort: SSDs first, then by most free space
BEST=""
BEST_FREE=0
for entry in "${CANDIDATES[@]}"; do
  IFS='|' read -r MNT DEV TYPE SIZE FREE FSTYPE <<< "$entry"
  if [[ "$TYPE" == "SSD" && $FREE -gt $BEST_FREE ]]; then
    BEST="$entry"
    BEST_FREE=$FREE
  fi

done
# If no SSD found, pick best HDD
if [[ -z "$BEST" ]]; then
  for entry in "${CANDIDATES[@]}"; do
    IFS='|' read -r MNT DEV TYPE SIZE FREE FSTYPE <<< "$entry"
    if [[ "$TYPE" == "HDD" && $FREE -gt $BEST_FREE ]]; then
      BEST="$entry"
      BEST_FREE=$FREE
    fi
  done
fi

if [[ -z "$BEST" ]]; then
  log "No suitable SSD or HDD found."
  exit 1
fi

IFS='|' read -r MNT DEV TYPE SIZE FREE FSTYPE <<< "$BEST"
TARGET="$MNT/kalki_build_work"

# If already using the best candidate, do nothing
if [[ -L "$BUILD_DIR" && "$(readlink -f "$BUILD_DIR")" == "$TARGET" ]]; then
  log "Build directory already on best partition ($MNT). No action needed."
  exit 0
fi

if [ -d "$BUILD_DIR" ] && [ ! -L "$BUILD_DIR" ]; then
  log "Moving $BUILD_DIR to $TARGET ..."
  mv "$BUILD_DIR" "$TARGET"
elif [ ! -d "$TARGET" ]; then
  log "Creating $TARGET ..."
  mkdir -p "$TARGET"
fi

log "Symlinking $BUILD_DIR -> $TARGET"
ln -sfn "$TARGET" "$BUILD_DIR"

FREE_GB=$((FREE/1024/1024))
log "Build directory is now on $MNT ($TYPE, Free: ${FREE_GB}GB)"
echo "[auto-move-build-dir] Build directory is now on $MNT ($TYPE, Free: ${FREE_GB}GB)" 