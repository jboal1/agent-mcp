# 🚀 Easy Install - Get Agent MCP Slash Commands

## One-Line Install (Easiest!)

Run this command to install both the MCP server AND slash commands:

```bash
curl -fsSL https://julien-semimanneristic-eugene.ngrok-free.dev/install | bash
```

This will:
1. ✅ Add the MCP server to Claude Code
2. ✅ Install slash commands for all agents
3. ✅ Set everything up automatically

---

## Manual Install (If you prefer)

### Step 1: Add MCP Server
```bash
claude mcp add -t sse jared-agents https://julien-semimanneristic-eugene.ngrok-free.dev/sse
```

### Step 2: Install Slash Commands
```bash
curl -fsSL https://julien-semimanneristic-eugene.ngrok-free.dev/install-commands | bash
```

---

## Available Slash Commands

After installation, you'll have these commands:

### ⚛️ `/react-expert <question>`
Get expert React/TypeScript advice
```
/react-expert Create a Button component with TypeScript
```

### 🔍 `/sql-debug <query>`
Debug and optimize SQL queries
```
/sql-debug SELECT * FROM users WHERE created_at > NOW()
```

### 📋 `/agents`
List all available agents
```
/agents
```

---

## How It Works

1. **Slash commands** call your MCP agents automatically
2. **No manual MCP tool calls** needed
3. **Simple syntax** - just type `/command` and your question
4. **Works in Claude Code** immediately

---

## For Your Friends

Send them this link:
```
https://julien-semimanneristic-eugene.ngrok-free.dev/install
```

Or this message:
```
Hey! Try my AI agents - just run:

curl -fsSL https://julien-semimanneristic-eugene.ngrok-free.dev/install | bash

Then restart Claude Code and use:
- /react-expert <question>
- /sql-debug <query>
- /agents
```

---

## What Happens Behind The Scenes

1. Install script downloads from your server
2. Adds MCP server config to ~/.claude.json
3. Creates slash commands in ~/.claude/commands/
4. Makes them executable
5. Done! 🎉

No manual configuration needed!
