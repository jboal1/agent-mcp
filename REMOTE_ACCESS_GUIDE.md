# Remote Access Guide - Agent MCP

## Overview

Your Agent MCP server has **two modes**:
1. **Local MCP (stdio)** - For your Claude Code only
2. **REST API** - For remote computers and services

## Option 1: REST API (Easiest) ✅

You already have a REST API server! Other computers can access it via HTTP.

### Step 1: Start the REST API Server

```bash
cd /Users/jaredboal/agent-mcp
npm run dev
```

Server runs on `http://localhost:3000`

### Step 2: Expose to Network

**For Local Network (Same WiFi):**
```bash
# Find your local IP
ifconfig | grep "inet " | grep -v 127.0.0.1

# Update .env to listen on all interfaces
# Change PORT=3000 to:
HOST=0.0.0.0
PORT=3000
```

Update `src/server.ts`:
```typescript
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on http://0.0.0.0:${PORT}`);
});
```

Now accessible at: `http://YOUR_LOCAL_IP:3000`

**For Internet Access:**

Use a service like:
- **ngrok** (easiest for testing)
- **Cloudflare Tunnel** (free, secure)
- **Deploy to cloud** (Railway, Render, Fly.io)

### Step 3: Remote Usage

Other computers can now call:

```bash
# List agents
curl -H "x-api-key: change-me" http://YOUR_IP:3000/agent.list

# Run agent
curl -X POST http://YOUR_IP:3000/agent.run \
  -H "x-api-key: change-me" \
  -H "content-type: application/json" \
  -d '{
    "agent_id": "react-expert",
    "user_input": "Create a Button component"
  }'
```

---

## Option 2: MCP over SSE (Server-Sent Events)

MCP supports HTTP/SSE transport for remote connections.

### Create SSE MCP Server

Create `src/mcp/sse-server.ts`:

```typescript
import 'dotenv/config';
import express from 'express';
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { SSEServerTransport } from "@modelcontextprotocol/sdk/server/sse.js";
// ... (import your existing MCP handlers)

const app = express();
const PORT = process.env.MCP_PORT || 3001;

app.get('/sse', async (req, res) => {
  const transport = new SSEServerTransport('/messages', res);
  await server.connect(transport);
});

app.post('/messages', async (req, res) => {
  // Handle MCP messages
});

app.listen(PORT, () => {
  console.log(`MCP SSE server on http://localhost:${PORT}/sse`);
});
```

### Remote Claude Code Configuration

On another computer's `.mcp.json`:

```json
{
  "mcpServers": {
    "remote-agent-mcp": {
      "type": "sse",
      "url": "http://YOUR_IP:3001/sse"
    }
  }
}
```

---

## Option 3: Ngrok Tunnel (Quickest for Testing)

### Install ngrok
```bash
brew install ngrok
# or download from ngrok.com
```

### Start Your Server
```bash
npm run dev
```

### Create Tunnel
```bash
ngrok http 3000
```

You'll get a URL like: `https://abc123.ngrok.io`

### Share with Others
```bash
# They can now access:
curl -H "x-api-key: change-me" https://abc123.ngrok.io/agent.list
```

---

## Option 4: Cloud Deployment

### Deploy to Railway.app (Free Tier)

1. **Install Railway CLI:**
   ```bash
   npm i -g @railway/cli
   ```

2. **Login & Deploy:**
   ```bash
   railway login
   railway init
   railway up
   ```

3. **Set Environment Variables:**
   ```bash
   railway variables set ANTHROPIC_API_KEY=your_key
   railway variables set API_KEY=your_secret_key
   ```

4. **Get Public URL:**
   Railway automatically provides a public URL

### Deploy to Render.com

1. Push code to GitHub
2. Connect Render to your repo
3. Set environment variables
4. Deploy

---

## Security Considerations ⚠️

### For Production Remote Access:

1. **Strong API Keys:**
   ```bash
   # Generate secure key
   openssl rand -base64 32
   ```

2. **HTTPS Only:**
   - Use Cloudflare Tunnel
   - Or deploy to cloud with SSL

