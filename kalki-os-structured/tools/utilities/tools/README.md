# Kalki OS Agent Tools

- Each tool is a Python script or class in this directory.
- Tools are loaded dynamically by the agent/overlay system.
- Users can add, remove, or modify tools to extend agent capabilities.
- Example tools: online search, memory, code execution, file management, etc.

## Example Tool (search.py)
```python
def run(query):
    # Implement search logic here
    return f"Results for {query}"
``` 