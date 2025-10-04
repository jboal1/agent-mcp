# ✅ MCP Setup Complete!

## Status: Connected ✓

Your Agent MCP server is now successfully connected to Claude Code!

```
agent-mcp: node /Users/jaredboal/agent-mcp/dist/mcp/server.js - ✓ Connected
```

## Configuration Details

- **Scope:** Project config (shared via .mcp.json)
- **Type:** stdio
- **Model:** Claude Sonnet 4.5 (claude-sonnet-4-20250514)
- **Command:** `node /Users/jaredboal/agent-mcp/dist/mcp/server.js`

## Available MCP Tools

### 1. `agent_list`
Lists all available AI agents with their metadata (excluding system prompts)

**Usage in Claude Code:**
```
"Show me the available agents"
"List all agents"
```

### 2. `agent_run`
Execute a specific AI agent with user input. The agent's system prompt remains hidden and secure.

**Parameters:**
- `agent_id` (required): The ID of the agent (e.g., 'react-expert', 'sql-debugger')
- `user_input` (required): Your question/task for the agent
- `temperature` (optional): Response randomness (0.0-1.0, default: 0.2)

**Usage in Claude Code:**
```
"Use the react-expert agent to create a Button component with TypeScript"
"Run sql-debugger with this query: SELECT * FROM users WHERE active=1"
```

## How It Works

1. **You ask Claude Code to use an agent**
2. **Claude Code calls the MCP tool** (agent_run)
3. **Your MCP server receives the request**
4. **Server loads the hidden system prompt** from YAML
5. **Applies security guardrails** (pre/post filtering)
6. **Calls Anthropic API** with the secret prompt
7. **Returns filtered response** to Claude Code
8. **System prompt stays secure** - never exposed!

## Available Agents

### 1. react-expert (v1)
- **Title:** React Expert Engineer
- **Description:** Senior React engineer with strong architecture, testing, and DX
- **Price:** $19
- **Tags:** react, frontend, testing
- **Best for:** Component design, hooks, TypeScript, testing strategies

### 2. sql-debugger (v1)
- **Title:** SQL Query Debugger
- **Description:** Expert at analyzing, optimizing, and debugging SQL queries
- **Price:** $15
- **Tags:** sql, database, optimization, debugging
- **Best for:** Query optimization, index suggestions, debugging N+1 queries

## Quick Commands

### Check MCP Status
```bash
claude mcp list
```

### Get Server Details
```bash
claude mcp get agent-mcp
```

### Remove Server (if needed)
```bash
claude mcp remove agent-mcp -s project
```

### Re-add Server (if needed)
```bash
claude mcp add agent-mcp node /Users/jaredboal/agent-mcp/dist/mcp/server.js \
  --scope user \
  -e ANTHROPIC_API_KEY=your_key \
  -e CLAUDE_MODEL=claude-sonnet-4-20250514
```

## Testing

Try these prompts in Claude Code:

1. **List agents:**
   ```
   "What agents are available via MCP?"
   ```

2. **Use React expert:**
   ```
   "Use the react-expert agent to help me create a reusable Card component with TypeScript"
   ```

3. **Use SQL debugger:**
   ```
   "Run the sql-debugger agent to optimize this query:
   SELECT u.*, p.* FROM users u JOIN posts p ON u.id = p.user_id WHERE u.active = 1"
   ```

## Architecture Recap

```
┌─────────────────┐
│  Claude Code    │ (You interact here)
└────────┬────────┘
         │ MCP Protocol (stdio)
         ▼
┌─────────────────────────────┐
│  Agent MCP Server           │
│  ┌─────────────────────┐   │
│  │ Security Guardrails │   │
│  └─────────────────────┘   │
│  ┌─────────────────────┐   │
│  │ Agent Blueprints    │   │ (Hidden system prompts)
│  │ - react-expert.yaml │   │
│  │ - sql-debugger.yaml │   │
│  └─────────────────────┘   │
│  ┌─────────────────────┐   │
│  │ Anthropic SDK       │   │
│  └─────────────────────┘   │
└─────────────────────────────┘
         │
         ▼
┌─────────────────┐
│ Claude Sonnet 4.5│ (AI execution)
└─────────────────┘
```

## What's Protected

✅ System prompts never leave the server
✅ Pre-filtering blocks jailbreak attempts
✅ Post-filtering redacts leaked instructions
✅ YAML files stay server-side only
✅ API key secured in MCP config

## Files & Locations

- **MCP Config:** `/Users/jaredboal/agent-mcp/.mcp.json`
- **User Config:** `/Users/jaredboal/.claude.json`
- **Server Code:** `/Users/jaredboal/agent-mcp/dist/mcp/server.js`
- **Agents:** `/Users/jaredboal/agent-mcp/dist/agents/*.yaml`

---

**🎉 Your secure AI agent marketplace is live and integrated with Claude Code!**

Now just ask Claude Code to use your agents, and they'll execute with hidden prompts via the MCP protocol.
