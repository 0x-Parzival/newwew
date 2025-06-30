# Kalki OS Agent Message Templates

- All agent/overlay messages use templates from this directory.
- Templates are Markdown or text files, loaded dynamically.
- Users can edit templates to change how agents communicate.
- Example: response.md, error.md, plan.md, etc.

## Example Template (plan.md)
```
## Plan
- Task: {{task}}
- Steps:
{{steps}}
``` 