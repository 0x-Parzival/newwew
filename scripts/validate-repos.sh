#!/bin/bash
# validate-repos.sh: Check custom package repository availability for Kalki OS
set -euo pipefail

REPOS=()
# Main repo from env
if [[ -n "${REPO_URL:-}" ]]; then
  REPOS+=("$REPO_URL")
fi
# Optional mirrors (comma-separated)
if [[ -n "${REPO_MIRRORS:-}" ]]; then
  IFS=',' read -ra MIRRORS <<< "$REPO_MIRRORS"
  for m in "${MIRRORS[@]}"; do
    REPOS+=("$m")
  done
fi

if (( ${#REPOS[@]} == 0 )); then
  echo "[INFO] No custom repositories specified. Skipping repo validation."
  exit 0
fi

fail=0
for repo in "${REPOS[@]}"; do
  echo "[INFO] Checking repository: $repo"
  if ! curl -Is "$repo" | grep -q "200"; then
    echo "[ERROR] Repository $repo is not reachable!"
    fail=1
  fi
  sleep 1
 done

if (( fail )); then
  echo "[ERROR] One or more repositories are not reachable. Fix before building."
  exit 1
else
  echo "[OK] All repositories are reachable."
fi 