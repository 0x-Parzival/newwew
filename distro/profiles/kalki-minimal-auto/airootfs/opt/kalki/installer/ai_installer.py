#!/usr/bin/env python3
"""
Kalki OS AI Installation Assistant
Minimal AI that guides the installation process
"""

import os
import sys
import subprocess
import json
import time
from pathlib import Path

class KalkiInstaller:
    def __init__(self):
        self.install_config = {
            "install_type": None,  # "replace" or "dual_boot"
            "target_disk": None,
            "hostname": "kalki-minimal",
            "username": "kalki",
            "password": "kalki123"
        }
        
    def detect_hardware(self):
        """Detect system hardware and capabilities"""
        hardware_info = {
            "cpu_cores": os.cpu_count(),
            "ram_gb": round(os.sysconf('SC_PAGE_SIZE') * os.sysconf('SC_PHYS_PAGES') / (1024.**3)),
            "disks": self.get_available_disks(),
            "is_vm": self.detect_virtualization()
        }
        return hardware_info
    
    def get_available_disks(self):
        """Get list of available storage devices"""
        try:
            result = subprocess.run(['lsblk', '-J'], capture_output=True, text=True)
            data = json.loads(result.stdout)
            disks = []
            for device in data['blockdevices']:
                if device['type'] == 'disk':
                    disks.append({
                        'name': device['name'],
                        'size': device['size'],
                        'model': device.get('model', 'Unknown')
                    })
            return disks
        except:
            return [{'name': 'sda', 'size': '20G', 'model': 'Virtual Disk'}]
    
    def detect_virtualization(self):
        """Check if running in VM"""
        try:
            result = subprocess.run(['systemd-detect-virt'], capture_output=True, text=True)
            return result.returncode == 0 and result.stdout.strip() != 'none'
        except:
            return False
    
    def ai_decision_prompt(self, hardware_info):
        """AI-assisted decision making for installation"""
        print("🤖 Kalki AI Assistant: Analyzing your system...")
        time.sleep(2)
        
        print(f"\n🔍 System Analysis:")
        print(f"   CPU Cores: {hardware_info['cpu_cores']}")
        print(f"   RAM: {hardware_info['ram_gb']} GB")
        print(f"   Virtual Machine: {'Yes' if hardware_info['is_vm'] else 'No'}")
        print(f"   Available Disks: {len(hardware_info['disks'])}")
        
        for disk in hardware_info['disks']:
            print(f"     - {disk['name']}: {disk['size']} ({disk['model']})")
        
        print("\n🧠 AI Recommendation:")
        if hardware_info['is_vm']:
            print("   ✓ VM detected - Full disk installation recommended")
            print("   ✓ Hardware specs suitable for Hyprland")
            recommendation = "replace"
        else:
            print("   ⚠️  Physical hardware detected")
            print("   💡 Dual boot recommended for safety")
            recommendation = "dual_boot"
        
        return recommendation
    
    def get_user_choice(self, recommendation):
        """Get final installation choice from user"""
        print(f"\n🎯 Installation Options:")
        print(f"1. Replace entire disk (Recommended: {'✓' if recommendation == 'replace' else '⚠️'})")
        print(f"2. Dual boot setup (Recommended: {'✓' if recommendation == 'dual_boot' else '⚠️'})")
        
        while True:
            choice = input("\n🔮 Choose installation type (1/2): ").strip()
            if choice == "1":
                return "replace"
            elif choice == "2":
                return "dual_boot"
            else:
                print("❌ Please enter 1 or 2")
    
    def configure_installation(self, install_type, hardware_info):
        """Configure installation based on choices"""
        self.install_config["install_type"] = install_type
        
        if hardware_info['disks']:
            # Use first available disk
            self.install_config["target_disk"] = f"/dev/{hardware_info['disks'][0]['name']}"
        
        print(f"\n⚙️ Installation Configuration:")
        print(f"   Type: {install_type}")
        print(f"   Target: {self.install_config['target_disk']}")
        print(f"   Hostname: {self.install_config['hostname']}")
        print(f"   User: {self.install_config['username']}")
    
    def execute_installation(self):
        """Execute the actual installation"""
        print("\n🚀 Starting Kalki OS installation...")
        
        # Create installation script
        install_script = self.generate_install_script()
        
        script_path = "/tmp/kalki_install.sh"
        with open(script_path, 'w') as f:
            f.write(install_script)
        
        os.chmod(script_path, 0o755)
        
        print("📋 Installation script created")
        print("🔧 Executing installation...")
        
        # In a real implementation, this would execute the script
        # For now, just show what would happen
        print("⏳ This would now install Kalki OS...")
        print("✅ Installation would complete successfully!")
    
    def generate_install_script(self):
        """Generate bash installation script"""
        config = self.install_config
        
        if config["install_type"] == "replace":
            partition_commands = f"""
# Full disk installation
parted {config['target_disk']} mklabel gpt
parted {config['target_disk']} mkpart primary fat32 1MiB 512MiB
parted {config['target_disk']} set 1 esp on
parted {config['target_disk']} mkpart primary ext4 512MiB 100%

# Format partitions
mkfs.fat -F32 {config['target_disk']}1
mkfs.ext4 {config['target_disk']}2

# Mount partitions
mount {config['target_disk']}2 /mnt
mkdir -p /mnt/boot
mount {config['target_disk']}1 /mnt/boot
"""
        else:  # dual_boot
            partition_commands = """
# Dual boot setup (simplified - would need more logic)
echo "Creating minimal partition for Kalki OS..."
parted {config['target_disk']} mkpart primary ext4 50% 100%
mkfs.ext4 {config['target_disk']}3
mount {config['target_disk']}3 /mnt
""".format(config=config)
        
        return f"""#!/bin/bash
set -e

echo "🕉️ Kalki OS Installation Script"

{partition_commands}

# Install base system
pacstrap /mnt base linux-zen linux-firmware

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot and configure
arch-chroot /mnt bash -c "
    # Set timezone
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime
    hwclock --systohc
    
    # Locale
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
    locale-gen
    echo 'LANG=en_US.UTF-8' > /etc/locale.conf
    
    # Hostname
    echo '{config['hostname']}' > /etc/hostname
    
    # Create user
    useradd -m -G wheel -s /bin/bash {config['username']}
    echo '{config['username']}:{config['password']}' | chpasswd
    echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
    
    # Install bootloader
    pacman -S --noconfirm grub efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=KALKI
    grub-mkconfig -o /boot/grub/grub.cfg
    
    # Install Hyprland and essentials
    pacman -S --noconfirm hyprland waybar kitty networkmanager
    systemctl enable NetworkManager
"

echo "✅ Kalki OS installation completed!"
"""
    
    def run(self):
        """Main installation workflow"""
        print("🕉️ Welcome to Kalki OS Auto-Installer")
        print("🤖 AI Assistant will guide your installation\n")
        
        # Detect hardware
        hardware_info = self.detect_hardware()
        
        # AI recommendation
        recommendation = self.ai_decision_prompt(hardware_info)
        
        # Get user choice
        install_type = self.get_user_choice(recommendation)
        
        # Configure installation
        self.configure_installation(install_type, hardware_info)
        
        # Confirm and execute
        confirm = input("\n🎯 Proceed with installation? (y/N): ").strip().lower()
        if confirm == 'y':
            self.execute_installation()
        else:
            print("❌ Installation cancelled")

if __name__ == "__main__":
    installer = KalkiInstaller()
    installer.run()
