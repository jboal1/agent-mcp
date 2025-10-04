#!/bin/bash

# Automated Ngrok Setup for Agent MCP

echo "🚀 Setting up public access to your Agent MCP server..."
echo ""

# Check if ngrok is configured
if ngrok config check 2>/dev/null | grep -q "Valid"; then
    echo "✅ Ngrok already configured!"
else
    echo "📋 Ngrok Setup Instructions:"
    echo ""
    echo "1. A browser window should have opened to https://dashboard.ngrok.com/signup"
    echo "2. Sign up (free) with Google/GitHub or email"
    echo "3. Copy your authtoken from: https://dashboard.ngrok.com/get-started/your-authtoken"
    echo ""
    read -p "Paste your ngrok authtoken here: " AUTHTOKEN

    if [ -z "$AUTHTOKEN" ]; then
        echo "❌ No authtoken provided. Exiting."
        exit 1
    fi

    echo ""
    echo "Configuring ngrok..."
    ngrok config add-authtoken "$AUTHTOKEN"
    echo "✅ Ngrok configured!"
fi

echo ""
echo "🌐 Starting public tunnel..."
echo ""

# Start ngrok in background and capture output
ngrok http 3002 --log=stdout > /tmp/ngrok.log 2>&1 &
NGROK_PID=$!

# Wait for ngrok to start
sleep 3

# Get the public URL
PUBLIC_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"https://[^"]*' | head -1 | cut -d'"' -f4)

if [ -z "$PUBLIC_URL" ]; then
    echo "❌ Failed to get public URL. Check if ngrok started correctly."
    echo "Ngrok logs:"
    cat /tmp/ngrok.log
    exit 1
fi

SSE_URL="${PUBLIC_URL}/sse"

echo "✅ Tunnel active!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📡 YOUR PUBLIC MCP URL:"
echo ""
echo "   $SSE_URL"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Share this with your friends:"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Hey! I'm sharing my secure AI agent MCP server with you."
echo ""
echo "🔗 URL: $SSE_URL"
echo ""
echo "📝 Setup Instructions:"
echo ""
echo "1. Open Terminal and run:"
echo "   claude mcp add jared-agents $SSE_URL --type sse"
echo ""
echo "2. Restart Claude Code"
echo ""
echo "3. Ask Claude Code:"
echo "   \"List available agents\""
echo "   \"Use react-expert to create a Button component\""
echo ""
echo "🤖 Available Agents:"
echo "   - react-expert: Senior React engineer"
echo "   - sql-debugger: SQL query optimizer"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✨ Tunnel will stay active until you press Ctrl+C"
echo ""
echo "🌐 Ngrok Web Interface: http://localhost:4040"
echo ""

# Save URL to file for easy access
cat > /Users/jaredboal/agent-mcp/PUBLIC_URL.txt << EOF
Public MCP Server URL
=====================

SSE URL: $SSE_URL
Dashboard: http://localhost:4040
Started: $(date)

Share with friends:
------------------
claude mcp add jared-agents $SSE_URL --type sse

EOF

echo "💾 Public URL saved to: /Users/jaredboal/agent-mcp/PUBLIC_URL.txt"
echo ""

# Wait for user to stop
echo "Press Ctrl+C to stop the tunnel..."
wait $NGROK_PID
