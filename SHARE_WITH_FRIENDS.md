# 🎉 Share Your AI Agents with Friends

## Super Easy Setup (One Time Only)

### Step 1: Get Ngrok Token (30 seconds)

A browser should have opened. If not, go to: https://dashboard.ngrok.com/signup

1. **Sign up** (free, use Google/GitHub)
2. **Copy your authtoken** from the dashboard
3. Keep it ready for next step!

### Step 2: Run the Share Script

```bash
cd /Users/jaredboal/agent-mcp
./share.sh
```

That's it! 🎉

The script will:
1. Ask for your ngrok token (paste it once)
2. Start your MCP server
3. Create a public URL
4. Give you a shareable link

## 📱 What Your Friends Get

They'll receive a message like:

```
Hey! I'm sharing my secure AI agent MCP server with you.

🔗 URL: https://abc123.ngrok.io/sse

Setup (30 seconds):
1. Run: claude mcp add jared-agents https://abc123.ngrok.io/sse --type sse
2. Restart Claude Code
3. Ask: "List available agents"

Available Agents:
- react-expert: Senior React engineer
- sql-debugger: SQL query optimizer
```

## 🔄 Every Time You Want to Share

Just run:
```bash
./share.sh
```

It will:
- ✅ Start the server
- ✅ Create public URL
- ✅ Show you what to share
- ✅ Keep running until you press Ctrl+C

## 📋 Quick Reference

**Start sharing:**
```bash
cd /Users/jaredboal/agent-mcp && ./share.sh
```

**Your public URL is saved to:**
```bash
cat /Users/jaredboal/agent-mcp/PUBLIC_URL.txt
```

**View tunnel dashboard:**
```
http://localhost:4040
```

**Stop sharing:**
```
Press Ctrl+C
```

## 🔐 Security

- ✅ System prompts stay secret on your machine
- ✅ Guardrails prevent prompt extraction
- ✅ HTTPS via ngrok
- ✅ You control when it's public (on/off)

## 🎯 What Can Your Friends Do?

Once connected, they can use your agents in Claude Code:

```
"Show me available agents"
"Use react-expert to create a TypeScript Button component"
"Use sql-debugger to optimize this query: SELECT * FROM users"
```

The agents will:
- Execute with **your** hidden system prompts
- Use **your** Claude API key
- Apply **your** guardrails
- Return filtered, secure responses

---

**That's it! You're ready to share AI superpowers with your friends!** 🚀
