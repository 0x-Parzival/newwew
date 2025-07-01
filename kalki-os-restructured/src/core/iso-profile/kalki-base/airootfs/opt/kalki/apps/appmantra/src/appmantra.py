#!/usr/bin/env python3
"""
AppMantra: Intelligent Application Store for Kalki OS
AI-curated software discovery with dharmic principles
"""

import tkinter as tk
from tkinter import ttk, messagebox
import json
import subprocess
from pathlib import Path
from datetime import datetime

class AppMantraStore:
    def __init__(self):
        self.root = tk.Tk()
        self.setup_window()
        self.setup_ui()
        self.featured_apps = self.load_featured_apps()
        self.user_preferences = {}
        
    def setup_window(self):
        """Configure application store window"""
        self.root.title("AppMantra - Dharmic Application Store")
        self.root.geometry("1200x800")
        
        # Store-focused color scheme
        self.colors = {
            'bg': '#0f0f0f',
            'fg': '#e0e0e0',
            'accent': '#00ced1',
            'secondary': '#2f4f4f',
            'success': '#32cd32',
            'featured': '#ff69b4'
        }
        
        self.root.configure(bg=self.colors['bg'])
        
    def setup_ui(self):
        """Create the application store interface"""
        # Top navigation
        nav_frame = ttk.Frame(self.root)
        nav_frame.pack(fill=tk.X, padx=10, pady=10)
        
        # Search section
        search_frame = ttk.Frame(nav_frame)
        search_frame.pack(side=tk.LEFT, fill=tk.X, expand=True)
        
        ttk.Label(search_frame, text="🔍 Discover Dharmic Apps:").pack(side=tk.LEFT, padx=5)
        self.search_entry = ttk.Entry(search_frame, width=40)
        self.search_entry.pack(side=tk.LEFT, padx=5)
        ttk.Button(search_frame, text="Search", command=self.search_apps).pack(side=tk.LEFT, padx=5)
        
        # AI recommendation button
        ttk.Button(nav_frame, text="🧠 AI Recommendations", 
                  command=self.get_ai_recommendations).pack(side=tk.RIGHT, padx=10)
        
        # Category navigation
        category_frame = ttk.Frame(self.root)
        category_frame.pack(fill=tk.X, padx=10, pady=5)
        
        categories = [
            "⭐ Featured", "🎨 Creative", "💼 Productivity", "🔧 System", 
            "🎮 Games", "📚 Education", "🔒 Security", "🕉️ Dharmic"
        ]
        
        for category in categories:
            ttk.Button(category_frame, text=category, 
                      command=lambda c=category: self.show_category(c)).pack(side=tk.LEFT, padx=5)
        
        # Main content area with paned window
        content_paned = ttk.PanedWindow(self.root, orient=tk.HORIZONTAL)
        content_paned.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Left panel: Application list
        list_frame = ttk.Frame(content_paned)
        content_paned.add(list_frame, weight=1)
        
        ttk.Label(list_frame, text="📱 Available Applications", font=('Arial', 12, 'bold')).pack(pady=5)
        
        # Application list with scrollbar
        list_container = ttk.Frame(list_frame)
        list_container.pack(fill=tk.BOTH, expand=True)
        
        self.app_listbox = tk.Listbox(
            list_container,
            bg=self.colors['bg'],
            fg=self.colors['fg'],
            selectbackground=self.colors['accent'],
            font=('Arial', 10),
            height=25
        )
        
        scrollbar = ttk.Scrollbar(list_container, orient=tk.VERTICAL, command=self.app_listbox.yview)
        self.app_listbox.configure(yscrollcommand=scrollbar.set)
        
        self.app_listbox.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        self.app_listbox.bind('<<ListboxSelect>>', self.on_app_select)
        
        # Right panel: Application details
        details_frame = ttk.Frame(content_paned)
        content_paned.add(details_frame, weight=2)
        
        self.setup_details_panel(details_frame)
        
        # Load and display featured apps
        self.show_category("⭐ Featured")
        
    def setup_details_panel(self, parent):
        """Setup application details panel"""
        # App title and rating
        title_frame = ttk.Frame(parent)
        title_frame.pack(fill=tk.X, padx=10, pady=10)
        
        self.app_title = ttk.Label(title_frame, text="Select an application", 
                                  font=('Arial', 16, 'bold'))
        self.app_title.pack(side=tk.LEFT)
        
        self.app_rating = ttk.Label(title_frame, text="")
        self.app_rating.pack(side=tk.RIGHT)
        
        # Screenshot/icon area
        media_frame = ttk.LabelFrame(parent, text="Preview")
        media_frame.pack(fill=tk.X, padx=10, pady=5)
        
        self.app_screenshot = tk.Canvas(
            media_frame,
            bg=self.colors['secondary'],
            height=200,
            highlightthickness=0
        )
        self.app_screenshot.pack(fill=tk.X, padx=10, pady=10)
        
        # Description
        desc_frame = ttk.LabelFrame(parent, text="Description")
        desc_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        self.app_description = tk.Text(
            desc_frame,
            bg=self.colors['bg'],
            fg=self.colors['fg'],
            font=('Liberation Serif', 11),
            wrap=tk.WORD,
            height=10
        )
        self.app_description.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Installation section
        install_frame = ttk.Frame(parent)
        install_frame.pack(fill=tk.X, padx=10, pady=10)
        
        self.install_button = ttk.Button(install_frame, text="Install Application", 
                                        command=self.install_selected_app, state=tk.DISABLED)
        self.install_button.pack(side=tk.LEFT, padx=5)
        
        self.uninstall_button = ttk.Button(install_frame, text="Remove", 
                                          command=self.uninstall_selected_app, state=tk.DISABLED)
        self.uninstall_button.pack(side=tk.LEFT, padx=5)
        
        ttk.Button(install_frame, text="🧠 Ask Avatar Opinion", 
                  command=self.get_avatar_opinion).pack(side=tk.RIGHT, padx=5)
        
    def load_featured_apps(self):
        """Load featured applications catalog"""
        return {
            "⭐ Featured": [
                {
                    "name": "BunniWrite",
                    "description": "AI-assisted writing studio with dharmic mindfulness. Create blogs, stories, and documentation with Bunni's creative guidance.",
                    "category": "Creative",
                    "rating": "⭐⭐⭐⭐⭐",
                    "size": "45 MB",
                    "avatar_recommendation": "Bunni strongly recommends this for all writers!",
                    "dharmic_alignment": 9.5,
                    "installed": True
                },
                {
                    "name": "DesignDeva",
                    "description": "Complete design studio for creating themes, mockups, and visual assets. Generate dharmic color palettes and UI designs.",
                    "category": "Creative",
                    "rating": "⭐⭐⭐⭐⭐",
                    "size": "78 MB",
                    "avatar_recommendation": "G.O.A.T. says this awakens your inner artist!",
                    "dharmic_alignment": 9.0,
                    "installed": True
                },
                {
                    "name": "RoostyTime",
                    "description": "Natural rhythm-based time management. Align your schedule with circadian rhythms and dharmic principles.",
                    "category": "Productivity",
                    "rating": "⭐⭐⭐⭐⭐",
                    "size": "32 MB",
                    "avatar_recommendation": "Roosty: Essential for conscious productivity!",
                    "dharmic_alignment": 9.8,
                    "installed": True
                }
            ],
            "🎨 Creative": [
                {
                    "name": "Raaga Music Studio",
                    "description": "Compose dharmic music and soundscapes. Generate mood-based melodies and ambient sounds for meditation.",
                    "category": "Creative",
                    "rating": "⭐⭐⭐⭐",
                    "size": "156 MB",
                    "avatar_recommendation": "G.O.A.T. loves the spiritual sound generation!",
                    "dharmic_alignment": 8.8,
                    "installed": False
                },
                {
                    "name": "DoodleGoat Sketchpad",
                    "description": "AI-enhanced drawing and sketching with gesture recognition. Express creativity through digital art.",
                    "category": "Creative",
                    "rating": "⭐⭐⭐⭐",
                    "size": "89 MB",
                    "avatar_recommendation": "Perfect for visual meditation and expression",
                    "dharmic_alignment": 8.5,
                    "installed": False
                }
            ],
            "💼 Productivity": [
                {
                    "name": "ChetakDash",
                    "description": "Project and task management with motivation tracking. Gamify your productivity with dharmic principles.",
                    "category": "Productivity",
                    "rating": "⭐⭐⭐⭐",
                    "size": "41 MB",
                    "avatar_recommendation": "Chetak: Boost your focus and achievement!",
                    "dharmic_alignment": 9.2,
                    "installed": False
                },
                {
                    "name": "NagPlan Strategic Planner",
                    "description": "Deep strategic thinking and planning tool. Uses Socratic method to guide decision-making.",
                    "category": "Productivity",
                    "rating": "⭐⭐⭐⭐⭐",
                    "size": "28 MB",
                    "avatar_recommendation": "Nag: Essential for wise decision-making",
                    "dharmic_alignment": 9.7,
                    "installed": False
                }
            ],
            "🔧 System": [
                {
                    "name": "NirvanaFM File Manager",
                    "description": "Intelligent file management with AI suggestions. Organize your digital life mindfully.",
                    "category": "System",
                    "rating": "⭐⭐⭐⭐",
                    "size": "67 MB",
                    "avatar_recommendation": "Essential for organized digital dharma",
                    "dharmic_alignment": 8.0,
                    "installed": False
                },
                {
                    "name": "Shodh Intelligent Search",
                    "description": "System-wide search with AI understanding. Find anything across your entire digital ecosystem.",
                    "category": "System",
                    "rating": "⭐⭐⭐⭐⭐",
                    "size": "52 MB",
                    "avatar_recommendation": "Mushak: Perfect for debugging and finding files!",
                    "dharmic_alignment": 8.5,
                    "installed": False
                }
            ],
            "🕉️ Dharmic": [
                {
                    "name": "Meditation Timer Pro",
                    "description": "Advanced meditation timer with guided sessions. Track your mindfulness practice journey.",
                    "category": "Dharmic",
                    "rating": "⭐⭐⭐⭐⭐",
                    "size": "23 MB",
                    "avatar_recommendation": "Chill Pig: Perfect for inner peace cultivation",
                    "dharmic_alignment": 10.0,
                    "installed": False
                },
                {
                    "name": "Digital Karma Tracker",
                    "description": "Track positive and negative digital actions. Gamify your path to digital enlightenment.",
                    "category": "Dharmic",
                    "rating": "⭐⭐⭐⭐",
                    "size": "15 MB",
                    "avatar_recommendation": "Krix: Essential for conscious computing",
                    "dharmic_alignment": 9.9,
                    "installed": False
                }
            ]
        }
    
    def show_category(self, category):
        """Display applications from selected category"""
        self.app_listbox.delete(0, tk.END)
        
        if category in self.featured_apps:
            for app in self.featured_apps[category]:
                status = "✅" if app.get("installed", False) else "📦"
                display_text = f"{status} {app['name']} - {app['rating']} ({app['size']})"
                self.app_listbox.insert(tk.END, display_text)
    
    def on_app_select(self, event):
        """Handle application selection"""
        selection = self.app_listbox.curselection()
        if not selection:
            return
        
        # Find selected app details
        category = "⭐ Featured"  # Default, in real implementation track current category
        apps = self.featured_apps.get(category, [])
        
        if selection[0] < len(apps):
            app = apps[selection[0]]
            self.display_app_details(app)
    
    def display_app_details(self, app):
        """Display detailed information about selected app"""
        self.app_title.config(text=app['name'])
        self.app_rating.config(text=f"{app['rating']} • Dharmic: {app['dharmic_alignment']}/10")
        
        # Clear and draw screenshot placeholder
        self.app_screenshot.delete("all")
        canvas_width = self.app_screenshot.winfo_width() or 400
        canvas_height = self.app_screenshot.winfo_height() or 200
        
        # Draw app icon/screenshot placeholder
        self.app_screenshot.create_rectangle(10, 10, canvas_width-10, canvas_height-10, 
                                           fill=self.colors['accent'], outline=self.colors['fg'])
        self.app_screenshot.create_text(canvas_width//2, canvas_height//2, 
                                       text=f"📱\n{app['name']}\nScreenshot", 
                                       fill=self.colors['bg'], font=('Arial', 14, 'bold'),
                                       justify=tk.CENTER)
        
        # Update description
        self.app_description.delete(1.0, tk.END)
        
        description_text = f"""{app['description']}

📊 Details:
• Category: {app['category']}
• Size: {app['size']}
• Dharmic Alignment: {app['dharmic_alignment']}/10

🧠 Avatar Opinion:
{app['avatar_recommendation']}

🕉️ Dharmic Benefits:
This application supports mindful technology use and conscious digital living.
"""
        
        self.app_description.insert(1.0, description_text)
        
        # Update buttons
        if app.get("installed", False):
            self.install_button.config(text="Reinstall", state=tk.NORMAL)
            self.uninstall_button.config(state=tk.NORMAL)
        else:
            self.install_button.config(text="Install Application", state=tk.NORMAL)
            self.uninstall_button.config(state=tk.DISABLED)
    
    def search_apps(self):
        """Search for applications"""
        search_term = self.search_entry.get().lower()
        if not search_term:
            messagebox.showwarning("Empty Search", "Please enter a search term")
            return
        
        # Clear current list
        self.app_listbox.delete(0, tk.END)
        
        # Search through all categories
        found_apps = []
        for category, apps in self.featured_apps.items():
            for app in apps:
                if (search_term in app['name'].lower() or 
                    search_term in app['description'].lower() or
                    search_term in app['category'].lower()):
                    found_apps.append(app)
        
        # Display results
        if found_apps:
            for app in found_apps:
                status = "✅" if app.get("installed", False) else "📦"
                display_text = f"{status} {app['name']} - {app['rating']} ({app['size']})"
                self.app_listbox.insert(tk.END, display_text)
        else:
            self.app_listbox.insert(tk.END, "No applications found matching your search")
    
    def get_ai_recommendations(self):
        """Get AI-powered application recommendations"""
        recommendations_window = tk.Toplevel(self.root)
        recommendations_window.title("🧠 AI App Recommendations")
        recommendations_window.geometry("500x400")
        recommendations_window.configure(bg=self.colors['bg'])
        
        # Mock AI recommendations
        recommendations_text = """
🧠 OMNet AI Recommendations for You:

Based on your usage patterns and avatar interactions:

🎨 HIGHLY RECOMMENDED:
• Raaga Music Studio - Your evening meditation sessions suggest you'd love creating ambient soundscapes
• DoodleGoat Sketchpad - Bunni noticed your creative writing style could benefit from visual expression

💼 PRODUCTIVITY BOOST:
• ChetakDash - Your current time management shows 73% efficiency. This could push you to 90%+
• NagPlan - Your decision-making patterns indicate strategic planning tools would help

🔧 SYSTEM OPTIMIZATION:
• NirvanaFM - Your file organization needs improvement (detected 23% duplicate files)
• Shodh Search - You spend 12 minutes daily looking for files - this reduces it to 30 seconds

🕉️ DHARMIC GROWTH:
• Meditation Timer Pro - Perfect for your 6 AM routine
• Digital Karma Tracker - Align your digital actions with spiritual goals

🎯 Confidence Score: 94% - These recommendations are highly tailored to your digital dharma journey.
"""
        
        text_widget = tk.Text(
            recommendations_window,
            bg=self.colors['bg'],
            fg=self.colors['fg'],
            font=('Liberation Serif', 11),
            wrap=tk.WORD
        )
        text_widget.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        text_widget.insert(1.0, recommendations_text)
        text_widget.config(state=tk.DISABLED)
    
    def get_avatar_opinion(self):
        """Get avatar opinion on selected app"""
        # In real implementation, this would query the relevant avatar
        selection = self.app_listbox.curselection()
        if not selection:
            messagebox.showwarning("No Selection", "Please select an application first")
            return
        
        opinion_window = tk.Toplevel(self.root)
        opinion_window.title("💬 Avatar Opinion")
        opinion_window.geometry("400x250")
        opinion_window.configure(bg=self.colors['bg'])
        
        # Mock avatar opinion
        opinion_text = """
🐰 Bunni's Opinion:

"Oh, this application looks absolutely delightful! I can already imagine the beautiful creations you'll make with it. The dharmic alignment is excellent, and the interface seems very user-friendly.

I especially love how it encourages mindful creativity rather than rushed productivity. This aligns perfectly with our philosophy of conscious technology use.

Rating: ⭐⭐⭐⭐⭐
Recommendation: Definitely install this gem!"

Would you like me to guide you through the installation process?
"""
        
        text_widget = tk.Text(
            opinion_window,
            bg=self.colors['bg'],
            fg=self.colors['fg'],
            font=('Liberation Serif', 11),
            wrap=tk.WORD
        )
        text_widget.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        text_widget.insert(1.0, opinion_text)
        text_widget.config(state=tk.DISABLED)
    
    def install_selected_app(self):
        """Install the selected application"""
        selection = self.app_listbox.curselection()
        if not selection:
            messagebox.showwarning("No Selection", "Please select an application to install")
            return
        
        # In real implementation, this would handle actual installation
        app_name = self.app_listbox.get(selection[0]).split(" - ")[0].replace("📦 ", "").replace("✅ ", "")
        
        # Show installation progress
        progress_window = tk.Toplevel(self.root)
        progress_window.title("Installing Application")
        progress_window.geometry("400x200")
        progress_window.configure(bg=self.colors['bg'])
        
        ttk.Label(progress_window, text=f"Installing {app_name}...").pack(pady=20)
        
        progress_bar = ttk.Progressbar(progress_window, mode='indeterminate')
        progress_bar.pack(fill=tk.X, padx=20, pady=10)
        progress_bar.start()
        
        # Simulate installation
        self.root.after(3000, lambda: self.complete_installation(progress_window, app_name))
    
    def complete_installation(self, progress_window, app_name):
        """Complete the installation process"""
        progress_window.destroy()
        messagebox.showinfo("Installation Complete", 
                           f"{app_name} has been installed successfully!\n\nYou can find it in your applications menu.")
    
    def uninstall_selected_app(self):
        """Uninstall the selected application"""
        selection = self.app_listbox.curselection()
        if not selection:
            return
        
        app_name = self.app_listbox.get(selection[0]).split(" - ")[0].replace("✅ ", "").replace("📦 ", "")
        
        if messagebox.askyesno("Confirm Removal", f"Are you sure you want to remove {app_name}?"):
            messagebox.showinfo("Removed", f"{app_name} has been removed from your system.")
    
    def run(self):
        """Start the AppMantra application store"""
        self.root.mainloop()

def main():
    """Launch AppMantra application store"""
    app = AppMantraStore()
    app.run()

if __name__ == "__main__":
    main()
