#!/usr/bin/env python3
import gi
import requests
import os
import threading
import time

gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GdkPixbuf, GLib

OLLAMA_URL = "http://localhost:11434/api/generate"
OLLAMA_MODEL = "dolphin-mistral"
KRIX_PERSONA = "You are Krix 🧑‍💻, the main AI terminal of Kalki OS. Respond as a helpful, expert, and friendly assistant for all system and user tasks on Archiso."

ICON_PATH = os.path.expanduser("~/.config/omnet-shell/krix.png")  # Place a Krix icon here if available

class KrixChatWindow(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="Krix AI Terminal")
        self.set_default_size(500, 600)
        self.set_border_width(10)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.set_icon_from_file(ICON_PATH) if os.path.exists(ICON_PATH) else None

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.add(vbox)

        # Chat history
        self.chat_buffer = Gtk.TextBuffer()
        self.chat_view = Gtk.TextView(buffer=self.chat_buffer)
        self.chat_view.set_editable(False)
        self.chat_view.set_wrap_mode(Gtk.WrapMode.WORD)
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_vexpand(True)
        scrolled.add(self.chat_view)
        vbox.pack_start(scrolled, True, True, 0)

        # Entry and send button
        hbox = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        self.entry = Gtk.Entry()
        self.entry.set_placeholder_text("Ask Krix anything...")
        self.entry.connect("activate", self.on_send)
        send_btn = Gtk.Button(label="Send")
        send_btn.connect("clicked", self.on_send)
        hbox.pack_start(self.entry, True, True, 0)
        hbox.pack_start(send_btn, False, False, 0)
        vbox.pack_start(hbox, False, False, 0)

        # Welcome message
        self.append_chat("Krix 🧑‍💻:", "Hello! I am Krix, your AI terminal companion. How can I help you today?")

    def append_chat(self, sender, message):
        end_iter = self.chat_buffer.get_end_iter()
        self.chat_buffer.insert(end_iter, f"{sender} {message}\n")
        self.chat_view.scroll_to_iter(self.chat_buffer.get_end_iter(), 0.0, False, 0, 0)

    def on_send(self, widget):
        user_text = self.entry.get_text().strip()
        if not user_text:
            return
        self.append_chat("You:", user_text)
        self.entry.set_text("")
        threading.Thread(target=self.get_krix_response, args=(user_text,)).start()

    def get_krix_response(self, user_text):
        prompt = f"{KRIX_PERSONA}\nUser says: {user_text}\nRespond as Krix."
        try:
            resp = requests.post(OLLAMA_URL, json={"model": OLLAMA_MODEL, "prompt": prompt, "stream": False}, timeout=60)
            if resp.ok:
                answer = resp.json()["response"].strip()
            else:
                answer = "[LLM error: " + resp.text + "]"
        except Exception as e:
            answer = f"[Error: {e}]"
        GLib.idle_add(self.append_chat, "Krix 🧑‍💻:", answer)

if __name__ == "__main__":
    win = KrixChatWindow()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main() 