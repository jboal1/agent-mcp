#!/bin/bash

# One-command script to share your MCP server

cd /Users/jaredboal/agent-mcp

echo "🚀 Starting Agent MCP Server..."
echo ""

# Start the MCP SSE server in background
npm run mcp:sse > /dev/null 2>&1 &
MCP_PID=$!

# Wait for server to start
sleep 3

# Run the tunnel setup
./setup-tunnel.sh

# Cleanup on exit
trap "kill $MCP_PID 2>/dev/null" EXIT
