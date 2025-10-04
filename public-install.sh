#!/bin/bash

# Agent MCP One-Line Installer
# Usage: curl -fsSL https://your-domain.com/install | bash

set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
   ___                  _     __  __  ___ ___
  / _ | ___ ____ ___  _| |_  |  \/  |/ _ \ _ \
 / __ |/ _ `/ -_) _ \|_   _| | |\/| | (_)  _/
/_/ |_|\_, \___\_/\_/  |_|   |_|  |_|\___/_|
      |__/
EOF
echo -e "${NC}"

echo -e "${GREEN}🚀 Installing Agent MCP...${NC}\n"

# Check if Claude CLI is installed
if ! command -v claude &> /dev/null; then
    echo -e "${YELLOW}⚠️  Claude CLI not found. Please install it first:${NC}"
    echo "   npm install -g @anthropic-ai/claude-cli"
    exit 1
fi

# MCP Server URL
MCP_URL="https://julien-semimanneristic-eugene.ngrok-free.dev/sse"
SERVER_NAME="jared-agents"

echo -e "${BLUE}📡 Adding MCP server...${NC}"

# Check if server already exists
if claude mcp list 2>/dev/null | grep -q "$SERVER_NAME"; then
    echo -e "${YELLOW}⚠️  MCP server '$SERVER_NAME' already exists. Skipping...${NC}"
else
    claude mcp add -t sse "$SERVER_NAME" "$MCP_URL"
    echo -e "${GREEN}✅ MCP server added${NC}"
fi

# Create commands directory
COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$COMMANDS_DIR"

echo -e "\n${BLUE}⚡ Installing slash commands...${NC}"

# React Expert Command
cat > "$COMMANDS_DIR/react-expert.md" << 'CMDEOF'
---
description: Get expert React/TypeScript advice from the react-expert agent
argument-hint: <your question>
---

Use the mcp__agent-mcp__agent_run tool to call the react-expert agent with this request:

**Agent ID:** react-expert
**User Input:** $ARGUMENTS
**Temperature:** 0.2

Please display the agent's response clearly and helpfully.
CMDEOF
echo -e "${GREEN}   ✅ /react-expert${NC}"

# SQL Debug Command
cat > "$COMMANDS_DIR/sql-debug.md" << 'CMDEOF'
---
description: Debug and optimize SQL queries with the sql-debugger agent
argument-hint: <your SQL query>
---

Use the mcp__agent-mcp__agent_run tool to call the sql-debugger agent with this query:

**Agent ID:** sql-debugger
**User Input:** $ARGUMENTS
**Temperature:** 0.2

Please analyze the query and display the agent's recommendations clearly.
CMDEOF
echo -e "${GREEN}   ✅ /sql-debug${NC}"

# Agents List Command
cat > "$COMMANDS_DIR/agents.md" << 'CMDEOF'
---
description: List all available Agent MCP agents
---

Use the mcp__agent-mcp__agent_list tool to display all available agents in a nice table format with their descriptions and capabilities.
CMDEOF
echo -e "${GREEN}   ✅ /agents${NC}"

echo -e "\n${GREEN}🎉 Installation complete!${NC}\n"

echo -e "${BLUE}💡 Available commands:${NC}"
echo "   /react-expert <question> - Get React/TypeScript advice"
echo "   /sql-debug <query>       - Debug and optimize SQL"
echo "   /agents                  - List all agents"

echo -e "\n${BLUE}📖 Examples:${NC}"
echo "   /react-expert Create a Button component with TypeScript"
echo "   /sql-debug SELECT * FROM users WHERE created_at > NOW()"
echo "   /agents"

echo -e "\n${YELLOW}⚠️  Restart Claude Code for changes to take effect${NC}\n"

echo -e "${GREEN}✨ Enjoy your AI agents!${NC}"
