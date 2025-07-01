import tkinter as tk
from tkinter import ttk, filedialog, messagebox, scrolledtext
import subprocess
import threading
import os
import glob
import shlex
from PIL import Image, ImageTk
import platform

REQUIRED_FILES = [
    "setup-build-env.sh",
    "requirements-all.txt"
]
REQUIRED_DIRS = [
    "out", "work", "kalki-os/scripts", "iso-profile", "distro"
]

# Utility to find all build scripts
def find_build_scripts():
    scripts = {}
    for folder in ["kalki-os", "build", "."]:
        for path in glob.glob(os.path.join(folder, "*.sh")):
            name = os.path.basename(path)
            label = name.replace("build-","").replace(".sh","").replace("-iso","").replace("-", " ").title()
            scripts[label] = path
    return scripts

def is_arch_linux():
    return os.path.isfile("/etc/arch-release")

def has_docker():
    return subprocess.call(["which", "docker"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) == 0

def has_vagrant():
    return subprocess.call(["which", "vagrant"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) == 0

class BuildLauncher(tk.Tk):
    def __init__(self):
        super().__init__()
        self.withdraw()  # Hide main window until env check
        self.title("Kalki OS Build Launcher")
        self.geometry("950x800")
        self.resizable(True, True)
        self.configure(bg="#1a2233")  # Deep blue background
        self.build_process = None
        self.stop_requested = False
        self.build_scripts = find_build_scripts()
        self.style = ttk.Style(self)
        self.set_theme()
        if not is_arch_linux():
            self.show_env_choice()
        else:
            self.create_widgets()
            self.check_environment()
            self.deiconify()

    def set_theme(self):
        self.style.theme_use('clam')
        self.style.configure('TFrame', background='#1a2233')
        self.style.configure('TLabel', background='#1a2233', foreground='#f5c542', font=('Segoe UI', 11))
        self.style.configure('TButton', font=('Segoe UI', 10, 'bold'), padding=6)
        self.style.configure('TCheckbutton', background='#1a2233', foreground='#f5c542', font=('Segoe UI', 10))
        self.style.configure('TEntry', font=('Segoe UI', 10))
        self.style.configure('TCombobox', font=('Segoe UI', 10))
        self.style.configure('TLabelframe', background='#1a2233', foreground='#f5c542', font=('Segoe UI', 12, 'bold'))
        self.style.configure('TLabelframe.Label', background='#1a2233', foreground='#f5c542', font=('Segoe UI', 12, 'bold'))

    def create_widgets(self):
        # Banner/logo
        banner_frame = ttk.Frame(self)
        banner_frame.grid(row=0, column=0, columnspan=5, pady=(10, 0), sticky='ew')
        try:
            logo_img = Image.open("kalki-os/kalki-logo.png").resize((64, 64))
            self.logo = ImageTk.PhotoImage(logo_img)
            logo_label = tk.Label(banner_frame, image=self.logo, bg="#1a2233")
            logo_label.pack(side='left', padx=(10, 10))
        except Exception:
            logo_label = tk.Label(banner_frame, text="🕉️", font=("Segoe UI", 32), bg="#1a2233", fg="#f5c542")
            logo_label.pack(side='left', padx=(10, 10))
        title_label = tk.Label(banner_frame, text="Kalki OS Build Launcher", font=("Segoe UI", 24, "bold"), bg="#1a2233", fg="#f5c542")
        title_label.pack(side='left', padx=(10, 0))
        about_btn = ttk.Button(banner_frame, text="About", command=self.show_about)
        about_btn.pack(side='right', padx=(0, 10))

        # Environment Status
        status_frame = ttk.Labelframe(self, text="Environment Status")
        status_frame.grid(row=1, column=0, columnspan=5, padx=10, pady=10, sticky='ew')
        self.status_labels = {}
        row = 0
        for f in REQUIRED_FILES:
            lbl = ttk.Label(status_frame, text=f"{f}: ...")
            lbl.grid(row=row, column=0, sticky='w')
            self.status_labels[f] = lbl
            row += 1
        for d in REQUIRED_DIRS:
            lbl = ttk.Label(status_frame, text=f"{d}/: ...")
            lbl.grid(row=row, column=0, sticky='w')
            self.status_labels[d] = lbl
            row += 1
        self.env_ready_label = ttk.Label(status_frame, text="Checking environment...", foreground="#f5c542", font=('Segoe UI', 11, 'bold'))
        self.env_ready_label.grid(row=row, column=0, sticky='w')
        self.setup_btn = ttk.Button(status_frame, text="Run Environment Setup", command=self.run_setup_env)
        self.setup_btn.grid(row=row, column=1, padx=10)
        self.help_btn = ttk.Button(status_frame, text="Help", command=self.show_help)
        self.help_btn.grid(row=row, column=2, padx=10)

        # Build Options
        build_frame = ttk.Labelframe(self, text="Build Options")
        build_frame.grid(row=2, column=0, columnspan=5, padx=10, pady=10, sticky='ew')
        ttk.Label(build_frame, text="Build Type:").grid(row=0, column=0, padx=10, pady=10, sticky='w')
        self.build_type = tk.StringVar()
        self.build_type_menu = ttk.Combobox(build_frame, textvariable=self.build_type, values=list(self.build_scripts.keys()), state="readonly", width=30)
        self.build_type_menu.grid(row=0, column=1, padx=10, pady=10, sticky='w')
        if self.build_scripts:
            self.build_type.set(list(self.build_scripts.keys())[0])
        ttk.Label(build_frame, text="Output Directory:").grid(row=1, column=0, padx=10, pady=10, sticky='w')
        self.output_dir = tk.StringVar(value=os.path.abspath("out"))
        self.output_entry = ttk.Entry(build_frame, textvariable=self.output_dir, width=40)
        self.output_entry.grid(row=1, column=1, padx=10, pady=10, sticky='w')
        self.browse_btn = ttk.Button(build_frame, text="Browse", command=self.browse_output_dir)
        self.browse_btn.grid(row=1, column=2, padx=5, pady=10)
        self.open_out_btn = ttk.Button(build_frame, text="Open Output Dir", command=lambda: self.open_dir(self.output_dir.get()))
        self.open_out_btn.grid(row=1, column=3, padx=5, pady=10)
        self.open_work_btn = ttk.Button(build_frame, text="Open Work Dir", command=lambda: self.open_dir("work"))
        self.open_work_btn.grid(row=1, column=4, padx=5, pady=10)
        self.skip_validations = tk.BooleanVar(value=True)
        self.verbose = tk.BooleanVar(value=True)
        self.clean_build = tk.BooleanVar(value=False)
        ttk.Checkbutton(build_frame, text="Skip Validations", variable=self.skip_validations).grid(row=2, column=0, padx=10, pady=5, sticky='w')
        ttk.Checkbutton(build_frame, text="Verbose Output", variable=self.verbose).grid(row=2, column=1, padx=10, pady=5, sticky='w')
        ttk.Checkbutton(build_frame, text="Clean Build (remove out/work)", variable=self.clean_build).grid(row=2, column=2, padx=10, pady=5, sticky='w')

        # Advanced Options
        self.adv_frame = ttk.Labelframe(self, text="Advanced Options")
        self.adv_frame.grid(row=3, column=0, columnspan=5, padx=10, pady=5, sticky='ew')
        self.adv_shown = tk.BooleanVar(value=True)
        self.adv_toggle_btn = ttk.Button(self.adv_frame, text="Hide Advanced", command=self.toggle_advanced)
        self.adv_toggle_btn.grid(row=0, column=0, padx=10, pady=5, sticky='w')
        ttk.Label(self.adv_frame, text="Custom Flags:").grid(row=1, column=0, padx=5, pady=5, sticky='w')
        self.custom_flags = tk.StringVar()
        self.custom_flags_entry = ttk.Entry(self.adv_frame, textvariable=self.custom_flags, width=40)
        self.custom_flags_entry.grid(row=1, column=1, padx=5, pady=5, sticky='w')
        ttk.Label(self.adv_frame, text="Env Vars (KEY=VAL;...):").grid(row=2, column=0, padx=5, pady=5, sticky='w')
        self.env_vars = tk.StringVar()
        self.env_vars_entry = ttk.Entry(self.adv_frame, textvariable=self.env_vars, width=40)
        self.env_vars_entry.grid(row=2, column=1, padx=5, pady=5, sticky='w')
        ttk.Label(self.adv_frame, text="Pre-Build Hook:").grid(row=3, column=0, padx=5, pady=5, sticky='w')
        self.pre_hook = tk.StringVar()
        self.pre_hook_entry = ttk.Entry(self.adv_frame, textvariable=self.pre_hook, width=40)
        self.pre_hook_entry.grid(row=3, column=1, padx=5, pady=5, sticky='w')
        self.pre_hook_btn = ttk.Button(self.adv_frame, text="Browse", command=lambda: self.pick_script(self.pre_hook))
        self.pre_hook_btn.grid(row=3, column=2, padx=5, pady=5)
        ttk.Label(self.adv_frame, text="Post-Build Hook:").grid(row=4, column=0, padx=5, pady=5, sticky='w')
        self.post_hook = tk.StringVar()
        self.post_hook_entry = ttk.Entry(self.adv_frame, textvariable=self.post_hook, width=40)
        self.post_hook_entry.grid(row=4, column=1, padx=5, pady=5, sticky='w')
        self.post_hook_btn = ttk.Button(self.adv_frame, text="Browse", command=lambda: self.pick_script(self.post_hook))
        self.post_hook_btn.grid(row=4, column=2, padx=5, pady=5)

        # Custom Command Mode
        self.custom_cmd_mode = tk.BooleanVar(value=False)
        self.custom_cmd_btn = ttk.Checkbutton(self.adv_frame, text="Custom Command Mode", variable=self.custom_cmd_mode, command=self.toggle_custom_cmd)
        self.custom_cmd_btn.grid(row=5, column=0, padx=10, pady=5, sticky='w')
        self.custom_cmd_entry = ttk.Entry(self.adv_frame, width=80)
        self.custom_cmd_entry.grid(row=5, column=1, columnspan=3, padx=10, pady=5, sticky='w')
        self.custom_cmd_entry.grid_remove()

        # Start/Cancel/Export buttons
        action_frame = ttk.Frame(self)
        action_frame.grid(row=4, column=0, columnspan=5, padx=10, pady=10, sticky='ew')
        self.start_btn = ttk.Button(action_frame, text="Start Build", command=self.start_build)
        self.start_btn.pack(side='left', padx=10)
        self.cancel_btn = ttk.Button(action_frame, text="Cancel", command=self.cancel_build, state='disabled')
        self.cancel_btn.pack(side='left', padx=10)
        self.export_log_btn = ttk.Button(action_frame, text="Export Log", command=self.export_log)
        self.export_log_btn.pack(side='left', padx=10)

        # Log area
        log_frame = ttk.Labelframe(self, text="Build Log")
        log_frame.grid(row=5, column=0, columnspan=5, padx=10, pady=10, sticky='nsew')
        self.log_text = scrolledtext.ScrolledText(log_frame, width=120, height=20, state='disabled', bg="#232b3b", fg="#f5c542", font=('Consolas', 10))
        self.log_text.pack(fill='both', expand=True)
        self.grid_rowconfigure(5, weight=1)
        self.grid_columnconfigure(0, weight=1)

    def toggle_advanced(self):
        if self.adv_shown.get():
            self.adv_frame.grid_remove()
            self.adv_shown.set(False)
            self.adv_toggle_btn.config(text="Show Advanced")
        else:
            self.adv_frame.grid()
            self.adv_shown.set(True)
            self.adv_toggle_btn.config(text="Hide Advanced")

    def toggle_custom_cmd(self):
        if self.custom_cmd_mode.get():
            self.custom_cmd_entry.grid()
        else:
            self.custom_cmd_entry.grid_remove()

    def pick_script(self, var):
        path = filedialog.askopenfilename(filetypes=[("Shell Scripts", "*.sh"), ("All Files", "*")])
        if path:
            var.set(path)

    def open_dir(self, path):
        if not os.path.isdir(path):
            os.makedirs(path, exist_ok=True)
        if os.name == 'nt':
            os.startfile(path)
        elif os.uname().sysname == 'Darwin':
            subprocess.Popen(['open', path])
        else:
            subprocess.Popen(['xdg-open', path])

    def export_log(self):
        log = self.log_text.get(1.0, tk.END)
        path = filedialog.asksaveasfilename(defaultextension=".log", filetypes=[("Log Files", "*.log"), ("All Files", "*")])
        if path:
            with open(path, 'w') as f:
                f.write(log)
            messagebox.showinfo("Export Log", f"Log saved to {path}")

    def check_environment(self):
        ready = True
        for f in REQUIRED_FILES:
            if os.path.isfile(f):
                self.status_labels[f].config(text=f"{f}: ✓", foreground="#4caf50")
            else:
                self.status_labels[f].config(text=f"{f}: ✗ (missing)", foreground="#e53935")
                ready = False
        for d in REQUIRED_DIRS:
            if os.path.isdir(d):
                self.status_labels[d].config(text=f"{d}/: ✓", foreground="#4caf50")
            else:
                self.status_labels[d].config(text=f"{d}/: ✗ (missing)", foreground="#e53935")
                ready = False
        if ready:
            self.env_ready_label.config(text="Environment ready!", foreground="#4caf50")
            self.setup_btn.config(state='disabled')
        else:
            self.env_ready_label.config(text="Environment incomplete. Please run setup.", foreground="#e53935")
            self.setup_btn.config(state='normal')
        self.env_ready = ready

    def run_setup_env(self):
        if not os.path.isfile("setup-build-env.sh"):
            messagebox.showerror("Error", "setup-build-env.sh not found!")
            return
        self.append_log("[INFO] Running environment setup...\n")
        self.setup_btn.config(state='disabled')
        threading.Thread(target=self._run_setup_env_thread, daemon=True).start()

    def _run_setup_env_thread(self):
        try:
            process = subprocess.Popen(["bash", "setup-build-env.sh"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
            for line in process.stdout:
                self.append_log(line)
            process.wait()
            self.append_log("[INFO] Environment setup complete.\n")
        except Exception as e:
            self.append_log(f"[ERROR] {e}\n")
        self.check_environment()

    def browse_output_dir(self):
        directory = filedialog.askdirectory(initialdir=self.output_dir.get())
        if directory:
            self.output_dir.set(directory)

    def start_build(self):
        if not self.env_ready:
            messagebox.showerror("Error", "Environment is not ready. Please run setup first.")
            return
        if self.clean_build.get():
            for d in [self.output_dir.get(), "work"]:
                if os.path.isdir(d):
                    for f in os.listdir(d):
                        fp = os.path.join(d, f)
                        try:
                            if os.path.isdir(fp):
                                import shutil
                                shutil.rmtree(fp)
                            else:
                                os.remove(fp)
                        except Exception:
                            pass
        if self.pre_hook.get():
            self.append_log(f"[INFO] Running pre-build hook: {self.pre_hook.get()}\n")
            subprocess.call(["bash", self.pre_hook.get()])
        if self.custom_cmd_mode.get():
            cmd = self.custom_cmd_entry.get()
            if not cmd.strip():
                messagebox.showerror("Error", "Custom command is empty.")
                return
            args = shlex.split(cmd)
        else:
            script = self.build_scripts[self.build_type.get()]
            if not os.path.exists(script):
                messagebox.showerror("Error", f"Build script not found: {script}")
                return
            for d in [self.output_dir.get(), "work"]:
                os.makedirs(d, exist_ok=True)
            args = ["bash", script]
            if self.skip_validations.get():
                args.append("--skip-validations")
            if self.verbose.get():
                args.append("--verbose")
            if self.custom_flags.get():
                args += shlex.split(self.custom_flags.get())
        env = os.environ.copy()
        env["OUT_DIR"] = self.output_dir.get()
        if self.env_vars.get():
            for pair in self.env_vars.get().split(';'):
                if '=' in pair:
                    k, v = pair.split('=', 1)
                    env[k.strip()] = v.strip()
        self.log_text.config(state='normal')
        self.log_text.delete(1.0, tk.END)
        self.log_text.config(state='disabled')
        self.start_btn.config(state='disabled')
        self.cancel_btn.config(state='normal')
        self.stop_requested = False
        threading.Thread(target=self.run_build, args=(args, env), daemon=True).start()

    def run_build(self, args, env):
        try:
            process = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=env, text=True, bufsize=1)
            self.build_process = process
            for line in process.stdout:
                self.append_log(line)
                if self.stop_requested:
                    process.terminate()
                    self.append_log("\n[Build cancelled by user]\n")
                    break
            process.wait()
            if not self.stop_requested and self.post_hook.get():
                self.append_log(f"[INFO] Running post-build hook: {self.post_hook.get()}\n")
                subprocess.call(["bash", self.post_hook.get()])
            if not self.stop_requested:
                if process.returncode == 0:
                    self.append_log("\n[Build completed successfully]\n")
                    messagebox.showinfo("Success", "Build completed successfully!")
                else:
                    self.append_log(f"\n[Build failed with exit code {process.returncode}]\n")
                    messagebox.showerror("Build Failed", f"Build failed with exit code {process.returncode}")
        except Exception as e:
            self.append_log(f"\n[Error: {e}]\n")
            messagebox.showerror("Error", str(e))
        finally:
            self.start_btn.config(state='normal')
            self.cancel_btn.config(state='disabled')
            self.build_process = None

    def cancel_build(self):
        self.stop_requested = True
        if self.build_process:
            self.build_process.terminate()

    def append_log(self, text):
        self.log_text.config(state='normal')
        self.log_text.insert(tk.END, text)
        self.log_text.see(tk.END)
        self.log_text.config(state='disabled')

    def show_help(self):
        help_text = (
            "Kalki OS Build Launcher Help\n\n"
            "1. Ensure all required files and directories are present (see status above).\n"
            "2. If environment is incomplete, click 'Run Environment Setup'.\n"
            "3. Select build type and options, choose output directory.\n"
            "4. Click 'Start Build' to begin.\n"
            "5. View logs below.\n"
            "6. For more info, see the README or documentation."
        )
        messagebox.showinfo("Help", help_text)

    def show_about(self):
        about_text = (
            "Kalki OS Build Launcher\n"
            "Version 1.0\n\n"
            "A modern, agentic, modular Linux build system.\n"
            "© 2024 Kalki OS Project. All rights reserved.\n"
            "https://kalki-os.org"
        )
        messagebox.showinfo("About", about_text)

    def show_env_choice(self):
        win = tk.Toplevel(self)
        win.title("Kalki OS Build Environment Setup")
        win.geometry("500x350")
        win.configure(bg="#1a2233")
        ttk.Label(win, text="Kalki OS requires an Arch Linux build environment.", font=("Segoe UI", 13, "bold")).pack(pady=20)
        ttk.Label(win, text="Choose an automated setup method:", font=("Segoe UI", 11)).pack(pady=10)
        btns = []
        if has_docker():
            btns.append(ttk.Button(win, text="Launch Docker Build Container", command=lambda: self.launch_script_and_exit("run-arch-build-container.sh", win)))
        else:
            ttk.Label(win, text="Docker not found. Please install Docker Desktop.", foreground="#e53935").pack(pady=5)
        if has_vagrant():
            btns.append(ttk.Button(win, text="Launch Vagrant VM", command=lambda: self.launch_script_and_exit("vagrant up", win)))
        else:
            ttk.Label(win, text="Vagrant not found. Please install Vagrant.", foreground="#e53935").pack(pady=5)
        for b in btns:
            b.pack(pady=10)
        ttk.Label(win, text="Or run on a native Arch Linux system.", font=("Segoe UI", 10)).pack(pady=10)
        ttk.Button(win, text="Exit", command=self.quit).pack(pady=10)
        win.protocol("WM_DELETE_WINDOW", self.quit)
        win.transient(self)
        win.grab_set()
        self.wait_window(win)

    def launch_script_and_exit(self, script, win):
        win.destroy()
        self.destroy()
        if script == "vagrant up":
            os.system("vagrant up")
        else:
            os.system(f"bash {script}")
        exit(0)

if __name__ == "__main__":
    app = BuildLauncher()
    app.mainloop() 