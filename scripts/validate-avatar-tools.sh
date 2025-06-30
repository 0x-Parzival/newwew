#!/bin/bash
# validate-avatar-tools.sh: Validate avatar tool directories and main tool files

AVATARS=(mushak bunni nandi shera)
TOOLS_ROOT="/opt/kalki/avatars/tools"

all_ok=1

for avatar in "${AVATARS[@]}"; do
  dir="$TOOLS_ROOT/$avatar"
  tool_file="$dir/${avatar}_tools.py"
  if [[ ! -d "$dir" ]]; then
    echo "❌ Missing tool directory: $dir"
    all_ok=0
    continue
  fi
  if [[ ! -f "$tool_file" ]]; then
    echo "❌ Missing main tool file in $dir"
    all_ok=0
    continue
  fi
  echo "✅ Validated tools for: $avatar"
done

if [[ $all_ok -eq 1 ]]; then
  echo "All avatar tools validated successfully."
else
  echo "Some avatar tools are missing or incomplete."
fi 