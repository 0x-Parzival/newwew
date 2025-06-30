#!/usr/bin/env python3
import subprocess, os, sys, json
from datetime import datetime

LOG_FILE = '/var/log/kalki-ai-installer.log'
PACKAGE_FILE = 'distro/profiles/kalki-ultimate/packages.x86_64'

# --- TinyLlama Integration ---
def call_tinyllama(prompt):
    """
    Call TinyLlama LLM for installation help.
    This is a placeholder: replace with your local TinyLlama API or CLI call.
    """
    # Example: local inference (replace with your actual call)
    # result = subprocess.getoutput(f"tinyllama --prompt '{prompt}'")
    # For now, just echo the prompt for demonstration
    return f"[TinyLlama Suggestion] {prompt}"

# --- Hardware Detection ---
def detect_hardware():
    info = {
        'cpu': subprocess.getoutput('lscpu'),
        'gpu': subprocess.getoutput('lspci | grep VGA'),
        'storage': subprocess.getoutput('lsblk'),
        'network': subprocess.getoutput('lspci | grep -i ethernet'),
        'wifi': subprocess.getoutput('lspci | grep -i wireless'),
        'boot_mode': 'UEFI' if os.path.exists('/sys/firmware/efi') else 'BIOS',
        'ram': subprocess.getoutput('free -h')
    }
    return info

# --- Compatibility Check ---
def check_compatibility(info):
    issues = []
    try:
        with open(PACKAGE_FILE) as f:
            pkgs = f.read()
    except Exception:
        pkgs = ''
    if 'NVIDIA' in info['gpu'] and 'nvidia' not in pkgs:
        issues.append('Missing NVIDIA driver')
    if info['boot_mode'] == 'UEFI' and 'efibootmgr' not in pkgs:
        issues.append('Missing efibootmgr for UEFI')
    # Add more checks as needed
    return issues

# --- Auto-Fix with TinyLlama ---
def autofix(issues, info):
    fixes = []
    for issue in issues:
        prompt = f"Device info: {json.dumps(info)}. Issue: {issue}. How to auto-fix for Arch Linux install?"
        suggestion = call_tinyllama(prompt)
        fixes.append({'issue': issue, 'suggestion': suggestion})
        # Example: auto-add package if suggested
        if 'NVIDIA' in issue and 'nvidia' not in open(PACKAGE_FILE).read():
            with open(PACKAGE_FILE, 'a') as f:
                f.write('\nnvidia nvidia-utils\n')
        if 'efibootmgr' in issue and 'efibootmgr' not in open(PACKAGE_FILE).read():
            with open(PACKAGE_FILE, 'a') as f:
                f.write('\nefibootmgr\n')
    return fixes

# --- Logging ---
def log_action(info, issues, fixes):
    with open(LOG_FILE, 'a') as log:
        log.write(f"\n[{datetime.now()}] Hardware: {json.dumps(info)}\n")
        log.write(f"Issues: {issues}\n")
        for fix in fixes:
            log.write(f"Fix: {fix['issue']} -> {fix['suggestion']}\n")

# --- Main ---
def main():
    info = detect_hardware()
    issues = check_compatibility(info)
    if issues:
        print('Detected issues:', issues)
        fixes = autofix(issues, info)
        log_action(info, issues, fixes)
        print('Auto-fixed issues with TinyLlama help. See log for details.')
        for fix in fixes:
            print(f"- {fix['issue']}: {fix['suggestion']}")
    else:
        print('No compatibility issues detected.')
        log_action(info, [], [])

if __name__ == '__main__':
    main() 