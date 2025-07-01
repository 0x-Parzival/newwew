#!/bin/bash
# kalki-rollback.sh: Simple snapshot/rollback tool for Kalki OS
set -euo pipefail

# Detect backend
if command -v btrfs &>/dev/null && mount | grep -q btrfs; then
    BACKEND="btrfs"
elif command -v snapper &>/dev/null; then
    BACKEND="snapper"
elif command -v timeshift &>/dev/null; then
    BACKEND="timeshift"
else
    echo "No supported snapshot backend found (btrfs, snapper, timeshift)" >&2
    exit 1
fi

SNAPSHOT_DIR="/mnt/.snapshots"

list_snapshots() {
    case "$BACKEND" in
        btrfs)
            ls -1 $SNAPSHOT_DIR 2>/dev/null || echo "No snapshots found."
            ;;
        snapper)
            snapper list --columns "#,date,description" || echo "No snapshots found."
            ;;
        timeshift)
            timeshift --list || echo "No snapshots found."
            ;;
    esac
}

create_snapshot() {
    DESC="${1:-Manual snapshot $(date)}"
    case "$BACKEND" in
        btrfs)
            NAME="manual-$(date +%Y%m%d%H%M%S)"
            sudo btrfs subvolume snapshot / "$SNAPSHOT_DIR/$NAME"
            echo "Created Btrfs snapshot: $NAME"
            ;;
        snapper)
            sudo snapper create --description "$DESC"
            echo "Created Snapper snapshot."
            ;;
        timeshift)
            sudo timeshift --create --comments "$DESC"
            echo "Created Timeshift snapshot."
            ;;
    esac
}

restore_snapshot() {
    SNAP_ID="$1"
    case "$BACKEND" in
        btrfs)
            echo "Restoring Btrfs snapshot: $SNAP_ID"
            echo "(This will reboot and rollback the system. Are you sure?)"
            read -p "Type YES to continue: " confirm
            [[ "$confirm" == "YES" ]] || { echo "Aborted."; exit 1; }
            sudo btrfs subvolume delete /
            sudo btrfs subvolume snapshot "$SNAPSHOT_DIR/$SNAP_ID" /
            echo "Rollback complete. Please reboot."
            ;;
        snapper)
            echo "Restoring Snapper snapshot: $SNAP_ID"
            sudo snapper undochange $SNAP_ID..0
            echo "Rollback complete. Please reboot."
            ;;
        timeshift)
            echo "Restoring Timeshift snapshot: $SNAP_ID"
            sudo timeshift --restore --snapshot "$SNAP_ID"
            ;;
    esac
}

usage() {
    echo "Usage: $0 [list|create [desc]|restore <id>]"
    exit 1
}

case "${1:-}" in
    list)
        list_snapshots
        ;;
    create)
        create_snapshot "${2:-}"
        ;;
    restore)
        [ -n "${2:-}" ] || usage
        restore_snapshot "$2"
        ;;
    *)
        usage
        ;;
esac 