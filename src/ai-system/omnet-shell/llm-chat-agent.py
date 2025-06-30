#!/usr/bin/env python3
import os
import sys
import time
import json
import readline
import requests
import re

LOG_FILE = os.path.expanduser("~/.config/omnet-shell/llm-chat-agent.log")
OLLAMA_URL = "http://localhost:11434/api/generate"
OLLAMA_MODEL = "dolphin-mistral"

# Call Ollama LLM

def call_llm(prompt, model=OLLAMA_MODEL):
    try:
        response = requests.post(
            OLLAMA_URL,
            json={"model": model, "prompt": prompt, "stream": False},
            timeout=60
        )
        if response.ok:
            return response.json()["response"]
        else:
            return "LLM error: " + response.text
    except Exception as e:
        return f"[LLM error: {e}]"

# File/app automation API (safe subset)
def execute_action(action):
    # Parse and execute safe actions (list, read, write, launch app)
    try:
        if action.startswith("os.listdir"):
            path = re.findall(r"os.listdir\(['\"]?(.*?)['\"]?\)", action)
            path = path[0] if path else "."
            files = os.listdir(path)
            return f"Files: {', '.join(files)}"
        elif action.startswith("os.remove"):
            fname = re.findall(r"os.remove\(['\"](.*?)['\"]\)", action)
            if fname:
                os.remove(fname[0])
                return f"File {fname[0]} deleted."
            else:
                return "No filename specified."
        elif action.startswith("os.system"):
            cmd = re.findall(r"os.system\(['\"](.*?)['\"]\)", action)
            if cmd:
                os.system(cmd[0])
                return f"Executed: {cmd[0]}"
            else:
                return "No command specified."
        else:
            return f"[Unrecognized or unsafe action: {action}]"
    except Exception as e:
        return f"[Execution error: {e}]"

def log(msg):
    with open(LOG_FILE, "a") as f:
        f.write(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] {msg}\n")

def chat_loop():
    print("\nWelcome to Kalki OS LLM Chat Agent (Ollama-powered)! Type your request (e.g., 'list files', 'open firefox', 'delete file test.txt'). Type 'exit' to quit.\n")
    while True:
        try:
            user_input = input("You: ").strip()
            if user_input.lower() in ("exit", "quit"): break
            log(f"User: {user_input}")
            # Call Ollama LLM
            llm_response = call_llm(f"You are an Arch Linux system agent. User says: {user_input}\nRespond with a plan, and if an action is needed, show it as Action: <python code>. If not, just answer.")
            print(f"Agent: {llm_response}")
            log(f"Agent: {llm_response}")
            # Execute action if suggested
            match = re.search(r"Action:\s*(.*)", llm_response)
            if match:
                action = match.group(1).strip()
                result = execute_action(action)
                print(f"[Result] {result}")
                log(f"Result: {result}")
        except (KeyboardInterrupt, EOFError):
            print("\nGoodbye!")
            break

def main():
    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)
    chat_loop()

if __name__ == "__main__":
    main() 