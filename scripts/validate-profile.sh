#!/bin/bash
# validate-profile.sh: Validate mkarchiso profile structure
set -e
PROFILE_DIR="${1:-iso-profile/kalki-base}"
REQUIRED_FILES=(profiledef.sh packages.x86_64 pacman.conf)
all_ok=1
for f in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$PROFILE_DIR/$f" ]]; then
    echo "❌ Missing $f in $PROFILE_DIR"
    all_ok=0
    # Optionally create sensible default
    if [[ "$f" == "profiledef.sh" ]]; then
      echo -e "# Minimal profiledef.sh\niso_name=\"kalki\"\narch=\"x86_64\"\n" > "$PROFILE_DIR/$f"
      echo "  -> Created default $f"
    elif [[ "$f" == "packages.x86_64" ]]; then
      echo -e "base\nlinux\nlinux-firmware" > "$PROFILE_DIR/$f"
      echo "  -> Created default $f"
    elif [[ "$f" == "pacman.conf" ]]; then
      echo -e "[options]\nHoldPkg = pacman glibc\nArchitecture = auto" > "$PROFILE_DIR/$f"
      echo "  -> Created default $f"
    fi
  else
    echo "✅ Found $f"
  fi
done
if [[ $all_ok -eq 1 ]]; then
  echo "Profile structure is valid."
else
  echo "Profile had missing files. Defaults created where possible."
fi
exit 0 