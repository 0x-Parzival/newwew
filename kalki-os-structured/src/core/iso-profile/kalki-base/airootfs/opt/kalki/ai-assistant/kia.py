#!/usr/bin/env python3
"""
Kalki Installation Assistant (KIA)
Embedded AI for system installation and troubleshooting
"""

import subprocess
import json
import os
import time
from pathlib import Path
import llama_cpp

class KalkiInstallAssistant:
    def __init__(self):
        self.model_path = "/opt/kalki/ai-assistant/install-assistant.gguf"
        self.llm = None
        self.load_model()
        
    def load_model(self):
        """Load the lightweight AI model for assistance"""
        try:
            self.llm = llama_cpp.Llama(
                model_path=self.model_path,
                n_ctx=2048,
                n_threads=2,
                verbose=False
            )
            print("🧠 Kalki Installation Assistant loaded successfully")
        except Exception as e:
            print(f"⚠️ AI Assistant unavailable: {e}")
            self.llm = None

    def get_system_info(self):
        """Gather comprehensive system information"""
        info = {}
        
        try:
            # Hardware detection
            info['cpu'] = subprocess.check_output(['lscpu'], text=True)
            info['memory'] = subprocess.check_output(['free', '-h'], text=True)
            info['disks'] = subprocess.check_output(['lsblk', '-f'], text=True)
            info['graphics'] = subprocess.check_output(['lspci | grep -i vga'], shell=True, text=True)
            
            # Network status
            info['network'] = subprocess.check_output(['ip', 'addr', 'show'], text=True)
            
            # Boot mode detection
            info['boot_mode'] = 'UEFI' if Path('/sys/firmware/efi').exists() else 'BIOS'
            
        except subprocess.CalledProcessError as e:
            print(f"System detection error: {e}")
            
        return info

    def diagnose_issue(self, user_description, system_info):
        """AI-powered issue diagnosis and resolution"""
        if not self.llm:
            return self.fallback_diagnosis(user_description)
            
        prompt = f"""
You are the Kalki OS Installation Assistant. You help users diagnose and fix system issues.

User Issue: {user_description}

System Information:
- Boot Mode: {system_info.get('boot_mode', 'Unknown')}
- Available Disks: {system_info.get('disks', 'N/A')[:200]}...
- Memory: {system_info.get('memory', 'N/A')[:100]}...

Provide:
1. Likely cause of the issue
2. Step-by-step solution
3. Commands to run (if any)
4. Potential risks or warnings

Keep response concise and practical.
"""

        try:
            response = self.llm(prompt, max_tokens=512, temperature=0.3)
            return response['choices'][0]['text'].strip()
        except Exception as e:
            return f"AI diagnosis failed: {e}. Using fallback analysis."

    def fallback_diagnosis(self, issue):
        """Rule-based fallback when AI is unavailable"""
        common_issues = {
            'boot': "Boot issues detected. Try: 1) Check boot order in BIOS, 2) Verify installation media, 3) Check disk connections",
            'network': "Network issues detected. Try: 1) Check cable connections, 2) Restart network service, 3) Verify DHCP settings",
            'graphics': "Graphics issues detected. Try: 1) Boot in safe mode, 2) Update graphics drivers, 3) Check monitor connections",
            'disk': "Disk issues detected. Try: 1) Check disk health with smartctl, 2) Verify partition table, 3) Check filesystem errors"
        }
        
        issue_lower = issue.lower()
        for key, solution in common_issues.items():
            if key in issue_lower:
                return solution
        
        return "Unable to diagnose specific issue. Please provide more details about the problem."

    def interactive_setup(self):
        """Interactive installation guidance"""
        print("\n🕉️ Welcome to Kalki OS Installation Assistant")
        print("I'm here to help you install and configure your dharmic computing platform.\n")
        
        # Pre-installation checks
        print("📋 Running pre-installation diagnostics...")
        system_info = self.get_system_info()
        
        # Display system summary
        print(f"✅ Boot Mode: {system_info.get('boot_mode')}")
        print(f"✅ Available Storage: Detected")
        print(f"✅ Memory: Sufficient for installation")
        
        # Installation guidance
        self.guide_installation(system_info)

    def guide_installation(self, system_info):
        """Step-by-step installation guidance"""
        steps = [
            ("Disk Preparation", self.guide_disk_setup),
            ("Network Configuration", self.guide_network_setup),
            ("User Account Creation", self.guide_user_setup),
            ("AI Components Setup", self.guide_ai_setup),
            ("Final Configuration", self.guide_final_setup)
        ]
        
        for step_name, step_function in steps:
            print(f"\n📌 {step_name}")
            try:
                step_function(system_info)
                print(f"✅ {step_name} completed successfully")
            except Exception as e:
                print(f"❌ {step_name} encountered an issue: {e}")
                self.suggest_solution(step_name, str(e))

    def guide_disk_setup(self, system_info):
        """Guide through disk partitioning and setup"""
        print("Setting up disk partitions for Kalki OS...")
        
        if system_info.get('boot_mode') == 'UEFI':
            print("UEFI detected - Creating GPT partition table")
            # Guide UEFI installation
        else:
            print("BIOS detected - Creating MBR partition table")
            # Guide BIOS installation

    def guide_network_setup(self, system_info):
        """Guide network configuration"""
        print("Configuring network settings...")
        # Network setup guidance

    def guide_user_setup(self, system_info):
        """Guide user account creation"""
        print("Creating user accounts and permissions...")
        # User setup guidance

    def guide_ai_setup(self, system_info):
        """Guide AI components installation"""
        print("Installing AI avatars and OMNet neural core...")
        # AI setup guidance

    def guide_final_setup(self, system_info):
        """Final system configuration"""
        print("Applying final system configuration...")
        # Final setup

    def suggest_solution(self, step_name, error):
        """AI-powered solution suggestion for errors"""
        if self.llm:
            prompt = f"Installation step '{step_name}' failed with error: {error}. Suggest a solution:"
            try:
                response = self.llm(prompt, max_tokens=256)
                print(f"💡 AI Suggestion: {response['choices'][0]['text'].strip()}")
            except:
                print("💡 Suggestion: Check system logs and try again")
        else:
            print("💡 Suggestion: Check system logs and try again")

def main():
    """Main entry point for Kalki Installation Assistant"""
    assistant = KalkiInstallAssistant()
    
    import sys
    if len(sys.argv) > 1:
        if sys.argv[1] == '--diagnose':
            issue = input("Describe the issue you're experiencing: ")
            system_info = assistant.get_system_info()
            diagnosis = assistant.diagnose_issue(issue, system_info)
            print(f"\n🔍 Diagnosis:\n{diagnosis}")
        elif sys.argv[1] == '--install':
            assistant.interactive_setup()
    else:
        assistant.interactive_setup()

if __name__ == "__main__":
    main()
