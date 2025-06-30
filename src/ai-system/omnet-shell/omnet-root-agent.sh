#!/bin/bash
# OMNet Root Agent: Privileged backend for autonomous AI OS editing (Kalki OS)
# Usage: Run as a systemd service. Listens for commands via /run/omnet-root-agent.cmd
# Features:
#  - BTRFS snapshot/rollback (or rsync fallback)
#  - Executes only Arch Linux/Archiso-compatible commands
#  - Logs all actions to /var/log/omnet-root-agent.log
#  - On error, auto-rollback to previous state
#  - IPC: echo '<command>' > /run/omnet-root-agent.cmd

set -euo pipefail

CMD_FIFO="/run/omnet-root-agent.cmd"
LOG_FILE="/var/log/omnet-root-agent.log"
SNAPSHOT_DIR="/mnt/.snapshots"
BTRFS_ROOT="/mnt" # Adjust if root is elsewhere

[ -p "$CMD_FIFO" ] || mkfifo "$CMD_FIFO"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

is_arch_command() {
  case "$1" in
    pacman*|systemctl*|mkinitcpio*|useradd*|usermod*|passwd*|timedatectl*|hostnamectl*|ln*|cp*|mv*|rm*|chmod*|chown*|btrfs*|rsync*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

create_snapshot() {
  if command -v btrfs &>/dev/null && mount | grep -q btrfs; then
    SNAP_NAME="omnet-$(date +%Y%m%d%H%M%S)"
    btrfs subvolume snapshot "$BTRFS_ROOT" "$SNAPSHOT_DIR/$SNAP_NAME"
    log "Created BTRFS snapshot: $SNAPSHOT_DIR/$SNAP_NAME"
    echo "$SNAP_NAME"
  else
    SNAP_NAME="omnet-rsync-$(date +%Y%m%d%H%M%S)"
    rsync -aAX --delete "$BTRFS_ROOT/" "$SNAPSHOT_DIR/$SNAP_NAME/"
    log "Created rsync snapshot: $SNAPSHOT_DIR/$SNAP_NAME"
    echo "$SNAP_NAME"
  fi
}

rollback_snapshot() {
  local SNAP_NAME="$1"
  if [[ "$SNAP_NAME" == omnet-* ]]; then
    if command -v btrfs &>/dev/null && mount | grep -q btrfs; then
      btrfs subvolume delete "$BTRFS_ROOT"
      btrfs subvolume snapshot "$SNAPSHOT_DIR/$SNAP_NAME" "$BTRFS_ROOT"
      log "Rolled back to BTRFS snapshot: $SNAP_NAME"
    else
      rsync -aAX --delete "$SNAPSHOT_DIR/$SNAP_NAME/" "$BTRFS_ROOT/"
      log "Rolled back to rsync snapshot: $SNAP_NAME"
    fi
  fi
}

log "OMNet Root Agent started. Waiting for commands..."

while true; do
  if read -r CMD < "$CMD_FIFO"; then
    log "Received command: $CMD"
    if is_arch_command "$CMD"; then
      SNAP_NAME=$(create_snapshot)
      if eval "$CMD"; then
        log "Command succeeded: $CMD"
      else
        log "Command failed: $CMD. Rolling back..."
        rollback_snapshot "$SNAP_NAME"
      fi
    else
      log "Rejected non-Arch command: $CMD"
    fi
  fi
  sleep 1
done 