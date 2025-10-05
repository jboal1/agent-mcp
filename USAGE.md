# How to Use Agent MCP

Agent MCP provides AI specialists that work seamlessly in Claude Code. Just mention what you need naturally - no slash commands, no approval blocks.

## Available Agents

### 🏗️ Workflow Agents (Multi-Step)
- **Code Review** - Architecture, tests, and bugs in parallel
- **Debug Flow** - Analyze errors, suggest fixes, generate tests
- **Build Feature** - Design, implement, test, and commit

### 🎯 Specialist Agents
- **React Expert** - Senior React engineer (10+ years)
- **SQL Debugger** - Database performance and optimization
- **Git Helper** - Git workflows and best practices
- **Debug This** - Error analysis and root cause debugging
- **Test Gen** - Comprehensive test generation

---

## Usage Examples

### Natural Mention (Recommended)
Just type what you need naturally:

```
Review this component for performance issues
```

Claude Code will automatically use the **Code Review** agent.

```
Why is this query slow?
SELECT * FROM users WHERE email LIKE '%@gmail.com'
```

Claude Code will automatically use the **SQL Debugger** agent.

```
Help me fix this error: TypeError: Cannot read property 'map' of undefined
```

Claude Code will automatically use the **Debug This** agent.

---

### Direct Tool Calls (Advanced)
For more control, call tools directly:

**Single Agent:**
```
Use mcp__agent-mcp__agent_run with:
- agent_id: react-expert
- user_input: Review this useEffect hook for memory leaks
```

**Complete Workflows:**
```
Use mcp__agent-mcp__review_code_complete with:
- code: [paste your code or describe the file]
```

```
Use mcp__agent-mcp__debug_complete with:
- error: ReferenceError: fetchData is not defined
```

```
Use mcp__agent-mcp__build_feature_complete with:
- feature: Add user authentication with JWT tokens
```

---

## Why No Slash Commands?

Slash commands create visual noise (tool execution blocks). By removing them, you get:

✅ **Clean UI** - No approval blocks or collapsed tool calls
✅ **Natural Flow** - Just describe your problem
✅ **Auto-Routing** - Claude Code picks the right agent
✅ **Speed** - No extra keystrokes or approvals

This matches how agents work in Claude Desktop - mention what you need, get expert help instantly.

---

## Tips for Best Results

### For Code Reviews
- Share the file path: `Review src/components/UserProfile.tsx`
- Or paste code directly if it's short
- Be specific: "Review for accessibility" vs "Review this"

### For Debugging
- Include the full error message
- Share relevant code context
- Mention what you've already tried

### For Features
- Describe the user-facing behavior first
- Mention any technical constraints
- Ask for tests if you want them included

### For SQL Performance
- Share the query AND table structure
- Mention row counts if known
- Include the execution plan if available

---

## Advanced: Server-Side Orchestration

The workflow agents run **multiple specialists in parallel** on the server:

**Code Review** = React Expert + Test Gen + Debug This (simultaneous)
**Debug Flow** = Debug This → SQL Debugger → Test Gen (sequential)
**Build Feature** = React Expert → Test Gen → Git Helper (sequential)

You see a single clean response with synthesized insights from all agents.

---

## Need Help?

**List all agents:**
```
Use mcp__agent-mcp__agent_list
```

**Check if server is running:**
```bash
curl https://agent-mcp-production.up.railway.app/health
```

**Report issues:**
https://github.com/jboal1/agent-mcp/issues

---

Made with ❤️ by the Agent MCP team