3. **Rate Limiting:**
   Add to `src/server.ts`:
   ```typescript
   import rateLimit from 'express-rate-limit';

   const limiter = rateLimit({
     windowMs: 15 * 60 * 1000, // 15 minutes
     max: 100 // limit each IP to 100 requests per windowMs
   });

   app.use(limiter);
   ```

4. **IP Whitelist:**
   ```typescript
   const allowedIPs = ['1.2.3.4', '5.6.7.8'];

   app.use((req, res, next) => {
     if (!allowedIPs.includes(req.ip)) {
       return res.status(403).json({ error: 'Forbidden' });
     }
     next();
   });
   ```

5. **Request Logging:**
   Already have Morgan, but add persistent logs:
   ```typescript
   import winston from 'winston';
   // Log all API requests
   ```

---

## Network Topology

### Local Network (Same WiFi)
```
Computer A (Your Mac)          Computer B (Friend's laptop)
┌─────────────────┐           ┌─────────────────┐
│ Agent MCP       │           │ curl / HTTP     │
│ :3000           │◄──────────│ client          │
└─────────────────┘           └─────────────────┘
   192.168.1.100                 192.168.1.101
```

### Internet Access via Ngrok
```
Computer A                    Internet                Computer B
┌─────────────┐              ┌────────┐             ┌──────────┐
│ Agent MCP   │◄─────────────│ ngrok  │◄────────────│  Client  │
│ localhost   │              │ tunnel │             │          │
│ :3000       │              └────────┘             └──────────┘
└─────────────┘         https://abc.ngrok.io
```

### Cloud Deployment
```
Your Computer              Cloud (Railway/Render)        Other Computers
┌─────────────┐           ┌──────────────────┐         ┌──────────┐
│ Deploy Code │──push────►│ Agent MCP Server │◄────────│  Clients │
└─────────────┘           │ https://...      │         └──────────┘
                          └──────────────────┘
```

---

## Quick Start: Ngrok (Recommended for Testing)

1. **Start your server:**
   ```bash
   cd /Users/jaredboal/agent-mcp
   npm run dev
   ```

2. **In another terminal, start ngrok:**
   ```bash
   ngrok http 3000
   ```

3. **Share the ngrok URL** (e.g., `https://abc123.ngrok.io`)

4. **Others can access:**
   ```bash
   curl -H "x-api-key: change-me" https://abc123.ngrok.io/agent.list
   ```

---

## Client Libraries

### JavaScript/TypeScript Client

```typescript
// client.ts
const API_URL = 'https://your-server.com';
const API_KEY = 'your-api-key';

async function listAgents() {
  const res = await fetch(`${API_URL}/agent.list`, {
    headers: { 'x-api-key': API_KEY }
  });
  return res.json();
}

async function runAgent(agentId: string, input: string) {
  const res = await fetch(`${API_URL}/agent.run`, {
    method: 'POST',
    headers: {
      'x-api-key': API_KEY,
      'content-type': 'application/json'
    },
    body: JSON.stringify({
      agent_id: agentId,
      user_input: input
    })
  });
  return res.json();
}
```

### Python Client

```python
import requests

API_URL = 'https://your-server.com'
API_KEY = 'your-api-key'

def list_agents():
    response = requests.get(
        f'{API_URL}/agent.list',
        headers={'x-api-key': API_KEY}
    )
    return response.json()

def run_agent(agent_id: str, user_input: str):
    response = requests.post(
        f'{API_URL}/agent.run',
        headers={'x-api-key': API_KEY},
        json={
            'agent_id': agent_id,
            'user_input': user_input
        }
    )
    return response.json()
```

---

## Recommended Setup for Different Use Cases

### Personal/Testing
- **Ngrok** - Quick, easy, temporary URL

### Team/Organization
- **Cloudflare Tunnel** - Free, secure, persistent
- **Tailscale** - Private network between devices

### Production/Public
- **Cloud deployment** (Railway, Render, Fly.io)
- Add authentication (JWT tokens)
- Rate limiting
- Monitoring/logging

---

## Next Steps

1. **Choose deployment method** based on your needs
2. **Strengthen security** (strong API keys, HTTPS, rate limiting)
3. **Add usage tracking** (log requests, track costs)
4. **Build client SDKs** for easy integration
5. **Add billing/metering** for marketplace

Your secure agent execution layer is ready to scale! 🚀
