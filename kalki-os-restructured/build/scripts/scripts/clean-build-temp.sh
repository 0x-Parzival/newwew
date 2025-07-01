#!/bin/bash
# clean-build-temp.sh: Clean up temporary build files and directories
set -e
for d in work out kalki-build; do
  if [[ -d $d ]]; then
    echo "Removing $d..."
    rm -rf "$d"
  fi
done 