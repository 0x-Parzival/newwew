#!/usr/bin/env python3
"""
BunniWrite: Dharmic Writing Studio for Kalki OS
AI-assisted writing with spiritual mindfulness
"""

import os
import json
import asyncio
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

try:
    import tkinter as tk
    from tkinter import ttk, filedialog, messagebox
    import asyncio
    from concurrent.futures import ThreadPoolExecutor
except ImportError:
    print("Installing BunniWrite dependencies...")
    os.system("pip install asyncio")

class BunniWriteEditor:
    def __init__(self):
        self.root = tk.Tk()
        self.setup_window()
        self.setup_ui()
        self.current_file = None
        self.word_count = 0
        self.writing_session_start = datetime.now()
        self.ai_suggestions_enabled = True
        
    def setup_window(self):
        """Configure main window with dharmic aesthetics"""
        self.root.title("BunniWrite - Dharmic Writing Studio")
        self.root.geometry("1200x800")
        
        # Dharmic color scheme
        self.colors = {
            'bg': '#1a0f2e',
            'fg': '#e6d7ff',
            'accent': '#8a2be2',
            'secondary': '#4a0e4e',
            'success': '#28a745',
            'warning': '#ffc107'
        }
        
        self.root.configure(bg=self.colors['bg'])
        
        # Configure styles
        style = ttk.Style()
        style.theme_use('clam')
        style.configure('Dharmic.TFrame', background=self.colors['bg'])
        style.configure('Dharmic.TLabel', background=self.colors['bg'], foreground=self.colors['fg'])
        
    def setup_ui(self):
        """Create the main user interface"""
        # Main container
        main_frame = ttk.Frame(self.root, style='Dharmic.TFrame')
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Toolbar
        toolbar = ttk.Frame(main_frame, style='Dharmic.TFrame')
        toolbar.pack(fill=tk.X, pady=(0, 10))
        
        # Writing mode buttons
        ttk.Button(toolbar, text="📝 Draft Mode", command=self.set_draft_mode).pack(side=tk.LEFT, padx=5)
        ttk.Button(toolbar, text="🎨 Creative Mode", command=self.set_creative_mode).pack(side=tk.LEFT, padx=5)
        ttk.Button(toolbar, text="🔬 Technical Mode", command=self.set_technical_mode).pack(side=tk.LEFT, padx=5)
        ttk.Button(toolbar, text="🕉️ Dharmic Mode", command=self.set_dharmic_mode).pack(side=tk.LEFT, padx=5)
        
        # AI assistant toggle
        ttk.Button(toolbar, text="🐰 Summon Bunni", command=self.toggle_ai_assistant).pack(side=tk.RIGHT, padx=5)
        
        # Main editing area
        editor_frame = ttk.Frame(main_frame, style='Dharmic.TFrame')
        editor_frame.pack(fill=tk.BOTH, expand=True)
        
        # Text editor with custom styling
        self.text_editor = tk.Text(
            editor_frame,
            bg=self.colors['bg'],
            fg=self.colors['fg'],
            insertbackground=self.colors['accent'],
            selectbackground=self.colors['secondary'],
            font=('JetBrains Mono', 12),
            wrap=tk.WORD,
            padx=20,
            pady=20,
            relief=tk.FLAT,
            borderwidth=0
        )
        
        # Scrollbar
        scrollbar = ttk.Scrollbar(editor_frame, orient=tk.VERTICAL, command=self.text_editor.yview)
        self.text_editor.configure(yscrollcommand=scrollbar.set)
        
        self.text_editor.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        # Status bar
        status_frame = ttk.Frame(main_frame, style='Dharmic.TFrame')
        status_frame.pack(fill=tk.X, pady=(10, 0))
        
        self.status_label = ttk.Label(status_frame, text="Ready to write with dharmic consciousness", style='Dharmic.TLabel')
        self.status_label.pack(side=tk.LEFT)
        
        self.word_count_label = ttk.Label(status_frame, text="Words: 0", style='Dharmic.TLabel')
        self.word_count_label.pack(side=tk.RIGHT)
        
        # Bind events
        self.text_editor.bind('<KeyRelease>', self.on_text_change)
        self.text_editor.bind('<Button-1>', self.on_text_change)
        
        # Menu setup
        self.setup_menu()
        
    def setup_menu(self):
        """Create application menu"""
        menubar = tk.Menu(self.root, bg=self.colors['bg'], fg=self.colors['fg'])
        self.root.config(menu=menubar)
        
        # File menu
        file_menu = tk.Menu(menubar, tearoff=0, bg=self.colors['bg'], fg=self.colors['fg'])
        menubar.add_cascade(label="File", menu=file_menu)
        file_menu.add_command(label="New", command=self.new_file, accelerator="Ctrl+N")
        file_menu.add_command(label="Open", command=self.open_file, accelerator="Ctrl+O")
        file_menu.add_command(label="Save", command=self.save_file, accelerator="Ctrl+S")
        file_menu.add_separator()
        file_menu.add_command(label="Export", command=self.export_file)
        
        # Edit menu
        edit_menu = tk.Menu(menubar, tearoff=0, bg=self.colors['bg'], fg=self.colors['fg'])
        menubar.add_cascade(label="Edit", menu=edit_menu)
        edit_menu.add_command(label="AI Suggestions", command=self.get_ai_suggestions)
        edit_menu.add_command(label="Grammar Check", command=self.check_grammar)
        edit_menu.add_command(label="Style Analysis", command=self.analyze_style)
        
        # Dharma menu
        dharma_menu = tk.Menu(menubar, tearoff=0, bg=self.colors['bg'], fg=self.colors['fg'])
        menubar.add_cascade(label="Dharma", menu=dharma_menu)
        dharma_menu.add_command(label="Writing Meditation", command=self.start_writing_meditation)
        dharma_menu.add_command(label="Mindful Break", command=self.mindful_break)
        dharma_menu.add_command(label="Intention Setting", command=self.set_writing_intention)
        
    def on_text_change(self, event=None):
        """Handle text changes and update statistics"""
        content = self.text_editor.get(1.0, tk.END)
        words = len(content.split())
        self.word_count = words
        self.word_count_label.config(text=f"Words: {words}")
        
        # Update status with writing flow indicator
        if words > 0:
            session_duration = (datetime.now() - self.writing_session_start).seconds // 60
            wpm = words / max(session_duration, 1) if session_duration > 0 else 0
            self.status_label.config(text=f"Writing flow: {wpm:.1f} WPM • Session: {session_duration}m")
    
    def set_draft_mode(self):
        """Configure for draft writing"""
        self.text_editor.config(font=('Liberation Serif', 12))
        self.status_label.config(text="Draft mode: Focus on getting ideas down")
        
    def set_creative_mode(self):
        """Configure for creative writing"""
        self.text_editor.config(font=('Crimson Text', 13))
        self.status_label.config(text="Creative mode: Let imagination flow freely")
        
    def set_technical_mode(self):
        """Configure for technical writing"""
        self.text_editor.config(font=('JetBrains Mono', 11))
        self.status_label.config(text="Technical mode: Precision and clarity")
        
    def set_dharmic_mode(self):
        """Configure for dharmic/spiritual writing"""
        self.text_editor.config(font=('Noto Serif', 13))
        self.status_label.config(text="Dharmic mode: Write with conscious intention")
        
    def toggle_ai_assistant(self):
        """Toggle AI assistance features"""
        self.ai_suggestions_enabled = not self.ai_suggestions_enabled
        status = "enabled" if self.ai_suggestions_enabled else "disabled"
        self.status_label.config(text=f"Bunni AI assistant {status}")
        
    def get_ai_suggestions(self):
        """Get writing suggestions from Bunni avatar"""
        current_text = self.text_editor.get(1.0, tk.END).strip()
        if not current_text:
            messagebox.showinfo("Bunni Says", "Write something first, and I'll help improve it! 🎨")
            return
        
        # In real implementation, this would call the OMNet communication system
        suggestion_window = tk.Toplevel(self.root)
        suggestion_window.title("Bunni's Writing Suggestions")
        suggestion_window.geometry("500x400")
        suggestion_window.configure(bg=self.colors['bg'])
        
        label = ttk.Label(
            suggestion_window, 
            text="🐰 Bunni is analyzing your writing...", 
            style='Dharmic.TLabel'
        )
        label.pack(pady=20)
        
        # This would be replaced with actual AI communication
        suggestions_text = tk.Text(
            suggestion_window,
            bg=self.colors['bg'],
            fg=self.colors['fg'],
            font=('Liberation Serif', 11),
            wrap=tk.WORD,
            padx=15,
            pady=15
        )
        suggestions_text.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)
        
        # Mock suggestions - in real implementation, these come from Bunni avatar
        mock_suggestions = """
        ✨ Style Suggestions:
        • Your writing has a contemplative tone - perfect for dharmic expression
        • Consider varying sentence length for better rhythm
        • The metaphors you use connect well with spiritual themes
        
        🎨 Creative Enhancements:
        • Add more sensory details to engage readers
        • The concept of "digital consciousness" could be expanded
        • Consider a stronger conclusion that ties back to your opening
        
        🕉️ Dharmic Alignment:
        • Your intention shines through clearly
        • The balance between technical and spiritual language is well-maintained
        • This piece embodies mindful communication
        """
        
        suggestions_text.insert(1.0, mock_suggestions)
        suggestions_text.config(state=tk.DISABLED)
    
    def new_file(self):
        """Create new document"""
        if self.text_editor.get(1.0, tk.END).strip() and not messagebox.askyesno("New File", "Discard current changes?"):
            return
        self.text_editor.delete(1.0, tk.END)
        self.current_file = None
        self.writing_session_start = datetime.now()
        self.root.title("BunniWrite - New Document")
    
    def open_file(self):
        """Open an existing document"""
        file_path = filedialog.askopenfilename(
            filetypes=[("Markdown", "*.md"), ("Text", "*.txt"), ("All Files", "*.*")]
        )
        if file_path:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                self.text_editor.delete(1.0, tk.END)
                self.text_editor.insert(1.0, content)
                self.current_file = file_path
                self.root.title(f"BunniWrite - {Path(file_path).name}")
                self.writing_session_start = datetime.now()
                self.on_text_change()
            except Exception as e:
                messagebox.showerror("Error", f"Could not open file: {e}")
    
    def save_file(self):
        """Save current document"""
        if not self.current_file:
            self.current_file = filedialog.asksaveasfilename(
                defaultextension=".md",
                filetypes=[("Markdown", "*.md"), ("Text", "*.txt"), ("All Files", "*.*")]
            )
        
        if self.current_file:
            try:
                with open(self.current_file, 'w', encoding='utf-8') as f:
                    content = self.text_editor.get(1.0, tk.END)
                    f.write(content)
                self.status_label.config(text=f"Saved: {Path(self.current_file).name}")
            except Exception as e:
                messagebox.showerror("Error", f"Could not save file: {e}")
    
    def export_file(self):
        """Export document to different formats"""
        file_path = filedialog.asksaveasfilename(
            defaultextension=".html",
            filetypes=[
                ("HTML", ".html"),
                ("PDF", ".pdf"),
                ("Markdown", ".md"),
                ("Word", ".docx")
            ]
        )
        if file_path:
            # In a real implementation, this would convert to the selected format
            self.status_label.config(text=f"Exporting to {Path(file_path).suffix.upper()}...")
            messagebox.showinfo("Export", f"Export to {Path(file_path).name} would be implemented here")
    
    def check_grammar(self):
        """Check grammar using Bunni's assistance"""
        messagebox.showinfo("Grammar Check", "Bunni's grammar check would be implemented here")
    
    def analyze_style(self):
        """Analyze writing style"""
        messagebox.showinfo("Style Analysis", "Bunni's style analysis would be implemented here")
    
    def start_writing_meditation(self):
        """Start a guided writing meditation"""
        messagebox.showinfo("Writing Meditation", "Guided writing meditation would start here")
    
    def mindful_break(self):
        """Take a mindful break"""
        messagebox.showinfo("Mindful Break", "Take a moment to breathe and center yourself...")
    
    def set_writing_intention(self):
        """Set intention for writing session"""
        intention = tk.simpledialog.askstring(
            "Set Intention",
            "What is your intention for this writing session?",
            parent=self.root
        )
        if intention:
            self.status_label.config(text=f"Intention set: {intention}")
    
    def run(self):
        """Start the application"""
        self.root.mainloop()

def main():
    """Launch BunniWrite application"""
    app = BunniWriteEditor()
    app.run()

if __name__ == "__main__":
    main()
