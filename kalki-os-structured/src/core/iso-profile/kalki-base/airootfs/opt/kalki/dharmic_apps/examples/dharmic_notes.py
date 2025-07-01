#!/usr/bin/env python3
"""
Dharmic Notes - A mindful note-taking application
Integrates with avatar system for enhanced productivity
"""

import os
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

# Add parent directory to path
sys.path.append(str(Path(__file__).parent.parent.parent))
from dharmic_apps import DharmicApp, UIModule
from rich.console import Console
from rich.panel import Panel
from rich.text import Text
from prompt_toolkit import PromptSession
from prompt_toolkit.completion import WordCompleter

class NotesUI(UIModule):
    """UI Module for Dharmic Notes"""
    
    def __init__(self, app: 'DharmicNotes'):
        self.app = app
        self.console = Console()
        self.session = PromptSession()
        self.commands = [
            'new', 'list', 'view', 'edit', 'delete',
            'search', 'tag', 'help', 'exit'
        ]
        self.completer = WordCompleter(self.commands)
    
    def render_header(self) -> None:
        """Render application header"""
        title = Text("🕉️ Dharmic Notes", style="bold blue")
        if self.app.current_note:
            title.append(f" | {self.app.current_note['title']}", style="dim")
        
        self.console.print(Panel(
            title,
            border_style="blue"
        ))
    
    def render_help(self) -> None:
        """Display help information"""
        help_text = """
[bold]Available Commands:[/bold]
  new       - Create a new note
  list      - List all notes
  view <id> - View a specific note
  edit <id> - Edit a note
  delete <id> - Delete a note
  search <query> - Search notes
  tag <id> <tags> - Add tags to note
  help      - Show this help
  exit      - Exit Dharmic Notes

[dim]Tip: Type @ to get avatar assistance while editing notes[/dim]
"""
        self.console.print(Panel(help_text, title="Help", border_style="blue"))
    
    def render(self, context: Dict) -> None:
        """Render the main UI"""
        os.system('clear' if os.name == 'posix' else 'cls')
        self.render_header()
        
        if 'message' in context:
            self.console.print(f"[green]{context['message']}[/green]")
        
        if 'error' in context:
            self.console.print(f"[red]Error: {context['error']}[/red]")
        
        if 'content' in context:
            self.console.print(Panel(
                context['content'],
                title=context.get('title', 'Note'),
                border_style="green"
            ))
    
    def get_user_input(self) -> str:
        """Get user input with command completion"""
        try:
            return self.session.prompt(
                "📝 > ",
                completer=self.completer,
                complete_while_typing=True
            )
        except KeyboardInterrupt:
            return "exit"
        except EOFError:
            return "exit"

class DharmicNotes(DharmicApp):
    """Dharmic Notes - A mindful note-taking application"""
    
    def __init__(self):
        super().__init__("dharmic_notes", "A mindful note-taking application")
        self.current_note = None
        self.notes = self.storage.load_data('notes', [])
        self.ui = NotesUI(self)
    
    def save_notes(self) -> bool:
        """Save notes to storage"""
        return self.storage.save_data('notes', self.notes)
    
    def create_note(self, title: str, content: str, tags: List[str] = None) -> Dict:
        """Create a new note"""
        note = {
            'id': len(self.notes) + 1,
            'title': title,
            'content': content,
            'tags': tags or [],
            'created_at': datetime.now().isoformat(),
            'updated_at': datetime.now().isoformat()
        }
        self.notes.append(note)
        self.save_notes()
        return note
    
    def update_note(self, note_id: int, **updates) -> Optional[Dict]:
        """Update an existing note"""
        for note in self.notes:
            if note['id'] == note_id:
                note.update(updates)
                note['updated_at'] = datetime.now().isoformat()
                self.save_notes()
                return note
        return None
    
    def delete_note(self, note_id: int) -> bool:
        """Delete a note by ID"""
        for i, note in enumerate(self.notes):
            if note['id'] == note_id:
                del self.notes[i]
                self.save_notes()
                return True
        return False
    
    def search_notes(self, query: str) -> List[Dict]:
        """Search notes by content or tags"""
        query = query.lower()
        return [
            note for note in self.notes
            if query in note['content'].lower() or
               query in ' '.join(note.get('tags', [])).lower() or
               query in note['title'].lower()
        ]
    
    def process_command(self, command: str) -> Dict:
        """Process user command"""
        parts = command.strip().split(maxsplit=1)
        cmd = parts[0].lower() if parts else ""
        args = parts[1] if len(parts) > 1 else ""
        
        if cmd == 'new':
            title = input("Title: ")
            print("Enter your note (Ctrl+D when finished):")
            content = sys.stdin.read()
            note = self.create_note(title, content)
            return {
                'message': f"Created note #{note['id']}",
                'content': note['content'],
                'title': note['title']
            }
            
        elif cmd == 'list':
            if not self.notes:
                return {'message': "No notes found"}
                
            notes_list = "\n".join(
                f"{note['id']}. {note['title']} - {note['created_at'].split('T')[0]}"
                for note in sorted(self.notes, key=lambda x: x['created_at'], reverse=True)
            )
            return {'content': notes_list, 'title': 'Your Notes'}
            
        elif cmd == 'view' and args.strip().isdigit():
            note_id = int(args.strip())
            for note in self.notes:
                if note['id'] == note_id:
                    self.current_note = note
                    return {
                        'content': note['content'],
                        'title': note['title']
                    }
            return {'error': f"Note #{note_id} not found"}
            
        elif cmd == 'help':
            return {'content': "Type 'help' to see available commands"}
            
        elif cmd == 'exit':
            return {'exit': True}
            
        else:
            return {'error': f"Unknown command: {cmd}"}
    
    def run(self) -> None:
        """Main application loop"""
        context = {}
        
        while True:
            self.ui.render(context)
            context = {}
            
            try:
                command = self.ui.get_user_input()
                if not command:
                    continue
                    
                if command.lower() in ('exit', 'quit'):
                    break
                    
                result = self.process_command(command)
                if 'exit' in result:
                    break
                    
                context.update(result)
                
            except Exception as e:
                context['error'] = str(e)

if __name__ == "__main__":
    app = DharmicNotes()
    try:
        app.run()
    except KeyboardInterrupt:
        print("\n🕉️ Thank you for using Dharmic Notes. May your thoughts be clear and mindful.")
    finally:
        app.cleanup()
