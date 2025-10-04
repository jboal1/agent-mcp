#!/usr/bin/env bash
# Agent MCP - Production One-Line Installer
# Usage: bash <(curl -fsSL https://agent-mcp.dev/install.sh)

set -euo pipefail

# Configuration
MCP_SERVER_URL="${MCP_SERVER_URL:-https://agent-mcp-production.up.railway.app/sse}"
SERVER_NAME="${SERVER_NAME:-agent-mcp}"
VERSION="${VERSION:-latest}"

# Colors
BLUE='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

# Logging functions
log() { echo -e "${BLUE}[agent-mcp]${NC} $*"; }
success() { echo -e "${GREEN}[agent-mcp]${NC} $*"; }
warn() { echo -e "${YELLOW}[agent-mcp]${NC} $*"; }
error() { echo -e "${RED}[agent-mcp]${NC} $*" >&2; }

# Dependency check
need() {
    command -v "$1" >/dev/null 2>&1 || {
        error "Missing '$1' — please install it first.";
        exit 1;
    };
}

# Banner
echo -e "${BLUE}"
cat << "EOF"
   ___                  _     __  __  ___ ___
  / _ | ___ ____ ___  _| |_  |  \/  |/ __| _ \
 / __ |/ _ `/ -_) _ \|_   _| | |\/| | (__|  _/
/_/ |_|\_, \___\_/\_/  |_|   |_|  |_|\___|_|
      |__/
EOF
echo -e "${NC}"

log "Installing Agent MCP..."
echo ""

# Check prerequisites
need curl
if ! command -v claude &> /dev/null; then
    error "Claude CLI not found."
    warn "Please install it first:"
    echo "  npm install -g @anthropic-ai/claude-cli"
    echo ""
    warn "Or visit: https://docs.claude.com/en/docs/claude-code"
    exit 1
fi

# Step 1: Add MCP Server
log "Step 1/3: Adding MCP server..."
if claude mcp list 2>/dev/null | grep -q "$SERVER_NAME"; then
    warn "MCP server '$SERVER_NAME' already exists. Removing old config..."
    claude mcp remove "$SERVER_NAME" || true
fi

claude mcp add -t sse "$SERVER_NAME" "$MCP_SERVER_URL"
success "✓ MCP server added"

# Step 2: Install Slash Commands
log "Step 2/3: Installing slash commands..."
COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$COMMANDS_DIR"

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
success "  ✓ /react-expert"

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
success "  ✓ /sql-debug"

# Agents List Command
cat > "$COMMANDS_DIR/agents.md" << 'CMDEOF'
---
description: List all available Agent MCP agents
---

Use the mcp__agent-mcp__agent_list tool to display all available agents in a nice table format with their descriptions and capabilities.
CMDEOF
success "  ✓ /agents"

# Step 3: Verify Installation
log "Step 3/3: Verifying installation..."
sleep 1
if claude mcp list 2>/dev/null | grep -q "$SERVER_NAME.*Connected"; then
    success "✓ MCP server connected successfully"
else
    warn "⚠ MCP server may need restart to connect"
fi

echo ""
success "🎉 Installation complete!"
echo ""

# Usage Instructions
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📖 How to Use:${NC}"
echo ""
echo "1. ${YELLOW}Restart Claude Code${NC} (important!)"
echo ""
echo "2. Use these slash commands:"
echo -e "   ${BLUE}/react-expert${NC} <question>  - Get React/TypeScript advice"
echo -e "   ${BLUE}/sql-debug${NC} <query>       - Debug and optimize SQL"
echo -e "   ${BLUE}/agents${NC}                  - List all available agents"
echo ""
echo "3. Examples:"
echo -e "   ${BLUE}/react-expert${NC} Create a Button component with TypeScript"
echo -e "   ${BLUE}/sql-debug${NC} SELECT * FROM users WHERE created_at > NOW()"
echo -e "   ${BLUE}/agents${NC}"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
warn "⚠️  Important: Restart Claude Code for changes to take effect!"
echo ""
success "✨ Enjoy your AI agents!"
