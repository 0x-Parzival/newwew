#!/usr/bin/env python3
"""
RoostyTime: Dharmic Time Management for Kalki OS
Natural rhythm scheduling with mindful productivity
"""

import tkinter as tk
from tkinter import ttk, messagebox
import json
import calendar
import math
from datetime import datetime, timedelta, time
from pathlib import Path

class RoostyTimeManager:
    def __init__(self):
        self.root = tk.Tk()
        self.setup_window()
        self.setup_ui()
        self.current_date = datetime.now().date()
        self.tasks = {}
        self.daily_rhythms = {}
        self.load_user_data()
        
    def setup_window(self):
        """Configure main window with time-focused design"""
        self.root.title("RoostyTime - Dharmic Time Management")
        self.root.geometry("1200x800")
        
        # Time-focused color scheme
        self.colors = {
            'bg': '#0a0a0a',
            'fg': '#ffd700',
            'accent': '#ff6347',
            'secondary': '#4b0000',
            'success': '#228b22',
            'dawn': '#ffb347',
            'noon': '#ffd700',
            'dusk': '#ff6347',
            'night': '#191970'
        }
        
        self.root.configure(bg=self.colors['bg'])
        
    def setup_ui(self):
        """Create the time management interface"""
        # Main notebook for different views
        notebook = ttk.Notebook(self.root)
        notebook.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Daily view
        self.daily_frame = ttk.Frame(notebook)
        notebook.add(self.daily_frame, text="📅 Daily Flow")
        self.setup_daily_view()
        
        # Weekly view
        self.weekly_frame = ttk.Frame(notebook)
        notebook.add(self.weekly_frame, text="📊 Weekly Rhythm")
        self.setup_weekly_view()
        
        # Goals & Intentions
        self.goals_frame = ttk.Frame(notebook)
        notebook.add(self.goals_frame, text="🎯 Goals & Dharma")
        self.setup_goals_view()
        
        # Natural rhythms
        self.rhythms_frame = ttk.Frame(notebook)
        notebook.add(self.rhythms_frame, text="🌅 Natural Rhythms")
        self.setup_rhythms_view()
        
    def setup_daily_view(self):
        """Setup daily schedule and task management"""
        # Header with date and Roosty interaction
        header_frame = ttk.Frame(self.daily_frame)
        header_frame.pack(fill=tk.X, padx=10, pady=10)
        
        date_label = ttk.Label(header_frame, text=f"📅 {self.current_date.strftime('%A, %B %d, %Y')}", 
                              font=('Arial', 16, 'bold'))
        date_label.pack(side=tk.LEFT)
        
        ttk.Button(header_frame, text="🐓 Morning Call with Roosty", 
                  command=self.morning_roosty_call).pack(side=tk.RIGHT, padx=10)
        
        # Time blocks visualization
        schedule_frame = ttk.LabelFrame(self.daily_frame, text="Daily Schedule - Natural Time Blocks")
        schedule_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        # Create time block canvas
        self.schedule_canvas = tk.Canvas(
            schedule_frame,
            bg=self.colors['bg'],
            height=500,
            highlightthickness=0
        )
        self.schedule_canvas.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        self.draw_daily_schedule()
        
        # Task entry area
        task_entry_frame = ttk.Frame(self.daily_frame)
        task_entry_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Label(task_entry_frame, text="Add Task:").pack(side=tk.LEFT)
        self.task_entry = ttk.Entry(task_entry_frame, width=40)
        self.task_entry.pack(side=tk.LEFT, padx=10)
        
        time_label = ttk.Label(task_entry_frame, text="Time:")
        time_label.pack(side=tk.LEFT, padx=(20, 5))
        
        self.task_time = ttk.Combobox(task_entry_frame, values=[
            "06:00 - Dawn Meditation", "09:00 - Deep Work", "12:00 - Midday Break",
            "15:00 - Creative Flow", "18:00 - Evening Reflection", "21:00 - Night Prep"
        ], width=20)
        self.task_time.pack(side=tk.LEFT, padx=5)
        
        ttk.Button(task_entry_frame, text="Add Task", command=self.add_task).pack(side=tk.LEFT, padx=10)
        
    def setup_weekly_view(self):
        """Setup weekly overview and patterns"""
        weekly_header = ttk.Label(self.weekly_frame, text="📊 Weekly Rhythm Analysis", 
                                 font=('Arial', 14, 'bold'))
        weekly_header.pack(pady=10)
        
        # Weekly calendar grid
        calendar_frame = ttk.Frame(self.weekly_frame)
        calendar_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=10)
        
        # Days of week
        days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
        
        for i, day in enumerate(days):
            day_frame = ttk.LabelFrame(calendar_frame, text=day)
            day_frame.grid(row=0, column=i, sticky="nsew", padx=2, pady=2)
            calendar_frame.columnconfigure(i, weight=1)
            
            # Energy level indicator
            energy_canvas = tk.Canvas(day_frame, height=60, bg=self.colors['bg'])
            energy_canvas.pack(fill=tk.X, padx=5, pady=5)
            
            # Mock energy levels - in real implementation, track from user data
            energy_level = [80, 90, 75, 85, 70, 60, 50][i]  # Example data
            bar_height = int(50 * energy_level / 100)
            color = self.get_energy_color(energy_level)
            
            energy_canvas.create_rectangle(10, 50-bar_height, 30, 50, fill=color, outline=color)
            energy_canvas.create_text(40, 25, text=f"{energy_level}%", fill=self.colors['fg'], anchor="w")
        
        calendar_frame.rowconfigure(0, weight=1)
        
        # Weekly insights
        insights_frame = ttk.LabelFrame(self.weekly_frame, text="🔍 Roosty's Weekly Insights")
        insights_frame.pack(fill=tk.X, padx=20, pady=10)
        
        insights_text = tk.Text(
            insights_frame,
            height=8,
            bg=self.colors['bg'],
            fg=self.colors['fg'],
            font=('Liberation Serif', 11),
            wrap=tk.WORD
        )
        insights_text.pack(fill=tk.X, padx=10, pady=10)
        
        # Mock insights from Roosty
        mock_insights = """🐓 Roosty's Weekly Analysis:

Your peak energy days are Tuesday and Thursday - schedule important projects then!

You're maintaining good morning consistency (87% on-time wake-ups). Keep it up!

Friday afternoons show energy dips - consider lighter tasks or creative work.

Your weekend recovery rhythm is excellent for maintaining weekly balance.

💡 Suggestion: Try 25-minute focus blocks on Wednesday when energy fluctuates."""
        
        insights_text.insert(1.0, mock_insights)
        insights_text.config(state=tk.DISABLED)
        
    def setup_goals_view(self):
        """Setup goals and dharmic intention tracking"""
        goals_header = ttk.Label(self.goals_frame, text="🎯 Dharmic Goals & Intentions", 
                                font=('Arial', 14, 'bold'))
        goals_header.pack(pady=10)
        
        # Goals categories
        categories = ["🧠 Learning & Growth", "💼 Work & Service", "🕉️ Spiritual Practice", 
                     "💚 Health & Wellbeing", "🤝 Relationships", "🎨 Creative Expression"]
        
        goals_notebook = ttk.Notebook(self.goals_frame)
        goals_notebook.pack(fill=tk.BOTH, expand=True, padx=20, pady=10)
        
        for category in categories:
            category_frame = ttk.Frame(goals_notebook)
            goals_notebook.add(category_frame, text=category)
            
            # Goal entry area
            entry_frame = ttk.Frame(category_frame)
            entry_frame.pack(fill=tk.X, padx=10, pady=10)
            
            ttk.Label(entry_frame, text="New Goal/Intention:").pack(anchor=tk.W)
            goal_entry = ttk.Entry(entry_frame, width=50)
            goal_entry.pack(fill=tk.X, pady=5)
            
            importance_frame = ttk.Frame(entry_frame)
            importance_frame.pack(fill=tk.X, pady=5)
            
            ttk.Label(importance_frame, text="Dharmic Alignment:").pack(side=tk.LEFT)
            importance_scale = ttk.Scale(importance_frame, from_=1, to=10, orient=tk.HORIZONTAL)
            importance_scale.pack(side=tk.LEFT, padx=10, fill=tk.X, expand=True)
            importance_scale.set(7)
            
            ttk.Button(entry_frame, text="Set Intention", 
                      command=lambda c=category, g=goal_entry, i=importance_scale: 
                      self.add_goal(c, g.get(), i.get())).pack(pady=5)
            
            # Goals list
            goals_list = tk.Listbox(category_frame, height=10, bg=self.colors['bg'], fg=self.colors['fg'])
            goals_list.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
            
    def setup_rhythms_view(self):
        """Setup natural rhythm tracking and optimization"""
        rhythms_header = ttk.Label(self.rhythms_frame, text="🌅 Natural Rhythm Optimization", 
                                  font=('Arial', 14, 'bold'))
        rhythms_header.pack(pady=10)
        
        # Circadian rhythm visualization
        rhythm_canvas = tk.Canvas(
            self.rhythms_frame,
            bg=self.colors['bg'],
            height=300,
            highlightthickness=0
        )
        rhythm_canvas.pack(fill=tk.X, padx=20, pady=10)
        
        self.draw_circadian_rhythm(rhythm_canvas)
        
        # Rhythm configuration
        config_frame = ttk.LabelFrame(self.rhythms_frame, text="⚙️ Rhythm Configuration")
        config_frame.pack(fill=tk.X, padx=20, pady=10)
        
        # Wake time
        wake_frame = ttk.Frame(config_frame)
        wake_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Label(wake_frame, text="🌅 Preferred Wake Time:").pack(side=tk.LEFT)
        self.wake_time = ttk.Combobox(wake_frame, values=[
            "05:00 - Early Riser", "06:00 - Dawn Warrior", "07:00 - Standard",
            "08:00 - Gentle Start", "09:00 - Late Riser"
        ])
        self.wake_time.pack(side=tk.LEFT, padx=10)
        self.wake_time.set("06:00 - Dawn Warrior")
        
        # Sleep time
        sleep_frame = ttk.Frame(config_frame)
        sleep_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Label(sleep_frame, text="🌙 Preferred Sleep Time:").pack(side=tk.LEFT)
        self.sleep_time = ttk.Combobox(sleep_frame, values=[
            "21:00 - Early Rest", "22:00 - Standard", "23:00 - Night Owl",
            "24:00 - Late Night", "01:00 - Very Late"
        ])
        self.sleep_time.pack(side=tk.LEFT, padx=10)
        self.sleep_time.set("22:00 - Standard")
        
        # Energy optimization
        ttk.Button(config_frame, text="🐓 Ask Roosty for Rhythm Optimization", 
                  command=self.get_rhythm_advice).pack(pady=10)
        
    def draw_daily_schedule(self):
        """Draw visual daily schedule with natural time blocks"""
        canvas = self.schedule_canvas
        canvas.delete("all")
        
        # Time periods with natural themes
        time_blocks = [
            (6, 9, "🌅 Dawn - Deep Work", self.colors['dawn']),
            (9, 12, "☀️ Morning - Collaboration", self.colors['noon']),
            (12, 14, "🕛 Midday - Rest & Nourishment", self.colors['accent']),
            (14, 17, "🌤️ Afternoon - Creative Flow", self.colors['noon']),
            (17, 19, "🌆 Evening - Reflection", self.colors['dusk']),
            (19, 22, "🌙 Night - Personal Time", self.colors['night'])
        ]
        
        canvas_width = canvas.winfo_width() or 800
        canvas_height = canvas.winfo_height() or 400
        
        block_height = canvas_height / len(time_blocks)
        
        for i, (start_hour, end_hour, label, color) in enumerate(time_blocks):
            y1 = i * block_height
            y2 = (i + 1) * block_height
            
            # Draw time block
            canvas.create_rectangle(0, y1, canvas_width, y2, fill=color, outline=self.colors['fg'], width=1)
            
            # Add label
            canvas.create_text(20, y1 + block_height/2, text=label, fill=self.colors['bg'], 
                             font=('Arial', 12, 'bold'), anchor="w")
            
            # Add time range
            time_range = f"{start_hour:02d}:00 - {end_hour:02d}:00"
            canvas.create_text(canvas_width - 20, y1 + block_height/2, text=time_range, 
                             fill=self.colors['bg'], font=('Arial', 10), anchor="e")
    
    def draw_circadian_rhythm(self, canvas):
        """Draw circadian rhythm visualization"""
        canvas.delete("all")
        
        canvas_width = canvas.winfo_width() or 800
        canvas_height = canvas.winfo_height() or 250
        
        # Draw 24-hour cycle
        center_x = canvas_width // 2
        center_y = canvas_height // 2
        radius = min(center_x, center_y) - 40
        
        # Draw circle for 24 hours
        canvas.create_oval(center_x - radius, center_y - radius, 
                          center_x + radius, center_y + radius, 
                          outline=self.colors['fg'], width=2)
        
        # Mark hours
        for hour in range(24):
            angle = (hour * 15 - 90) * 3.14159 / 180  # Convert to radians, start at top
            x = center_x + radius * 0.9 * math.cos(angle)
            y = center_y + radius * 0.9 * math.sin(angle)
            
            # Color code by natural energy levels
            if 6 <= hour <= 10:
                color = self.colors['dawn']  # High energy morning
            elif 11 <= hour <= 15:
                color = self.colors['noon']  # Peak day energy
            elif 16 <= hour <= 19:
                color = self.colors['dusk']  # Afternoon energy
            else:
                color = self.colors['night']  # Low energy night
            
            canvas.create_oval(x-8, y-8, x+8, y+8, fill=color, outline=self.colors['fg'])
            canvas.create_text(x, y, text=str(hour), fill=self.colors['bg'], font=('Arial', 8, 'bold'))
        
        # Add center label
        canvas.create_text(center_x, center_y, text="🕐\nCircadian\nRhythm", 
                          fill=self.colors['fg'], font=('Arial', 10, 'bold'), justify=tk.CENTER)
        
        # Add legend
        legend_y = canvas_height - 30
        legend_items = [
            ("🌅 Morning Peak", self.colors['dawn']),
            ("☀️ Day Active", self.colors['noon']),
            ("🌆 Evening Wind", self.colors['dusk']),
            ("🌙 Night Rest", self.colors['night'])
        ]
        
        for i, (label, color) in enumerate(legend_items):
            x = 20 + i * 180
            canvas.create_rectangle(x, legend_y, x+15, legend_y+15, fill=color, outline=self.colors['fg'])
            canvas.create_text(x+20, legend_y+7, text=label, fill=self.colors['fg'], anchor="w")
    
    def morning_roosty_call(self):
        """Interactive morning session with Roosty"""
        roosty_window = tk.Toplevel(self.root)
        roosty_window.title("🐓 Morning Call with Roosty")
        roosty_window.geometry("500x400")
        roosty_window.configure(bg=self.colors['bg'])
        
        # Roosty's morning message
        message_text = f"""
🐓 COCK-A-DOODLE-DOO! Good morning, dharmic warrior!

It's {datetime.now().strftime('%A, %B %d')} and the sun is ready to power your day!

Today's Energy Forecast: ⚡⚡⚡⚡☆ (4/5 stars)

🌅 Your morning ritual:
• Deep breath meditation (5 minutes)
• Set your dharmic intention for today
• Review your top 3 priorities
• Hydrate with consciousness

💪 Peak energy windows today:
• 9:00-11:00 AM - Perfect for deep work
• 2:00-4:00 PM - Creative flow time

🎯 Remember: Progress over perfection!
Every mindful action is a victory.

What's your primary intention for today?
"""
        
        text_widget = tk.Text(
            roosty_window,
            bg=self.colors['bg'],
            fg=self.colors['fg'],
            font=('Liberation Serif', 11),
            wrap=tk.WORD,
            height=15
        )
        text_widget.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        text_widget.insert(1.0, message_text)
        text_widget.config(state=tk.DISABLED)
        
        # Intention entry
        entry_frame = ttk.Frame(roosty_window)
        entry_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Label(entry_frame, text="Today's Intention:").pack(anchor=tk.W)
        intention_entry = ttk.Entry(entry_frame, width=50)
        intention_entry.pack(fill=tk.X, pady=5)
        
        ttk.Button(entry_frame, text="🐓 Set Intention & Start Day", 
                  command=lambda: self.set_daily_intention(intention_entry.get(), roosty_window)).pack(pady=5)
    
    def add_task(self):
        """Add task to current day"""
        task_text = self.task_entry.get()
        task_time = self.task_time.get()
        
        if task_text and task_time:
            # In real implementation, save to data structure
            messagebox.showinfo("Task Added", f"Added '{task_text}' at {task_time}")
            self.task_entry.delete(0, tk.END)
        else:
            messagebox.showwarning("Incomplete", "Please enter both task and time")
    
    def get_energy_color(self, energy_level):
        """Get color based on energy level"""
        if energy_level >= 80:
            return self.colors['success']
        elif energy_level >= 60:
            return self.colors['noon']
        elif energy_level >= 40:
            return self.colors['dusk']
        else:
            return self.colors['night']
    
    def add_goal(self, category, goal_text, importance):
        """Add new goal to category"""
        if goal_text:
            messagebox.showinfo("Goal Set", f"Added '{goal_text}' to {category} with dharmic alignment: {int(importance)}/10")
    
    def get_rhythm_advice(self):
        """Get rhythm optimization advice from Roosty"""
        advice_window = tk.Toplevel(self.root)
        advice_window.title("🐓 Roosty's Rhythm Wisdom")
        advice_window.geometry("400x300")
        advice_window.configure(bg=self.colors['bg'])
        
        advice_text = """
🐓 Roosty's Circadian Wisdom:

Based on your preferences, here's your optimal rhythm:

🌅 6:00 AM Wake-up aligns perfectly with natural sunrise energy
🧠 9:00-11:00 AM is your cognitive peak - schedule important work here
🍽️ 12:00-1:00 PM natural energy dip - perfect for mindful eating
⚡ 2:00-4:00 PM afternoon energy surge - great for creative tasks
🌆 6:00-8:00 PM wind-down period - reflection and light activities
🌙 10:00 PM sleep prep starts - digital sunset begins

💡 Pro tips:
• Natural light exposure within 30 minutes of waking
• Avoid caffeine after 2:00 PM
• Create evening ritual 1 hour before sleep
• Weekend consistency keeps rhythm strong

Your current pattern scores 8.5/10 for natural alignment!
"""
        
        text_widget = tk.Text(
            advice_window,
            bg=self.colors['bg'],
            fg=self.colors['fg'],
            font=('Liberation Serif', 10),
            wrap=tk.WORD
        )
        text_widget.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        text_widget.insert(1.0, advice_text)
        text_widget.config(state=tk.DISABLED)
    
    def set_daily_intention(self, intention, window):
        """Set and save daily intention"""
        if intention:
            messagebox.showinfo("Intention Set", f"Today's dharmic intention: '{intention}'\nRoosty will help you stay aligned!")
            window.destroy()
    
    def load_user_data(self):
        """Load user's saved data"""
        # In real implementation, load from Dev.dat or local storage
        pass
    
    def save_user_data(self):
        """Save user's data"""
        # In real implementation, save to Dev.dat
        pass
    
    def run(self):
        """Start the RoostyTime application"""
        self.root.mainloop()

def main():
    """Launch RoostyTime application"""
    app = RoostyTimeManager()
    app.run()

if __name__ == "__main__":
    main()
