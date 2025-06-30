#!/usr/bin/env python3
import json
import os
import time
import subprocess

CONTEXT_FILE = os.path.expanduser("~/.config/omnet-shell/desktop-context.json")
INTERVAL = 5  # seconds

# Avatar triggers: map app keywords to avatar recommendations
AVATAR_TRIGGERS = [
    ("libreoffice", "🐰 Bunni", "I see you're working on a document. Need help with writing or formatting?"),
    ("okular", "🐯 Shera", "You're reading a PDF. Want me to check for security risks or summarize?"),
    ("firefox", "🐒 Monki", "Browsing the web? I can help with search, translation, or fun facts!"),
    ("terminal", "🐉 Kalkian", "Working in the terminal? I can automate commands or scripts for you."),
    ("music", "🐐 G.O.A.T.", "Listening to music? Want to generate a playlist or mood board?"),
    ("code", "🐭 Mushak", "Coding detected! Need debugging or code suggestions?"),
    ("settings", "🐍 Nag", "Tweaking system settings? I can recommend optimizations."),
    ("calendar", "🐓 Roosty", "Scheduling something? I can help you plan and remind you."),
    ("security", "🐕 Chew-Chew", "Security app open. Want a quick system scan?"),
    ("finance", "🐂 Nandi", "Managing finances? I can help with calculations or crypto."),
    ("productivity", "🐎 Chetak", "Productivity tools detected. Want to optimize your workflow?"),
    ("wellness", "🐖 Chill Pig", "Taking a break? I can guide a quick meditation or wellness tip."),
]

# Use notify-send for right-bottom notification (requires a notification daemon)
def send_notification(avatar, message):
    subprocess.run([
        "notify-send",
        "-u", "normal",
        "-t", "8000",
        "-h", "string:x-canonical-private-synchronous:omnet-avatar-recommend",
        "-h", "int:transient:1",
        "-h", "string:desktop-entry:omnet-shell",
        "-h", "string:urgency:normal",
        "-h", "string:category:recommendation",
        "-h", "string:position:bottom-right",
        f"{avatar} recommends:",
        message
    ])

last_active = None

def main():
    global last_active
    while True:
        if os.path.exists(CONTEXT_FILE):
            with open(CONTEXT_FILE) as f:
                context = json.load(f)
            active = context.get("active_window", "").lower() if context.get("active_window") else ""
            if active and active != last_active:
                for keyword, avatar, msg in AVATAR_TRIGGERS:
                    if keyword in active:
                        send_notification(avatar, msg)
                        last_active = active
                        break
        time.sleep(INTERVAL)

if __name__ == "__main__":
    main() 