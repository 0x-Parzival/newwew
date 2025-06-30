#!/bin/bash
# check-custom-lock.sh: Check/install pinned custom package versions
set -euo pipefail
LOCKFILE="custom-packages.lock"
if [[ ! -f $LOCKFILE ]]; then
  echo "[INFO] No custom-packages.lock found. Skipping custom package check."
  exit 0
fi
fail=0
while read -r line; do
  [[ -z "$line" || "$line" =~ ^# ]] && continue
  name=$(echo $line | awk '{print $1}')
  ver=$(echo $line | awk '{print $2}')
  repo=$(echo $line | awk '{print $3}')
  inst_ver=$(pacman -Q $name 2>/dev/null | awk '{print $2}')
  if [[ -z "$inst_ver" ]]; then
    echo "[WARN] $name not installed. To install: sudo pacman -S $name"
    fail=1
  elif [[ "$inst_ver" != "$ver" ]]; then
    echo "[WARN] $name version mismatch: installed $inst_ver, expected $ver"
    fail=1
  fi
done < "$LOCKFILE"
if (( fail )); then
  echo "[ERROR] Custom package version check failed. Fix above issues."
  exit 1
else
  echo "[OK] All custom packages match lockfile."
fi 