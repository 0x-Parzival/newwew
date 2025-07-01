#!/usr/bin/env python3
import gi
import os
import subprocess
import json
from pathlib import Path
import threading
import time

gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GdkPixbuf, GObject

CONFIG_PATH = os.path.expanduser('~/.config/kalki-onboarding.json')
AVATAR_DIR = os.path.join(os.path.dirname(__file__), '../src/ai-system/omnet-shell/avatars')
PRIVACY_CONFIG = os.path.expanduser('~/.config/kalki-privacy.json')
AI_SERVICES = ["krix-ai", "ollama"]

class AvatarControlPanel(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="Avatar Control Panel v0.1")
        self.set_default_size(700, 500)
        self.set_border_width(10)

        # Main layout: sidebar + stack
        hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        self.add(hbox)

        # Sidebar
        sidebar = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        hbox.pack_start(sidebar, False, False, 0)

        self.stack = Gtk.Stack()
        self.stack.set_transition_type(Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
        self.stack.set_transition_duration(300)
        hbox.pack_start(self.stack, True, True, 0)

        # Sidebar buttons
        sections = [
            ("Privacy Controls", self.privacy_controls),
            ("Avatar Picker", self.avatar_picker),
            ("AI Core Status", self.ai_core_status),
            ("System Utilities", self.system_utilities),
            ("Personalization", self.personalization),
        ]
        for label, func in sections:
            btn = Gtk.Button(label=label)
            btn.connect("clicked", lambda w, f=func: self.stack.set_visible_child_name(f.__name__))
            sidebar.pack_start(btn, False, False, 0)
            self.stack.add_titled(func(), func.__name__, label)

        self.show_all()

    def privacy_controls(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.set_border_width(10)
        # Load privacy config
        self.privacy_state = self.load_privacy_config()
        # Toggles
        self.toggles = {}
        for label in ["Microphone", "Camera", "Location", "Network AI access"]:
            key = label.lower().replace(' ', '_')
            toggle = Gtk.Switch()
            toggle.set_active(self.privacy_state.get(key, True))
            toggle.connect("notify::active", self.on_privacy_toggle, key)
            h = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
            h.pack_start(Gtk.Label(label=label), False, False, 0)
            h.pack_end(toggle, False, False, 0)
            box.pack_start(h, False, False, 0)
            self.toggles[key] = toggle
        # AI Kill Switch
        self.ai_status_label = Gtk.Label(label="[Checking AI service status...]")
        kill_btn = Gtk.Button(label="AI Kill Switch (Stop/Start Krix & Ollama)")
        kill_btn.connect("clicked", self.on_ai_kill_switch)
        box.pack_start(self.ai_status_label, False, False, 0)
        box.pack_start(kill_btn, False, False, 0)
        # Start status updater
        self.update_ai_status()
        return box

    def load_privacy_config(self):
        if os.path.isfile(PRIVACY_CONFIG):
            try:
                with open(PRIVACY_CONFIG) as f:
                    return json.load(f)
            except Exception:
                return {}
        return {}

    def save_privacy_config(self):
        try:
            os.makedirs(os.path.dirname(PRIVACY_CONFIG), exist_ok=True)
            with open(PRIVACY_CONFIG, 'w') as f:
                json.dump(self.privacy_state, f, indent=2)
        except Exception as e:
            print(f"[Privacy] Failed to save config: {e}")

    def on_privacy_toggle(self, switch, gparam, key):
        self.privacy_state[key] = switch.get_active()
        self.save_privacy_config()
        # TODO: Integrate with real hardware/service control (e.g., disable mic/cam)

    def on_ai_kill_switch(self, button):
        # Toggle AI services: if running, stop; if stopped, start
        all_active = all(self.is_service_active(s) for s in AI_SERVICES)
        for svc in AI_SERVICES:
            try:
                if all_active:
                    subprocess.run(["systemctl", "stop", svc], check=False)
                else:
                    subprocess.run(["systemctl", "start", svc], check=False)
            except Exception as e:
                print(f"[AI Kill Switch] {svc}: {e}")
        self.update_ai_status()

    def is_service_active(self, svc):
        try:
            r = subprocess.run(["systemctl", "is-active", svc], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            return r.stdout.strip() == "active"
        except Exception:
            return False

    def update_ai_status(self):
        def check():
            statuses = []
            for svc in AI_SERVICES:
                status = "active" if self.is_service_active(svc) else "inactive"
                statuses.append(f"{svc}: {status}")
            label = "AI Services: " + ", ".join(statuses)
            GObject.idle_add(self.ai_status_label.set_text, label)
        threading.Thread(target=check, daemon=True).start()

    def avatar_picker(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.set_border_width(10)
        # Load avatars
        self.avatars = self.load_avatars()
        avatar_names = [a['name'] for a in self.avatars]
        # Dropdown
        self.avatar_combo = Gtk.ComboBoxText()
        for name in avatar_names:
            self.avatar_combo.append_text(name)
        self.avatar_combo.set_active(0)
        self.avatar_combo.connect("changed", self.on_avatar_changed)
        box.pack_start(Gtk.Label(label="Choose your Avatar:"), False, False, 0)
        box.pack_start(self.avatar_combo, False, False, 0)
        # Avatar image placeholder
        self.avatar_image = Gtk.Label(label="[Avatar Image Here]")  # TODO: Replace with real image
        box.pack_start(self.avatar_image, False, False, 0)
        # Avatar info
        self.avatar_info = Gtk.Label()
        box.pack_start(self.avatar_info, False, False, 0)
        # LLM model
        self.llm_label = Gtk.Label()
        box.pack_start(self.llm_label, False, False, 0)
        # Reboot Krix button
        reboot_btn = Gtk.Button(label="Reboot Krix (Reload Avatar)")
        reboot_btn.connect("clicked", self.on_reboot_krix)
        box.pack_start(reboot_btn, False, False, 0)
        # Load current selection from config
        self.load_selected_avatar()
        self.update_avatar_display()
        return box

    def load_avatars(self):
        avatars = []
        if os.path.isdir(AVATAR_DIR):
            for d in sorted(os.listdir(AVATAR_DIR)):
                path = os.path.join(AVATAR_DIR, d)
                if os.path.isdir(path):
                    cfg = os.path.join(path, "config.json")
                    data = {"name": d, "role": "", "greeting": "", "llm": "Unknown"}
                    if os.path.isfile(cfg):
                        try:
                            with open(cfg) as f:
                                j = json.load(f)
                                data["name"] = j.get("name", d)
                                data["role"] = j.get("role", "")
                                data["greeting"] = j.get("greeting", "")
                                data["llm"] = j.get("llm", "Unknown")
                        except Exception:
                            pass
                    avatars.append(data)
        return avatars if avatars else [{"name": "No Avatars Found", "role": "", "greeting": "", "llm": "Unknown"}]

    def load_selected_avatar(self):
        # Load from onboarding config
        try:
            if os.path.isfile(CONFIG_PATH):
                with open(CONFIG_PATH) as f:
                    j = json.load(f)
                    sel = j.get("avatar", None)
                    if sel:
                        for i, a in enumerate(self.avatars):
                            if a["name"] == sel:
                                self.avatar_combo.set_active(i)
                                break
        except Exception:
            pass

    def save_selected_avatar(self, name):
        # Save to onboarding config
        try:
            j = {}
            if os.path.isfile(CONFIG_PATH):
                with open(CONFIG_PATH) as f:
                    j = json.load(f)
            j["avatar"] = name
            os.makedirs(os.path.dirname(CONFIG_PATH), exist_ok=True)
            with open(CONFIG_PATH, 'w') as f:
                json.dump(j, f, indent=2)
        except Exception as e:
            print(f"[Avatar Picker] Failed to save: {e}")

    def on_avatar_changed(self, combo):
        idx = combo.get_active()
        if idx < 0 or idx >= len(self.avatars):
            return
        avatar = self.avatars[idx]
        self.update_avatar_display()
        self.save_selected_avatar(avatar["name"])
        # TODO: Play avatar greeting sound/animation here

    def update_avatar_display(self):
        idx = self.avatar_combo.get_active()
        if idx < 0 or idx >= len(self.avatars):
            self.avatar_info.set_text("")
            self.llm_label.set_text("")
            return
        avatar = self.avatars[idx]
        info = f"Role: {avatar['role']}\nGreeting: {avatar['greeting']}"
        self.avatar_info.set_text(info)
        self.llm_label.set_text(f"LLM Model: {avatar['llm']}")
        # TODO: Update avatar_image with real image if available

    def on_reboot_krix(self, button):
        try:
            subprocess.run(["systemctl", "restart", "krix-ai"], check=False)
        except Exception as e:
            print(f"[Reboot Krix] {e}")

    def ai_core_status(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.set_border_width(10)
        box.pack_start(Gtk.Label(label="AI Core Status (LLM Models)"), False, False, 0)
        # List models
        self.model_listbox = Gtk.ListBox()
        self.model_status_label = Gtk.Label()
        box.pack_start(self.model_status_label, False, False, 0)
        self.refresh_model_list()
        box.pack_start(self.model_listbox, True, True, 0)
        refresh_btn = Gtk.Button(label="Refresh Model List")
        refresh_btn.connect("clicked", lambda b: self.refresh_model_list())
        box.pack_start(refresh_btn, False, False, 0)
        # Start real-time status updater
        self.model_status_thread = threading.Thread(target=self.model_status_updater, daemon=True)
        self.model_status_thread.start()
        return box

    def model_status_updater(self):
        while True:
            self.refresh_model_list(realtime=True)
            time.sleep(5)

    def refresh_model_list(self, realtime=False):
        # Clear list
        def update_ui(models, running, error=None):
            for row in self.model_listbox.get_children():
                self.model_listbox.remove(row)
            if error:
                self.model_status_label.set_text(error)
                return
            self.model_status_label.set_text("")
            for m in models:
                row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
                name_lbl = Gtk.Label(label=m, xalign=0)
                status = "Running" if m in running else ("Downloaded" if models[m] else "Not Present")
                status_lbl = Gtk.Label(label=status)
                row.pack_start(name_lbl, True, True, 0)
                row.pack_start(status_lbl, False, False, 0)
                # Pull button
                pull_btn = Gtk.Button(label="Pull")
                pull_btn.connect("clicked", lambda b, model=m: self.pull_model(model))
                row.pack_start(pull_btn, False, False, 0)
                # Remove button
                rm_btn = Gtk.Button(label="Remove")
                rm_btn.connect("clicked", lambda b, model=m: self.remove_model(model))
                row.pack_start(rm_btn, False, False, 0)
                # Upgrade button
                up_btn = Gtk.Button(label="Upgrade")
                up_btn.connect("clicked", lambda b, model=m: self.upgrade_model(model))
                row.pack_start(up_btn, False, False, 0)
                self.model_listbox.add(row)
            self.model_listbox.show_all()
        # Real integration with ollama
        try:
            models = {}
            running = []
            # Get installed models
            r = subprocess.run(["ollama", "list"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            if r.returncode != 0:
                raise Exception(r.stderr.strip())
            for line in r.stdout.splitlines():
                if line.strip() and not line.startswith("NAME"):
                    parts = line.split()
                    if parts:
                        models[parts[0]] = True
            # Get running models
            r2 = subprocess.run(["ollama", "ps"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            if r2.returncode == 0:
                for line in r2.stdout.splitlines():
                    if line.strip() and not line.startswith("NAME"):
                        parts = line.split()
                        if parts:
                            running.append(parts[0])
            # Add some known models as not present for demo
            for m in ["mistral", "llama2", "tinyllama", "krix"]:
                if m not in models:
                    models[m] = False
            GObject.idle_add(update_ui, models, running)
        except Exception as e:
            GObject.idle_add(update_ui, {}, [], f"Ollama error: {e}")

    def pull_model(self, model):
        # TODO: Integrate with Ollama/model manager
        print(f"[AI Core] Pulling model: {model}")
        # Simulate action
        self.refresh_model_list()

    def remove_model(self, model):
        # TODO: Integrate with Ollama/model manager
        print(f"[AI Core] Removing model: {model}")
        # Simulate action
        self.refresh_model_list()

    def upgrade_model(self, model):
        # TODO: Integrate with Ollama/model manager
        print(f"[AI Core] Upgrading model: {model}")
        # Simulate action
        self.refresh_model_list()

    def system_utilities(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.set_border_width(10)
        box.pack_start(Gtk.Label(label="System Utilities"), False, False, 0)
        # Rollback button
        rollback_btn = Gtk.Button(label="Rollback (System Restore)")
        rollback_btn.connect("clicked", self.on_rollback)
        box.pack_start(rollback_btn, False, False, 0)
        # Update checker
        update_btn = Gtk.Button(label="Check for Updates")
        update_btn.connect("clicked", self.on_update_check)
        box.pack_start(update_btn, False, False, 0)
        # Krix Terminal launcher
        krix_btn = Gtk.Button(label="Launch Krix Terminal")
        krix_btn.connect("clicked", self.on_launch_krix_terminal)
        box.pack_start(krix_btn, False, False, 0)
        return box

    def on_rollback(self, button):
        # Launch kalki-rollback-gui.sh if present
        rollback_gui = "/opt/kalki/scripts/kalki-rollback-gui.sh"
        if os.path.isfile(rollback_gui):
            subprocess.Popen(["bash", rollback_gui])
        else:
            self.show_error("Rollback tool not found at /opt/kalki/scripts/kalki-rollback-gui.sh")

    def on_update_check(self, button):
        # Stub: Show dialog, ready for real integration
        dialog = Gtk.MessageDialog(self, 0, Gtk.MessageType.INFO, Gtk.ButtonsType.OK, "Update Checker")
        dialog.format_secondary_text("System update check not yet implemented.\n(TODO: Integrate with package manager)")
        dialog.run()
        dialog.destroy()

    def on_launch_krix_terminal(self, button):
        # Launch Krix terminal if present
        krix_term = "/opt/kalki/scripts/krix-term"
        if os.path.isfile(krix_term):
            subprocess.Popen(["bash", krix_term])
        else:
            self.show_error("Krix terminal not found at /opt/kalki/scripts/krix-term")

    def show_error(self, msg):
        dialog = Gtk.MessageDialog(self, 0, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK, "Error")
        dialog.format_secondary_text(msg)
        dialog.run()
        dialog.destroy()

    def personalization(self):
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        box.set_border_width(10)
        box.pack_start(Gtk.Label(label="Personalization"), False, False, 0)
        # Load config
        self.pers_config_path = os.path.expanduser('~/.config/kalki-personalization.json')
        self.pers_config = self.load_pers_config()
        # Theme toggle
        theme_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        theme_label = Gtk.Label(label="Theme:")
        self.theme_switch = Gtk.Switch()
        self.theme_switch.set_active(self.pers_config.get('dark_theme', False))
        self.theme_switch.connect("notify::active", self.on_theme_toggle)
        theme_box.pack_start(theme_label, False, False, 0)
        theme_box.pack_end(self.theme_switch, False, False, 0)
        box.pack_start(theme_box, False, False, 0)
        # Font size slider
        font_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        font_label = Gtk.Label(label="Terminal Font Size:")
        self.font_adj = Gtk.Adjustment(self.pers_config.get('font_size', 14), 10, 24, 1, 2, 0)
        self.font_slider = Gtk.Scale(orientation=Gtk.Orientation.HORIZONTAL, adjustment=self.font_adj)
        self.font_slider.set_digits(0)
        self.font_slider.connect("value-changed", self.on_font_slider)
        font_box.pack_start(font_label, False, False, 0)
        font_box.pack_end(self.font_slider, True, True, 0)
        box.pack_start(font_box, False, False, 0)
        # Opacity slider
        op_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        op_label = Gtk.Label(label="Terminal Opacity:")
        self.op_adj = Gtk.Adjustment(self.pers_config.get('opacity', 100), 50, 100, 1, 5, 0)
        self.op_slider = Gtk.Scale(orientation=Gtk.Orientation.HORIZONTAL, adjustment=self.op_adj)
        self.op_slider.set_digits(0)
        self.op_slider.connect("value-changed", self.on_opacity_slider)
        op_box.pack_start(op_label, False, False, 0)
        op_box.pack_end(self.op_slider, True, True, 0)
        box.pack_start(op_box, False, False, 0)
        # Boot video selector
        video_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        video_label = Gtk.Label(label="Boot Video:")
        self.video_entry = Gtk.Entry()
        self.video_entry.set_text(self.pers_config.get('boot_video', ''))
        video_btn = Gtk.Button(label="Select...")
        video_btn.connect("clicked", self.on_select_video)
        video_box.pack_start(video_label, False, False, 0)
        video_box.pack_start(self.video_entry, True, True, 0)
        video_box.pack_end(video_btn, False, False, 0)
        box.pack_start(video_box, False, False, 0)
        return box

    def load_pers_config(self):
        if os.path.isfile(self.pers_config_path):
            try:
                with open(self.pers_config_path) as f:
                    return json.load(f)
            except Exception:
                return {}
        return {}

    def save_pers_config(self):
        try:
            os.makedirs(os.path.dirname(self.pers_config_path), exist_ok=True)
            with open(self.pers_config_path, 'w') as f:
                json.dump(self.pers_config, f, indent=2)
        except Exception as e:
            print(f"[Personalization] Failed to save config: {e}")

    def on_theme_toggle(self, switch, gparam):
        self.pers_config['dark_theme'] = switch.get_active()
        self.save_pers_config()
        # TODO: Integrate with real theme switching

    def on_font_slider(self, slider):
        self.pers_config['font_size'] = int(slider.get_value())
        self.save_pers_config()
        # TODO: Integrate with terminal font size

    def on_opacity_slider(self, slider):
        self.pers_config['opacity'] = int(slider.get_value())
        self.save_pers_config()
        # TODO: Integrate with terminal opacity

    def on_select_video(self, button):
        dialog = Gtk.FileChooserDialog(
            title="Select Boot Video", parent=self, action=Gtk.FileChooserAction.OPEN,
            buttons=(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL, Gtk.STOCK_OPEN, Gtk.ResponseType.OK))
        dialog.set_modal(True)
        filter_mp4 = Gtk.FileFilter()
        filter_mp4.set_name("MP4 files")
        filter_mp4.add_pattern("*.mp4")
        dialog.add_filter(filter_mp4)
        if dialog.run() == Gtk.ResponseType.OK:
            self.video_entry.set_text(dialog.get_filename())
            self.pers_config['boot_video'] = dialog.get_filename()
            self.save_pers_config()
            # TODO: Integrate with boot animation system
        dialog.destroy()

if __name__ == "__main__":
    app = AvatarControlPanel()
    app.connect("destroy", Gtk.main_quit)
    app.show_all()
    Gtk.main() 