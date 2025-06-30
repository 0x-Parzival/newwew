#!/bin/bash
set -euo pipefail

# Kalki OS First Boot Wizard - Fully Automated
# Auto-launches, defaults to safe options, and minimizes user input

LOG_FILE="/var/log/first-boot-wizard.log"
VIDEO_FILE="/usr/share/kalki/avatarintro.mp4" # Placeholder path
AVATAR_LIST=(
  "🐭 Mushak - Debugger"
  "🐂 Nandi - Finance"
  "🐯 Shera - Security"
  "🐰 Bunni - Creative"
  "🐉 Kalkian - Dev Mode"
  "🐍 Nag - Strategy"
  "🐎 Chetak - Productivity"
  "🐐 G.O.A.T. - Music & Vibe"
  "🐒 Monki - Hinglish Fun"
  "🐓 Roosty - Scheduling"
  "🐕 Chew-Chew - Security Watchdog"
  "🐖 Chill Pig - Wellness"
)

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# 1. Prompt for install mode with timeout
INSTALL_MODE="dualboot" # Default
if command -v zenity &>/dev/null; then
  (sleep 30 && kill $$) &
  zenity --question --title="Kalki OS Setup" \
    --text="Welcome to Kalki OS!\n\nDo you want to replace your current OS or set up dual boot?\n\n(Default: Dual Boot in 30s)" \
    --ok-label="Replace OS" --cancel-label="Dual Boot" && INSTALL_MODE="replace"
else
  (sleep 30 && kill $$) &
  whiptail --title "Kalki OS Setup" --yesno "Do you want to replace your current OS?\nChoose No for Dual Boot.\n\n(Default: Dual Boot in 30s)" 10 60 && INSTALL_MODE="replace"
fi
log "User selected install mode: $INSTALL_MODE"

# 2. Play intro video and show progress bar overlay
if [ -f "$VIDEO_FILE" ]; then
  log "Playing intro video: $VIDEO_FILE"
  # Start AI installer in background with progress
  ( 
    /usr/share/kalki/ai-auto-installer.sh "$INSTALL_MODE" | while read -r line; do
      echo "$line"
    done
  ) &
  AI_PID=$!
  if command -v zenity &>/dev/null; then
    (sleep 2; zenity --progress --title="Kalki OS Installation" --text="Setting up your system..." --pulsate --auto-close --no-cancel) &
  fi
  mpv --fs --no-border --quiet "$VIDEO_FILE"
  wait $AI_PID || (zenity --error --text="Install failed. Click Retry." && exec "$0")
else
  log "Intro video not found: $VIDEO_FILE"
fi

# 3. Avatar selection menu with timeout
AVATAR=""
if command -v zenity &>/dev/null; then
  (sleep 30 && kill $$) &
  AVATAR=$(zenity --list --title="Choose Your AI Companion" --column="Avatar" "${AVATAR_LIST[@]}")
else
  (sleep 30 && kill $$) &
  AVATAR=$(whiptail --title "Choose Your AI Companion" --menu "Select your AI companion avatar:\n(Default: Random in 30s)" 20 60 12 \
    $(for i in "${AVATAR_LIST[@]}"; do echo "$i"; done) 3>&1 1>&2 2>&3)
fi
if [ -z "$AVATAR" ]; then
  AVATAR=${AVATAR_LIST[$((RANDOM % 12))]}
  log "No avatar selected, assigned random: $AVATAR"
else
  log "User selected avatar: $AVATAR"
fi

# TODO: Save avatar choice for user profile
# TODO: Integrate with real AI installer and video asset

log "First boot wizard complete." 