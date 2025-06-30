#!/bin/bash
# kalki-rollback-gui.sh: Zenity GUI for kalki-rollback.sh
set -euo pipefail

# Robust path resolution (symlink-safe)
resolve_path() {
    if command -v realpath >/dev/null 2>&1; then
        realpath "$1"
    elif command -v readlink >/dev/null 2>&1; then
        readlink -f "$1"
    else
        (cd "$(dirname "$1")" && pwd)/$(basename "$1")
    fi
}
SCRIPT_PATH="$(resolve_path "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
ROLLBACK_CLI="$SCRIPT_DIR/kalki-rollback.sh"
# Dependency check at the start
if [ -f "$SCRIPT_DIR/../check-dependencies.sh" ]; then
  bash "$SCRIPT_DIR/../check-dependencies.sh" || exit 1
  echo "[kalki-rollback-gui.sh] Dependency check passed."
else
  echo "[kalki-rollback-gui.sh] Dependency check script not found!"
  exit 1
fi

main_menu() {
    ACTION=$(zenity --list --title="Kalki OS System Restore" \
        --column="Action" --column="Description" \
        list "View available snapshots" "List and restore system snapshots" \
        create "Create a new system snapshot" \
        exit "Exit" \
        --height=250 --width=400)
    case "$ACTION" in
        list)
            list_snapshots
            ;;
        create)
            create_snapshot
            ;;
        exit|*)
            exit 0
            ;;
    esac
}

list_snapshots() {
    SNAPSHOTS=$($ROLLBACK_CLI list)
    if [[ -z "$SNAPSHOTS" ]]; then
        zenity --info --text="No snapshots found."
        main_menu
        return
    fi
    SNAP_ID=$(echo "$SNAPSHOTS" | zenity --list --title="Available Snapshots" --column="Snapshot" --height=400 --width=400)
    if [[ -z "${SNAP_ID:-}" ]]; then
        main_menu
        return
    fi
    if zenity --question --text="Restore snapshot: $SNAP_ID?\nThis will rollback your system. Continue?"; then
        if $ROLLBACK_CLI restore "$SNAP_ID" 2> >(zenity --error --text="Restore failed! See terminal for details."); then
            zenity --info --text="System rolled back to snapshot: $SNAP_ID. Please reboot."
        fi
    fi
    main_menu
}

create_snapshot() {
    DESC=$(zenity --entry --title="Create Snapshot" --text="Enter a description for the snapshot:")
    if [[ -z "${DESC:-}" ]]; then
        main_menu
        return
    fi
    if $ROLLBACK_CLI create "$DESC" 2> >(zenity --error --text="Snapshot creation failed! See terminal for details."); then
        zenity --info --text="Snapshot created successfully."
    fi
    main_menu
}

main_menu 