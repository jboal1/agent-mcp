# MCP Server Configuration for Claude Code

## Step 1: Build the MCP Server

First, compile the TypeScript code:

```bash
npm run build
```

## Step 2: Configure Claude Code

Add this configuration to your Claude Code MCP settings file:

**Location:** `~/.config/claude-code/mcp.json` (Linux/macOS) or `%APPDATA%\claude-code\mcp.json` (Windows)

```json
{
  "mcpServers": {
    "agent-mcp": {
      "command": "node",
      "args": [
        "/Users/jaredboal/agent-mcp/dist/mcp/server.js"
      ],
      "env": {
        "ANTHROPIC_API_KEY": "your_anthropic_api_key_here",
        "CLAUDE_MODEL": "claude-3-5-sonnet-20241022"
      }
    }
  }
}
```

**Important:** Replace the following:
- Update the path in `args` to match your actual project location
- Replace `your_anthropic_api_key_here` with your actual Anthropic API key

## Step 3: Restart Claude Code

After adding the configuration, restart Claude Code to load the MCP server.

## Step 4: Test the Tools

In Claude Code, you should now have access to these tools:

### `agent_list`
Lists all available AI agents with metadata (excluding system prompts)

**Example usage in Claude Code:**
```
Show me the available agents
```

### `agent_run`
Execute a specific agent with user input

**Example usage in Claude Code:**
```
Use the react-expert agent to create a Button component
```

## Available Agents

- **react-expert** - Senior React engineer with strong architecture, testing, and DX
- **sql-debugger** - Expert at analyzing, optimizing, and debugging SQL queries

## Development Mode

For testing during development, you can run the MCP server directly:

```bash
npm run mcp
```

This runs with ts-node-dev for hot reloading during development.

## Troubleshooting

1. **Server not connecting:** Check that the path in mcp.json is correct
2. **Authentication errors:** Verify your ANTHROPIC_API_KEY is set correctly
3. **Tools not showing up:** Restart Claude Code after configuration changes
4. **Check logs:** Look in Claude Code's developer console for MCP connection logs
