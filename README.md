# 🤖 Agent MCP

**Secure AI Agent MCP Server** - Share AI agents with protected prompts via the Model Context Protocol.

## 🚀 One-Line Install

```bash
bash <(curl -fsSL https://julien-semimanneristic-eugene.ngrok-free.dev/install)
```

Or use your own domain:
```bash
bash <(curl -fsSL https://agent-mcp.dev/install.sh)
```

## ✨ What You Get

After installation, you'll have instant access to these slash commands in Claude Code:

- `/react-expert <question>` - Get expert React/TypeScript advice
- `/sql-debug <query>` - Debug and optimize SQL queries  
- `/agents` - List all available agents

## 🔐 How It Works

1. **Secure Prompts**: Agent prompts stay hidden on the server
2. **MCP Protocol**: Uses Claude's Model Context Protocol for integration
3. **Slash Commands**: Simple, intuitive interface in Claude Code
4. **Protected Output**: Guardrails prevent prompt extraction

## 📦 Available Agents

| Agent | Description | Use Cases |
|-------|-------------|-----------|
| `react-expert` | Senior React/TypeScript engineer | Components, hooks, architecture, testing |
| `sql-debugger` | SQL query optimizer | Query optimization, index suggestions, debugging |

## 🛠️ For Developers

### Local Development

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/agent-mcp.git
cd agent-mcp

# Install dependencies
npm install

# Set up environment
cp .env.example .env
# Edit .env with your API keys

# Run development server
npm run dev

# Run MCP SSE server
npm run mcp:sse
```

### Add Your Own Agents

1. Create a YAML file in `src/agents/`:

```yaml
id: my-agent
version: v1
title: My Custom Agent
desc: Description of what your agent does
price: 10
tags: [custom, example]
system: |
  You are an expert in...
  [Your secret system prompt here]
```

2. Restart the server - your agent is now available!

## 📡 Architecture

```
┌─────────────────────────────────┐
│   One-Line Installer            │
│   (GitHub Pages / CDN)          │
└─────────────────────────────────┘
            ↓
┌─────────────────────────────────┐
│   MCP Server (SSE)              │
│   - Agents runtime              │
│   - Guardrails                  │  
│   - Slash commands              │
└─────────────────────────────────┘
            ↓
┌─────────────────────────────────┐
│   Claude Code / Desktop         │
│   - /react-expert               │
│   - /sql-debug                  │
│   - /agents                     │
└─────────────────────────────────┘
```

## 🌐 Deployment

### Option 1: ngrok (Quick & Easy)
```bash
ngrok http 3002
```

### Option 2: Railway/Render (Production)
1. Deploy to Railway or Render
2. Set environment variables
3. Get stable URL
4. Update install script

### Option 3: Self-Hosted
1. Set up server with Node.js
2. Configure reverse proxy (nginx)
3. Add SSL certificate
4. Run with PM2 or systemd

## 📄 License

MIT

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

---

**Built with ❤️ using the Model Context Protocol**
