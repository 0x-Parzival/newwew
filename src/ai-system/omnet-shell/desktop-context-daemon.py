#!/usr/bin/env python3
import subprocess
import time
import json
import os

CONTEXT_FILE = os.path.expanduser("~/.config/omnet-shell/desktop-context.json")
INTERVAL = 5  # seconds

def get_active_window():
    try:
        win_id = subprocess.check_output(["xprop", "-root", "_NET_ACTIVE_WINDOW"]).decode()
        win_id = win_id.strip().split()[-1]
        if win_id == '0x0':
            return None
        win_info = subprocess.check_output(["xprop", "-id", win_id]).decode()
        for line in win_info.splitlines():
            if line.startswith("WM_CLASS"):  # e.g. WM_CLASS(STRING) = "okular", "Okular"
                return line.split('=')[1].strip().strip('"')
        return None
    except Exception:
        return None

def get_open_windows():
    try:
        output = subprocess.check_output(["wmctrl", "-l"]).decode()
        windows = []
        for line in output.splitlines():
            parts = line.split(None, 3)
            if len(parts) == 4:
                windows.append({"id": parts[0], "desktop": parts[1], "host": parts[2], "title": parts[3]})
        return windows
    except Exception:
        return []

def summarize_context():
    active = get_active_window()
    windows = get_open_windows()
    context = {
        "active_window": active,
        "open_windows": windows,
        "timestamp": time.time()
    }
    return context

def main():
    os.makedirs(os.path.dirname(CONTEXT_FILE), exist_ok=True)
    while True:
        context = summarize_context()
        with open(CONTEXT_FILE, "w") as f:
            json.dump(context, f, indent=2)
        time.sleep(INTERVAL)

if __name__ == "__main__":
    main() 