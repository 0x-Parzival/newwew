#!/bin/bash
# suggest-dependencies.sh: Scan scripts for missing dependencies and auto-append to check-dependencies.sh
# Usage: bash scripts/suggest-dependencies.sh
set -euo pipefail

CHECK_SCRIPT="$(dirname "$0")/check-dependencies.sh"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# 1. Gather all packages/commands from scripts
found_pkgs=()
found_cmds=()

# Scan for package install commands
while IFS= read -r file; do
  # pacman -S
  grep -Eo 'pacman -S[yu]* ([^&;]+)' "$file" | awk '{for(i=3;i<=NF;++i)print $i}' | tr -d '\n' | tr ' ' '\n' | grep -v '^$' | while read -r pkg; do
    found_pkgs+=("$pkg")
  done
  # apt install
  grep -Eo 'apt(itude)? install ([^&;]+)' "$file" | awk '{for(i=3;i<=NF;++i)print $i}' | tr -d '\n' | tr ' ' '\n' | grep -v '^$' | while read -r pkg; do
    found_pkgs+=("$pkg")
  done
  # dnf install
  grep -Eo 'dnf install ([^&;]+)' "$file" | awk '{for(i=3;i<=NF;++i)print $i}' | tr -d '\n' | tr ' ' '\n' | grep -v '^$' | while read -r pkg; do
    found_pkgs+=("$pkg")
  done
  # zypper install
  grep -Eo 'zypper install ([^&;]+)' "$file" | awk '{for(i=3;i<=NF;++i)print $i}' | tr -d '\n' | tr ' ' '\n' | grep -v '^$' | while read -r pkg; do
    found_pkgs+=("$pkg")
  done
  # direct binary usage (e.g., command -v, or direct calls)
  grep -Eo 'command -v [^ ]+' "$file" | awk '{print $3}' | while read -r cmd; do
    found_cmds+=("$cmd")
  done
  grep -Eo '\n([a-zA-Z0-9_-]+) ' "$file" | awk '{print $1}' | grep -vE '^(if|then|else|fi|for|do|done|while|case|esac|function|echo|exit|return|sudo|bash|sh|cd|rm|cp|mv|cat|grep|awk|sed|export|set|true|false|break|continue|read|printf|test|wait|trap|shift|local|declare|let|eval|exec|pwd|dirname|basename|cut|head|tail|sort|uniq|tr|tee|yes|sleep|date|time|find|xargs|diff|patch|ln|ls|chmod|chown|touch|which|whoami|id|groups|ps|kill|killall|jobs|fg|bg|history|clear|reset|su|login|logout|passwd|man|info|whatis|apropos|whereis|locate|updatedb|df|du|mount|umount|sync|dmesg|lsblk|blkid|fdisk|mkfs|fsck|dd|parted|partprobe|losetup|mkswap|swapon|swapoff|free|vmstat|iostat|mpstat|top|htop|iotop|lsof|strace|ltrace|gdb|valgrind|perf|systemctl|journalctl|service|init|telinit|runlevel|reboot|shutdown|poweroff|halt|sync|logger|crontab|at|batch|anacron|systemd-analyze|systemd-cgls|systemd-cgtop|systemd-escape|systemd-inhibit|systemd-machine-id-setup|systemd-notify|systemd-sysusers|systemd-tmpfiles|systemd-tty-ask-password-agent|loginctl|machinectl|hostnamectl|timedatectl|localectl|bootctl|kernel-install|networkctl|resolvectl|timedatectl|hwclock|chroot|mkinitcpio|dracut|update-initramfs|depmod|modprobe|lsmod|insmod|rmmod|modinfo|uname|lsusb|lspci|lsdev|lshw|dmidecode|inxi|hwinfo|hdparm|smartctl|lsscsi|lsattr|chattr|lslocks|lsns|lsipc|lslogins|lsmem|lsmod|lsusb|lspci|lsblk|blkid|fdisk|cfdisk|sfdisk|parted|partprobe|losetup|mkswap|swapon|swapoff|free|vmstat|iostat|mpstat|top|htop|iotop|lsof|strace|ltrace|gdb|valgrind|perf|systemctl|journalctl|service|init|telinit|runlevel|reboot|shutdown|poweroff|halt|sync|logger|crontab|at|batch|anacron|systemd-analyze|systemd-cgls|systemd-cgtop|systemd-escape|systemd-inhibit|systemd-machine-id-setup|systemd-notify|systemd-sysusers|systemd-tmpfiles|systemd-tty-ask-password-agent|loginctl|machinectl|hostnamectl|timedatectl|localectl|bootctl|kernel-install|networkctl|resolvectl|timedatectl|hwclock|chroot|mkinitcpio|dracut|update-initramfs|depmod|modprobe|lsmod|insmod|rmmod|modinfo|uname|lsusb|lspci|lsdev|lshw|dmidecode|inxi|hwinfo|hdparm|smartctl|lsscsi|lsattr|chattr|lslocks|lsns|lsipc|lslogins|lsmem|lsmod|lsusb|lspci|lsblk|blkid|fdisk|cfdisk|sfdisk|parted|partprobe|losetup|mkswap|swapon|swapoff|free|vmstat|iostat|mpstat|top|htop|iotop|lsof|strace|ltrace|gdb|valgrind|perf|systemctl|journalctl|service|init|telinit|runlevel|reboot|shutdown|poweroff|halt|sync|logger|crontab|at|batch|anacron|systemd-analyze|systemd-cgls|systemd-cgtop|systemd-escape|systemd-inhibit|systemd-machine-id-setup|systemd-notify|systemd-sysusers|systemd-tmpfiles|systemd-tty-ask-password-agent|loginctl|machinectl|hostnamectl|timedatectl|localectl|bootctl|kernel-install|networkctl|resolvectl|timedatectl|hwclock|chroot|mkinitcpio|dracut|update-initramfs|depmod|modprobe|lsmod|insmod|rmmod|modinfo|uname|lsusb|lspci|lsdev|lshw|dmidecode|inxi|hwinfo|hdparm|smartctl|lsscsi|lsattr|chattr|lslocks|lsns|lsipc|lslogins|lsmem|lsmod|lsusb|lspci|lsblk|blkid|fdisk|cfdisk|sfdisk|parted|partprobe|losetup|mkswap|swapon|swapoff|free|vmstat|iostat|mpstat|top|htop|iotop|lsof|strace|ltrace|gdb|valgrind|perf)$' | sort -u | while read -r cmd; do
    found_cmds+=("$cmd")
  done

