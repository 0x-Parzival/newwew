#!/bin/bash
# generate-avatars.sh: Generate avatar directories and default files

AVATAR_ROOT="$(dirname "$0")/avatars"
AVATAR_LIST=(
  "01-matsya"
  "02-kurma"
  "03-varaha"
  "04-narasimha"
  "05-vamana"
  "06-parashurama"
  "07-rama"
  "08-krishna"
  "09-buddha"
  "10-kalki"
  "11-hayagriva"
  "12-dhanvantari"
)

for avatar in "${AVATAR_LIST[@]}"; do
  AVATAR_DIR="$AVATAR_ROOT/$avatar"
  mkdir -p "$AVATAR_DIR/scripts"
  if [ ! -f "$AVATAR_DIR/config.json" ]; then
    cat > "$AVATAR_DIR/config.json" <<EOF
{
  "name": "$avatar",
  "personality": "",
  "llm": "Dolphin3",
  "intro": ""
}
EOF
  fi
  if [ ! -f "$AVATAR_DIR/avatar.txt" ]; then
    echo "$avatar avatar" > "$AVATAR_DIR/avatar.txt"
  fi
  if [ ! -f "$AVATAR_DIR/scripts/hello.sh" ]; then
    cat > "$AVATAR_DIR/scripts/hello.sh" <<EOF
#!/bin/bash
echo "Hello from $avatar!"
EOF
    chmod +x "$AVATAR_DIR/scripts/hello.sh"
  fi
done

echo "[generate-avatars.sh] Avatars generated." 