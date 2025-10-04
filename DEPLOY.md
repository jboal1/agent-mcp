# 🚀 Deployment Guide

## Quick Start: Push to GitHub & Enable Pages

### Step 1: Create GitHub Repository

```bash
# Add all files
git add .

# Commit
git commit -m "Initial commit: Agent MCP production setup"

# Create GitHub repo (using gh CLI)
gh repo create agent-mcp --public --source=. --remote=origin --push
```

Or manually:
1. Go to https://github.com/new
2. Create repository named `agent-mcp`
3. Copy the commands GitHub shows you

### Step 2: Enable GitHub Pages

```bash
# Using gh CLI
gh repo edit --enable-pages --pages-branch main --pages-path /

# Or manually:
# 1. Go to repository Settings
# 2. Pages section
# 3. Source: Deploy from branch
# 4. Branch: main
# 5. Folder: / (root)
# 6. Save
```

Your install script will be available at:
```
https://YOUR_USERNAME.github.io/agent-mcp/install.sh
```

### Step 3: Update Install Script URL

Edit `install.sh` to point to production MCP server (not ngrok):

```bash
# Replace ngrok URL with production
MCP_SERVER_URL="${MCP_SERVER_URL:-https://your-production-url.com/sse}"
```

### Step 4: Share Your Installer

Your one-liner:
```bash
bash <(curl -fsSL https://YOUR_USERNAME.github.io/agent-mcp/install.sh)
```

---

## Production Server Options

### Option 1: Railway (Recommended for MVP)

**Pros:** Free tier, auto-deploy from GitHub, stable URLs

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Init project
railway init

# Deploy
railway up

# Get URL
railway domain
```

**Environment Variables:**
- `ANTHROPIC_API_KEY`
- `PORT=3002`
- `NODE_ENV=production`

### Option 2: Render

**Pros:** Free tier, easy setup, auto SSL

1. Go to https://render.com
2. New → Web Service
3. Connect GitHub repo
4. Build: `npm install && npm run build`
5. Start: `npm run start:mcp:sse`
6. Add environment variables

### Option 3: Fly.io

**Pros:** Global edge deployment, generous free tier

```bash
# Install flyctl
curl -L https://fly.io/install.sh | sh

# Login
fly auth login

# Launch
fly launch

# Deploy
fly deploy
```

Create `fly.toml`:
```toml
app = "agent-mcp"

[build]
  builder = "heroku/buildpacks:20"

[[services]]
  internal_port = 3002
  protocol = "tcp"

  [[services.ports]]
    port = 80
    handlers = ["http"]

  [[services.ports]]
    port = 443
    handlers = ["tls", "http"]
```

---

## Custom Domain Setup

### Option 1: GitHub Pages with Custom Domain

1. Buy domain (e.g., `agent-mcp.dev` from Cloudflare or Namecheap)
2. Add CNAME record:
   ```
   install.agent-mcp.dev → YOUR_USERNAME.github.io
   ```
3. In GitHub repo settings → Pages:
   - Custom domain: `install.agent-mcp.dev`
   - Enforce HTTPS: ✓

Your installer becomes:
```bash
bash <(curl -fsSL https://install.agent-mcp.dev/install.sh)
```

### Option 2: Cloudflare Pages (Faster)

1. Push to GitHub
2. Go to Cloudflare Pages
3. Create new project from GitHub
4. Build settings:
   - Build command: (leave empty for static)
   - Output directory: `/`
5. Custom domain: `install.agent-mcp.dev`

---

## Security Checklist

- [ ] Remove `.env` from repository
- [ ] Add `.env` to `.gitignore`
- [ ] Use environment variables in production
- [ ] Enable HTTPS for MCP server
- [ ] Add rate limiting
- [ ] Monitor API usage
- [ ] Set up error tracking (Sentry)

---

## Testing Your Deployment

```bash
# Test install script
curl -fsSL https://YOUR_URL/install.sh | head -20

# Test MCP server
curl https://YOUR_MCP_SERVER/health

# Test full installation
bash <(curl -fsSL https://YOUR_URL/install.sh)
```

---

## Rollback Plan

If something goes wrong:

```bash
# Revert to previous version
git revert HEAD
git push

# Or use specific commit
git reset --hard COMMIT_HASH
git push --force
```

GitHub Pages will auto-update in ~1 minute.

---

## Monitoring

### Usage Analytics

Track installs by adding to your server:

```typescript
app.get('/install', (req, res) => {
  // Log install
  console.log('Install:', {
    ip: req.ip,
    userAgent: req.headers['user-agent'],
    timestamp: new Date()
  });
  
  // Serve script
  res.sendFile('install.sh');
});
```

### Health Checks

```bash
# Add to crontab
*/5 * * * * curl -sf https://YOUR_MCP_SERVER/health || echo "Server down!"
```

---

**You're ready to deploy! 🎉**
