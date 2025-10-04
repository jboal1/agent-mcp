#!/bin/bash

# Install Custom Claude Commands for Agent MCP
# This script creates slash commands for easy agent access

COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$COMMANDS_DIR"

echo "🚀 Installing Agent MCP slash commands..."

# React Expert Command
cat > "$COMMANDS_DIR/react-expert.sh" << 'EOF'
#!/bin/bash
# /react-expert - Get expert React advice
# Usage: /react-expert <your question>

PROMPT="$*"
echo "🎯 Calling react-expert agent..."
echo ""

# Call the MCP agent via Claude Code
claude chat "Use the mcp__agent-mcp__agent_run tool with agent_id='react-expert' and user_input='$PROMPT'"
EOF

chmod +x "$COMMANDS_DIR/react-expert.sh"

# SQL Debugger Command
cat > "$COMMANDS_DIR/sql-debug.sh" << 'EOF'
#!/bin/bash
# /sql-debug - Debug and optimize SQL queries
# Usage: /sql-debug <your SQL or question>

PROMPT="$*"
echo "🔍 Calling sql-debugger agent..."
echo ""

# Call the MCP agent via Claude Code
claude chat "Use the mcp__agent-mcp__agent_run tool with agent_id='sql-debugger' and user_input='$PROMPT'"
EOF

chmod +x "$COMMANDS_DIR/sql-debug.sh"

# Create agent list command
cat > "$COMMANDS_DIR/agents-list.sh" << 'EOF'
#!/bin/bash
# /agents-list - List all available agents
echo "📋 Available agents:"
echo ""

# Call the MCP agent_list tool
claude chat "Use the mcp__agent-mcp__agent_list tool to show all available agents"
EOF

chmod +x "$COMMANDS_DIR/agents-list.sh"

echo "✅ Installed commands:"
echo "   /react-expert <question>"
echo "   /sql-debug <query>"
echo "   /agents-list"
echo ""
echo "💡 Usage examples:"
echo "   /react-expert Create a TypeScript Button component"
echo "   /sql-debug SELECT * FROM users WHERE created_at > '2024-01-01'"
echo "   /agents-list"
echo ""
echo "🎉 Done! Restart Claude Code to use the new commands."
