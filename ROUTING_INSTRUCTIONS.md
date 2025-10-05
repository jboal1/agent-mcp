# Agent MCP - Routing Instructions for Claude

## Tool Selection Rules

### ALWAYS prefer `agent_quickrun` over `agent_run`

**Why:** Minimal args = cleaner tool preview = better UX

**When to use `agent_quickrun`:**
- User asks a simple question
- Task description is under 200 chars
- No special temperature/config needed
- **99% of use cases**

**Example:**
```
User: "Review this code for bugs"
✅ Use: agent_quickrun(id: "code-reviewer", task: "Review for bugs")
❌ Don't: agent_run(agent_id: "code-reviewer", user_input: "Review this code for bugs...", temperature: 0.2)
```

### Keep tool arguments microscopic

**Rules:**
1. Task descriptions: **< 200 chars** when possible
2. Don't paste code/examples in tool args
3. Don't include formatting/banners
4. Be direct and concise

**Bad (verbose):**
```
agent_run(
  agent_id: "react-expert",
  user_input: "Hey! I need help with React. Here's my code:\n```jsx\n[100 lines]```\nWhat do you think?",
  temperature: 0.3
)
```

**Good (clean):**
```
agent_quickrun(
  id: "react-expert",
  task: "Review LoginForm component for best practices"
)
```

### Return artifacts, not walls of text

**When agent returns long output:**
1. Summarize in ≤2 lines
2. Mention key findings
3. Don't paste everything

**Example:**
```
Agent found 3 issues:
1. Missing error handling (line 42)
2. Performance: memo needed (line 67)
3. TypeScript: add proper types

[Full review available - would you like details on any issue?]
```

## Agent Selection Guide

| User Intent | Use This Agent |
|-------------|----------------|
| React/TypeScript help | `react-expert` |
| SQL optimization | `sql-debug` |
| Git commands/workflows | `git-helper` |
| Debug errors | `debug-this` |
| Generate tests | `test-gen` |
| Code review (comprehensive) | `code-reviewer` |

## Usage Examples

### ✅ Good
```
User: "Why is my SQL query slow?"
→ agent_quickrun(id: "sql-debug", task: "Optimize slow query performance")

User: "Review this component"
→ agent_quickrun(id: "react-expert", task: "Review UserProfile component")

User: "How do I undo a git commit?"
→ agent_quickrun(id: "git-helper", task: "Undo last commit")
```

### ❌ Bad
```
User: "Review this"
→ agent_run(agent_id: "react-expert", user_input: "Please review this code:\n\n```typescript\n// [500 lines of code pasted]\n```\n\nWhat do you think? Any improvements? Should I refactor? Thanks!", temperature: 0.2)
```

## Hard Limits

The server enforces:
- `agent_quickrun` task: max 500 chars
- Rejects overly verbose inputs with error

If you hit limits, tell user to:
1. Break task into smaller parts
2. Use `agent_run` for complex multi-part requests
3. Attach files instead of pasting

## Share Command

When user wants to share agents:
```
agent_share(id: "react-expert")
→ Returns install command and usage instructions
```

## Summary

1. **Default to `agent_quickrun`** (cleaner UI)
2. **Keep args tiny** (< 200 chars ideal)
3. **Summarize results** (don't dump everything)
4. **Use the right agent** (see guide above)

This creates a seamless, fast experience with minimal UI clutter.
