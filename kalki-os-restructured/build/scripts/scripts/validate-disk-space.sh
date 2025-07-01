#!/bin/bash
# validate-disk-space.sh: Check for sufficient disk space for build
set -e
DIR="${1:-/}"
REQUIRED_GB=8
FREE_GB=$(df -BG "$DIR" | awk 'NR==2 {gsub("G", "", $4); print $4}')
if (( FREE_GB < REQUIRED_GB )); then
  echo "❌ Only ${FREE_GB}GB free in $DIR. At least ${REQUIRED_GB}GB required."
  exit 1
else
  echo "✅ Sufficient disk space: ${FREE_GB}GB free in $DIR."
fi 