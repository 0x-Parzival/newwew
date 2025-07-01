#!/usr/bin/env python3
import tkinter as tk
from tkinter import scrolledtext, messagebox
import subprocess, threading, os

LOG_FILE = '/var/log/kalki-ai-installer.log'
AI_INSTALLER = os.path.join(os.path.dirname(__file__), 'ai-auto-installer.py')

class FirstBootWizardGUI(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title('Kalki OS First Boot Wizard')
        self.geometry('700x500')
        self.resizable(False, False)
        self.create_widgets()
        self.protocol("WM_DELETE_WINDOW", self.on_close)
        self.run_ai_installer()

    def create_widgets(self):
        self.label = tk.Label(self, text="Welcome to Kalki OS!\nChecking your system for compatibility...", font=("Arial", 14))
        self.label.pack(pady=10)
        self.text = scrolledtext.ScrolledText(self, width=80, height=20, state='disabled', font=("Consolas", 10))
        self.text.pack(padx=10, pady=10)
        self.proceed_btn = tk.Button(self, text="Proceed with Setup", state='disabled', command=self.proceed)
        self.proceed_btn.pack(pady=10)

    def run_ai_installer(self):
        def task():
            if os.path.exists(AI_INSTALLER):
                self.append_text("[Kalki AI Installer] Running hardware compatibility check and auto-fix...\n")
                proc = subprocess.Popen(['python3', AI_INSTALLER], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
                for line in proc.stdout:
                    self.append_text(line)
                proc.wait()
                self.append_text("\n[Kalki AI Installer] Compatibility check complete.\n")
                self.proceed_btn.config(state='normal')
            else:
                self.append_text("[Kalki AI Installer] ai-auto-installer.py not found, skipping AI compatibility check.\n")
                self.proceed_btn.config(state='normal')
        threading.Thread(target=task, daemon=True).start()

    def append_text(self, msg):
        self.text.config(state='normal')
        self.text.insert(tk.END, msg)
        self.text.see(tk.END)
        self.text.config(state='disabled')

    def proceed(self):
        messagebox.showinfo("Kalki OS", "Continuing with first boot setup...\n(Continue onboarding here)")
        self.destroy()

    def on_close(self):
        if messagebox.askokcancel("Quit", "Are you sure you want to exit the setup?"):
            self.destroy()

if __name__ == '__main__':
    app = FirstBootWizardGUI()
    app.mainloop() 