done < <(find "$PROJECT_ROOT" -type f -name '*.sh')

# Deduplicate
found_pkgs=("$(printf "%s\n" "${found_pkgs[@]}" | sort -u)")
found_cmds=("$(printf "%s\n" "${found_cmds[@]}" | sort -u)")

# 2. Read current dependencies from check-dependencies.sh
current_pkgs=($(grep '^  [^# ]' "$CHECK_SCRIPT" | grep -v 'REQUIRED_CMDS' | tr -d '"' | tr -d ' '))
current_cmds=($(grep '^  [^# ]' "$CHECK_SCRIPT" | grep -A100 'REQUIRED_CMDS=(' | grep -v 'REQUIRED_CMDS' | tr -d '"' | tr -d ' '))

# 3. Find missing
missing_pkgs=()
for pkg in "${found_pkgs[@]}"; do
  if [[ ! " ${current_pkgs[@]} " =~ " $pkg " ]]; then
    missing_pkgs+=("$pkg")
  fi

done
missing_cmds=()
for cmd in "${found_cmds[@]}"; do
  if [[ ! " ${current_cmds[@]} " =~ " $cmd " ]]; then
    missing_cmds+=("$cmd")
  fi
done

# 4. Append missing to check-dependencies.sh
if (( ${#missing_pkgs[@]} > 0 )); then
  echo -e "\n# [AUTO-ADDED] The following packages were detected as used in scripts but not listed above. Please review:" >> "$CHECK_SCRIPT"
  for pkg in "${missing_pkgs[@]}"; do
    echo "  $pkg" >> "$CHECK_SCRIPT"
  done
fi
if (( ${#missing_cmds[@]} > 0 )); then
  echo -e "\n# [AUTO-ADDED] The following commands were detected as used in scripts but not listed above. Please review:" >> "$CHECK_SCRIPT"
  for cmd in "${missing_cmds[@]}"; do
    echo "  $cmd" >> "$CHECK_SCRIPT"
  done
fi

# 5. Print summary
if (( ${#missing_pkgs[@]} > 0 )) || (( ${#missing_cmds[@]} > 0 )); then
  echo "\n[INFO] The following dependencies were auto-appended to $CHECK_SCRIPT:"
  for pkg in "${missing_pkgs[@]}"; do
    echo "  - Package: $pkg"
  done
  for cmd in "${missing_cmds[@]}"; do
    echo "  - Command: $cmd"
  done
else
  echo "No new dependencies detected. $CHECK_SCRIPT is up to date."
fi 