#!/usr/bin/env python3
"""
DesignDeva: AI-Assisted Design Studio for Kalki OS
Create themes, mockups, and visual assets with dharmic aesthetics
"""

import tkinter as tk
from tkinter import ttk, colorchooser, filedialog, messagebox
import json
import colorsys
from pathlib import Path
from datetime import datetime

class DesignDevaStudio:
    def __init__(self):
        self.root = tk.Tk()
        self.setup_window()
        self.setup_ui()
        self.current_palette = []
        self.current_theme = {}
        
    def setup_window(self):
        """Configure main design studio window"""
        self.root.title("DesignDeva - Dharmic Design Studio")
        self.root.geometry("1400x900")
        
        # Design-focused color scheme
        self.colors = {
            'bg': '#0f0f23',
            'fg': '#e6e6fa',
            'accent': '#9370db',
            'secondary': '#483d8b',
            'canvas': '#1e1e3f'
        }
        
        self.root.configure(bg=self.colors['bg'])
        
    def setup_ui(self):
        """Create the design studio interface"""
        # Main container with paned window
        main_paned = ttk.PanedWindow(self.root, orient=tk.HORIZONTAL)
        main_paned.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Left panel: Tools and controls
        left_frame = ttk.Frame(main_paned, style='Dharmic.TFrame')
        main_paned.add(left_frame, weight=1)
        
        # Tool palette
        tools_label = ttk.Label(left_frame, text="🎨 Design Tools", font=('Arial', 14, 'bold'))
        tools_label.pack(pady=10)
        
        # Color palette section
        palette_frame = ttk.LabelFrame(left_frame, text="Color Harmony")
        palette_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Button(palette_frame, text="Generate Dharmic Palette", command=self.generate_dharmic_palette).pack(pady=5)
        ttk.Button(palette_frame, text="Add Custom Color", command=self.add_custom_color).pack(pady=2)
        
        # Color display area
        self.color_frame = ttk.Frame(palette_frame)
        self.color_frame.pack(fill=tk.X, pady=5)
        
        # Theme generation section
        theme_frame = ttk.LabelFrame(left_frame, text="Theme Generator")
        theme_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Label(theme_frame, text="Theme Style:").pack(anchor=tk.W)
        self.theme_style = ttk.Combobox(theme_frame, values=[
            "Dharmic Minimal", "Cosmic Dark", "Zen Light", 
            "Cyber Dharma", "Natural Flow", "Divine Geometry"
        ])
        self.theme_style.pack(fill=tk.X, pady=2)
        self.theme_style.set("Dharmic Minimal")
        
        ttk.Button(theme_frame, text="🐐 Ask G.O.A.T. for Inspiration", command=self.get_artistic_inspiration).pack(pady=5)
        ttk.Button(theme_frame, text="Generate Theme", command=self.generate_theme).pack(pady=2)
        
        # Export section
        export_frame = ttk.LabelFrame(left_frame, text="Export & Share")
        export_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Button(export_frame, text="Export CSS Theme", command=self.export_css).pack(pady=2)
        ttk.Button(export_frame, text="Export GTK Theme", command=self.export_gtk).pack(pady=2)
        ttk.Button(export_frame, text="Save Design Project", command=self.save_project).pack(pady=2)
        
        # Right panel: Design canvas
        right_frame = ttk.Frame(main_paned, style='Dharmic.TFrame')
        main_paned.add(right_frame, weight=3)
        
        # Canvas for design preview
        canvas_label = ttk.Label(right_frame, text="🖼️ Design Preview", font=('Arial', 14, 'bold'))
        canvas_label.pack(pady=10)
        
        self.design_canvas = tk.Canvas(
            right_frame,
            bg=self.colors['canvas'],
            highlightthickness=0,
            width=800,
            height=600
        )
        self.design_canvas.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Preview controls
        preview_frame = ttk.Frame(right_frame)
        preview_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Label(preview_frame, text="Preview Mode:").pack(side=tk.LEFT)
        self.preview_mode = ttk.Combobox(preview_frame, values=[
            "Desktop Theme", "Web Interface", "Mobile App", "Terminal Theme"
        ])
        self.preview_mode.pack(side=tk.LEFT, padx=10)
        self.preview_mode.set("Desktop Theme")
        self.preview_mode.bind('<<ComboboxSelected>>', self.update_preview)
        
        # Initialize with default preview
        self.draw_default_preview()
        
    def generate_dharmic_palette(self):
        """Generate color palette inspired by dharmic principles"""
        # Dharmic color harmonies based on chakra system
        dharmic_palettes = {
            "Root Grounding": ["#8B0000", "#A52A2A", "#CD5C5C", "#F0E68C", "#FFFACD"],
            "Sacred Orange": ["#FF6347", "#FF7F50", "#FFA500", "#FFD700", "#FFFFE0"],
            "Solar Power": ["#FFD700", "#FFA500", "#FF8C00", "#FF7F50", "#FFFACD"],
            "Heart Harmony": ["#228B22", "#32CD32", "#90EE90", "#98FB98", "#F0FFF0"],
            "Throat Truth": ["#4169E1", "#6495ED", "#87CEEB", "#B0E0E6", "#F0F8FF"],
            "Third Eye": ["#4B0082", "#6A5ACD", "#9370DB", "#DDA0DD", "#E6E6FA"],
            "Crown Connection": ["#8A2BE2", "#9400D3", "#9932CC", "#DA70D6", "#F8F8FF"]
        }
        
        import random
        palette_name = random.choice(list(dharmic_palettes.keys()))
        colors = dharmic_palettes[palette_name]
        
        self.current_palette = colors
        self.display_color_palette(colors, palette_name)
        
    def display_color_palette(self, colors, name="Custom Palette"):
        """Display color palette in the UI"""
        # Clear existing palette display
        for widget in self.color_frame.winfo_children():
            widget.destroy()
        
        ttk.Label(self.color_frame, text=f"🎨 {name}").pack()
        
        color_display_frame = ttk.Frame(self.color_frame)
        color_display_frame.pack(fill=tk.X, pady=5)
        
        for i, color in enumerate(colors):
            color_btn = tk.Button(
                color_display_frame,
                bg=color,
                width=3,
                height=1,
                relief=tk.RAISED,
                command=lambda c=color: self.select_color(c)
            )
            color_btn.pack(side=tk.LEFT, padx=2)
    
    def add_custom_color(self):
        """Add custom color to palette"""
        color = colorchooser.askcolor(title="Choose Custom Color")
        if color[1]:  # If color was selected
            self.current_palette.append(color[1])
            self.display_color_palette(self.current_palette, "Custom Palette")
    
    def select_color(self, color):
        """Handle color selection"""
        # In a real implementation, this would set the active color for editing
        messagebox.showinfo("Color Selected", f"Selected color: {color}")
    
    def generate_theme(self):
        """Generate complete theme based on current palette and style"""
        if not self.current_palette:
            messagebox.showwarning("No Palette", "Please generate or create a color palette first")
            return
        
        style = self.theme_style.get()
        
        # Create theme configuration
        theme_config = {
            "name": f"{style} Theme",
            "primary_color": self.current_palette[0] if self.current_palette else "#8A2BE2",
            "secondary_color": self.current_palette[1] if len(self.current_palette) > 1 else "#4B0082",
            "accent_color": self.current_palette[2] if len(self.current_palette) > 2 else "#9370DB",
            "background_color": "#1a0f2e" if "Dark" in style else "#f8f8ff",
            "text_color": "#e6d7ff" if "Dark" in style else "#2d1b69",
            "border_radius": "12px" if "Minimal" in style else "8px",
            "shadow_style": "soft" if "Zen" in style else "sharp",
            "typography": {
                "heading_font": "Noto Sans",
                "body_font": "Liberation Sans",
                "mono_font": "JetBrains Mono"
            }
        }
        
        self.current_theme = theme_config
        self.update_preview()
        
        messagebox.showinfo("Theme Generated", f"Created {style} theme with dharmic aesthetics!")
    
    def draw_default_preview(self):
        """Draw default UI preview on canvas"""
        canvas = self.design_canvas
        canvas.delete("all")
        
        # Draw mockup UI elements
        # Window frame
        canvas.create_rectangle(50, 50, 750, 550, fill="#1a0f2e", outline="#8a2be2", width=2)
        
        # Title bar
        canvas.create_rectangle(50, 50, 750, 90, fill="#4b0082", outline="#8a2be2")
        canvas.create_text(400, 70, text="Kalki OS - Dharmic Interface", fill="#e6d7ff", font=('Arial', 12, 'bold'))
        
        # Sidebar
        canvas.create_rectangle(50, 90, 200, 550, fill="#2d1b69", outline="#8a2be2")
        
        # Menu items
        menu_items = ["🏠 Home", "📁 Files", "🎨 Design", "🧠 AI", "⚙️ Settings"]
        for i, item in enumerate(menu_items):
            y = 120 + i * 40
            canvas.create_text(125, y, text=item, fill="#e6d7ff", font=('Arial', 10))
        
        # Main content area
        canvas.create_rectangle(200, 90, 750, 550, fill="#1e1e3f", outline="#8a2be2")
        canvas.create_text(475, 320, text="🕉️ Dharmic Computing Interface\nMindful Technology for Conscious Users", 
                          fill="#9370db", font=('Arial', 14), justify=tk.CENTER)
    
    def update_preview(self, event=None):
        """Update preview based on current theme and mode"""
        if self.current_theme:
            self.draw_themed_preview()
        else:
            self.draw_default_preview()
    
    def draw_themed_preview(self):
        """Draw preview with current theme applied"""
        canvas = self.design_canvas
        canvas.delete("all")
        
        theme = self.current_theme
        
        # Apply theme colors to preview
        bg_color = theme.get("background_color", "#1a0f2e")
        primary_color = theme.get("primary_color", "#8a2be2")
        secondary_color = theme.get("secondary_color", "#4b0082")
        text_color = theme.get("text_color", "#e6d7ff")
        
        # Draw themed interface
        canvas.create_rectangle(50, 50, 750, 550, fill=bg_color, outline=primary_color, width=2)
        canvas.create_rectangle(50, 50, 750, 90, fill=secondary_color, outline=primary_color)
        canvas.create_text(400, 70, text=f"Kalki OS - {theme['name']}", fill=text_color, font=('Arial', 12, 'bold'))
        
        # Themed sidebar
        canvas.create_rectangle(50, 90, 200, 550, fill=secondary_color, outline=primary_color)
        
        # Themed content
        canvas.create_rectangle(200, 90, 750, 550, fill=bg_color, outline=primary_color)
        canvas.create_text(475, 320, text="🎨 Theme Preview\nDharmic Design Applied", 
                          fill=primary_color, font=('Arial', 14), justify=tk.CENTER)
    
    def get_artistic_inspiration(self):
        """Get design inspiration from G.O.A.T. avatar"""
        inspiration_window = tk.Toplevel(self.root)
        inspiration_window.title("G.O.A.T.'s Artistic Wisdom")
        inspiration_window.geometry("400x300")
        inspiration_window.configure(bg=self.colors['bg'])
        
        # Mock inspiration from G.O.A.T. avatar
        inspiration_text = """
        🐐 G.O.A.T. says:
        
        "Your design should breathe like a meditation...
        
        Consider the sacred geometry of the golden ratio.
        Purple and deep blues connect to higher consciousness.
        Smooth curves invite the eye to flow naturally.
        White space is not empty - it's potential.
        
        Let each element serve both function and beauty.
        True design touches both mind and soul."
        
        🎨 Suggested improvements:
        • Increase border radius for softer feel
        • Add subtle gradient backgrounds
        • Use Fibonacci spacing for elements
        • Include breathing room between sections
        """
        
        text_widget = tk.Text(
            inspiration_window,
            bg=self.colors['bg'],
            fg=self.colors['fg'],
            font=('Liberation Serif', 11),
            wrap=tk.WORD,
            padx=15,
            pady=15
        )
        text_widget.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        text_widget.insert(1.0, inspiration_text)
        text_widget.config(state=tk.DISABLED)
    
    def export_css(self):
        """Export theme as CSS file"""
        if not self.current_theme:
            messagebox.showwarning("No Theme", "Generate a theme first")
            return
        
        filename = filedialog.asksaveasfilename(
            defaultextension=".css",
            filetypes=[("CSS files", "*.css"), ("All files", "*.*")]
        )
        
        if filename:
            css_content = self.generate_css_theme()
            with open(filename, 'w') as f:
                f.write(css_content)
            messagebox.showinfo("Export Complete", f"CSS theme exported to {filename}")
    
    def generate_css_theme(self):
        """Generate CSS from current theme"""
        theme = self.current_theme
        
        css_template = f"""
/* {theme['name']} - Generated by DesignDeva */

:root {{
    --primary-color: {theme['primary_color']};
    --secondary-color: {theme['secondary_color']};
    --accent-color: {theme['accent_color']};
    --background-color: {theme['background_color']};
    --text-color: {theme['text_color']};
    --border-radius: {theme['border_radius']};
}}

body {{
    background-color: var(--background-color);
    color: var(--text-color);
    font-family: {theme['typography']['body_font']}, sans-serif;
}}

.dharmic-card {{
    background: var(--secondary-color);
    border: 2px solid var(--primary-color);
    border-radius: var(--border-radius);
    padding: 1rem;
    margin: 1rem 0;
}}

.dharmic-button {{
    background: var(--accent-color);
    color: var(--text-color);
    border: none;
    border-radius: var(--border-radius);
    padding: 0.5rem 1rem;
    cursor: pointer;
    transition: all 0.3s ease;
}}

.dharmic-button:hover {{
    background: var(--primary-color);
    transform: translateY(-2px);
}}
"""
        return css_template
    
    def export_gtk(self):
        """Export as GTK theme (placeholder)"""
        messagebox.showinfo("Coming Soon", "GTK theme export will be available in the next update!")
    
    def save_project(self):
        """Save current design project"""
        if not self.current_theme and not self.current_palette:
            messagebox.showwarning("Nothing to Save", "Create a theme or palette first")
            return
        
        filename = filedialog.asksaveasfilename(
            defaultextension=".json",
            filetypes=[("JSON files", "*.json"), ("All files", "*.*")]
        )
        
        if filename:
            project_data = {
                "theme": self.current_theme,
                "palette": self.current_palette,
                "created_by": "DesignDeva",
                "created_at": str(datetime.now())
            }
            
            with open(filename, 'w') as f:
                json.dump(project_data, f, indent=2)
            
            messagebox.showinfo("Project Saved", f"Design project saved to {filename}")
    
    def run(self):
        """Start the DesignDeva application"""
        self.root.mainloop()

def main():
    """Launch DesignDeva application"""
    app = DesignDevaStudio()
    app.run()

if __name__ == "__main__":
    main()
