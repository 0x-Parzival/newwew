#!/bin/bash
# Kalki OS First Boot Wizard (Avatar Onboarding)
set -euo pipefail

CONFIG_DIR="$HOME/.config"
CONFIG_FILE="$CONFIG_DIR/kalki-onboarding.json"
AUTOSTART_ENTRY="$HOME/.config/autostart/kalki-first-boot-wizard.desktop"

# Avatar data
AVATAR_NAMES=(
  "Mushak" "Nandi" "Shera" "Bunni" "Kalkian" "Nag" "Chetak" "G.O.A.T." "Monki" "Roosty" "Chew-Chew" "The Chill Pig"
)
AVATAR_ICONS=(
  "🐭" "🐂" "🐯" "🐰" "🐉" "🐍" "🐎" "🐐" "🐒" "🐓" "🐕" "🐖"
)
AVATAR_ROLES=(
  "Debugger of Chaos"
  "Financial Guardian"
  "Cybersecurity Sentinel"
  "Creative Companion"
  "Divine Developer Mode"
  "Strategist & Analyst"
  "Productivity Commander"
  "Vibes & Design Wizard"
  "Gesture + Hinglish Agent"
  "Scheduler & Timekeeper"
  "Security Watchdog"
  "Mood & Wellness Guide"
)
AVATAR_GREETINGS=(
  "Yo! I already found 3 bugs before you even booted. Ready to squash some chaos?"
  "Your wealth stands strong. Markets synced. Portfolios protected. Let's keep it stable."
  "No intruder shall pass. Your firewalls are fortified. I'm watching everything."
  "Let's make something beautiful today — words, code, or art. I've got palettes preloaded!"
  "You are now in divine dev mode. Command wisely, for all power is yours."
  "Every move matters. I've calculated your optimal flow. Proceed when ready."
  "Time's racing, and so are we. I've queued your tasks and mapped your sprint. Let's ride!"
  "Vibes are optimal. Fonts are fresh. Beats are synced. Let's create some GOAT-level work."
  "Oye bro! No typing, just vibing. Wink, wave, or say the word — Monki's got you."
  "Rise and sync! All tasks aligned. You've got 3 goals, 2 meetings, and 1 perfect day."
  "System perimeter clear. No threats sniffed. Chew-Chew on duty, as always."
  "Breathe in. Breathe out. Your mind is a temple. Let's work... but not burn out."
)

# Welcome dialog
zenity --info --title="Welcome to Kalki OS!" --width=400 --text="\
Welcome to Kalki OS — your AI-powered, modular, privacy-focused Linux experience!\n\nLet's get you set up with your own AI companion and show you the best features.\n\n(You can skip onboarding at any time.)"
if [[ $? -ne 0 ]]; then exit 0; fi

# Feature highlights
zenity --info --title="Kalki OS Features" --width=400 --text="\
• 12 unique AI avatars, each with a special role\n• Proactive AI help, automation, and natural language commands\n• Instant system rollback & recovery\n• Privacy-first controls\n• Beautiful, modern UI\n• App store with best-in-class tools\n\nLet's pick your AI companion!"
if [[ $? -ne 0 ]]; then exit 0; fi

# Avatar selection
AVATAR_LIST=""
for i in "${!AVATAR_NAMES[@]}"; do
  AVATAR_LIST+="${AVATAR_ICONS[$i]} ${AVATAR_NAMES[$i]} — ${AVATAR_ROLES[$i]}\n"
done
AVATAR_CHOICE=$(zenity --list --title="Choose Your AI Avatar" --column="Avatar" --width=500 --height=400 \
  $(for i in "${!AVATAR_NAMES[@]}"; do echo "${AVATAR_ICONS[$i]} ${AVATAR_NAMES[$i]} — ${AVATAR_ROLES[$i]}"; done))
if [[ $? -ne 0 || -z "${AVATAR_CHOICE:-}" ]]; then exit 0; fi

# Show greeting for selected avatar
for i in "${!AVATAR_NAMES[@]}"; do
  if [[ "$AVATAR_CHOICE" == "${AVATAR_ICONS[$i]} ${AVATAR_NAMES[$i]} — ${AVATAR_ROLES[$i]}" ]]; then
    AVATAR_SELECTED="${AVATAR_NAMES[$i]}"
    AVATAR_GREETING="${AVATAR_GREETINGS[$i]}"
    break
  fi
done
zenity --info --title="${AVATAR_SELECTED} says hi!" --width=400 --text="${AVATAR_GREETING}"
if [[ $? -ne 0 ]]; then exit 0; fi

# Privacy and snapshot options
zenity --question --title="Enable Privacy Mode?" --width=400 --text="\
Kalki OS can maximize your privacy by restricting telemetry, disabling cloud sync, and sandboxing AI features.\n\nEnable Privacy Mode? (Recommended)"
PRIVACY_ENABLED=$?
zenity --question --title="Enable Auto-Snapshots?" --width=400 --text="\
Kalki OS can automatically create system snapshots before major changes, so you can always roll back.\n\nEnable Auto-Snapshots? (Recommended)"
SNAPSHOT_ENABLED=$?

# Save config
mkdir -p "$CONFIG_DIR"
cat > "$CONFIG_FILE" <<EOF
{
  "avatar": "$AVATAR_SELECTED",
  "privacy_mode": $([[ $PRIVACY_ENABLED -eq 0 ]] && echo true || echo false),
  "auto_snapshots": $([[ $SNAPSHOT_ENABLED -eq 0 ]] && echo true || echo false)
}
EOF

# Goodbye
zenity --info --title="All set!" --width=400 --text="\
You're ready to experience Kalki OS.\n\nYou can change your avatar or settings anytime in System Settings.\n\nCheck out the handbook for tips, and enjoy your new OS!"

# Remove from autostart
rm -f "$AUTOSTART_ENTRY"

exit 0 