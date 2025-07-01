#!/usr/bin/env python3
"""
Kalki OS AI Terminal
- Modern, AI-powered terminal using prompt_toolkit
- Local LLM (Ollama) integration for command suggestions
- Command palette (Ctrl+P)
- Agent/overlay integration stub
"""
from prompt_toolkit import PromptSession, print_formatted_text
from prompt_toolkit.key_binding import KeyBindings
from prompt_toolkit.completion import Completer, Completion
import requests
import os

OLLAMA_API = os.environ.get('OLLAMA_API', 'http://localhost:11434/api/generate')

class LLMCompleter(Completer):
    def get_completions(self, document, complete_event):
        prompt = document.text
        try:
            response = requests.post(OLLAMA_API, json={"prompt": prompt})
            suggestion = response.json().get("response", "")
            if suggestion:
                yield Completion(suggestion, start_position=-len(prompt))
        except Exception:
            pass

kb = KeyBindings()

@kb.add('c-p')
def _(event):
    """Command palette (Ctrl+P) stub."""
    print_formatted_text("[Command Palette] (TODO: Implement command search/run)")

@kb.add('c-a')
def _(event):
    """Agent/overlay integration stub (Ctrl+A)."""
    print_formatted_text("[Agent/Overlay] (TODO: Integrate avatars/Agent Zero)")

session = PromptSession(completer=LLMCompleter(), key_bindings=kb)

print_formatted_text("Kalki OS AI Terminal (type 'exit' to quit)")
while True:
    try:
        user_input = session.prompt("KalkiOS> ")
        if user_input.strip() == "exit":
            break
        print_formatted_text(f"You entered: {user_input}")
        # TODO: Add command execution, agent/overlay routing, etc.
    except (EOFError, KeyboardInterrupt):
        break
print_formatted_text("Goodbye!") 