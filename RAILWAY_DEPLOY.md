# 🚂 Railway Deployment Guide

## Step-by-Step Deployment

### 1. Login to Railway

```bash
railway login
```

This will open your browser. Sign up or login with GitHub (free).

### 2. Initialize Railway Project

```bash
railway init
```

- Project name: `agent-mcp`
- Press Enter to create

### 3. Set Environment Variables

```bash
# Add your Anthropic API key
railway variables set ANTHROPIC_API_KEY=YOUR_KEY_HERE

# Set other variables
railway variables set CLAUDE_MODEL=claude-sonnet-4-20250514
railway variables set NODE_ENV=production
```

Or set them in the Railway dashboard:
1. Go to https://railway.app
2. Select your project
3. Click "Variables"
4. Add:
   - `ANTHROPIC_API_KEY`: your_key
   - `CLAUDE_MODEL`: claude-sonnet-4-20250514
   - `NODE_ENV`: production

### 4. Deploy!

```bash
railway up
```

Wait 2-3 minutes for deployment...

### 5. Get Your Production URL

```bash
railway domain
```

This will generate a Railway domain like:
`agent-mcp-production.up.railway.app`

Or set a custom domain:
```bash
railway domain add your-domain.com
```

### 6. Test Deployment

```bash
# Get your URL
RAILWAY_URL=$(railway domain | head -1)

# Test health endpoint
curl https://$RAILWAY_URL/health

# Test SSE endpoint  
curl https://$RAILWAY_URL/
```

### 7. Update Install Script

Edit `install.sh` and replace the MCP_SERVER_URL:

```bash
# Change from:
MCP_SERVER_URL="${MCP_SERVER_URL:-https://julien-semimanneristic-eugene.ngrok-free.dev/sse}"

# To:
MCP_SERVER_URL="${MCP_SERVER_URL:-https://YOUR-APP.up.railway.app/sse}"
```

### 8. Deploy GitHub Pages for Install Script

```bash
# Create GitHub repo
gh repo create agent-mcp --public --source=. --remote=origin

# Add all files
git add .
git commit -m "Production deployment ready"
git push -u origin main

# Enable GitHub Pages
gh repo edit --enable-pages --pages-branch main --pages-path /
```

Your install script will be at:
```
https://YOUR_USERNAME.github.io/agent-mcp/install.sh
```

### 9. Share Your Production Installer!

```bash
bash <(curl -fsSL https://YOUR_USERNAME.github.io/agent-mcp/install.sh)
```

---

## Railway Commands Reference

```bash
# View logs
railway logs

# Open in browser
railway open

# Check status
railway status

# Re-deploy
railway up

# SSH into container (for debugging)
railway shell

# Delete project
railway delete
```

---

## Troubleshooting

### Issue: Build fails
```bash
# Check logs
railway logs --build

# Common fix: Ensure package.json has correct build script
"build": "tsc && mkdir -p dist/agents && cp src/agents/*.yaml dist/agents/"
```

### Issue: App crashes on start
```bash
# Check runtime logs
railway logs

# Ensure PORT env var is used
const PORT = process.env.PORT || 3002;
```

### Issue: Can't access MCP server
```bash
# Check if service is running
railway status

# Verify health endpoint
curl https://YOUR-APP.up.railway.app/health
```

---

## Cost Estimates

Railway Free Tier:
- $5 free credits/month
- Enough for ~500 hours runtime
- Perfect for MVP testing

Railway Pro (when you grow):
- $20/month minimum
- Pay for what you use
- Scales automatically

---

## Next Steps

1. ✅ Deploy to Railway
2. ✅ Get production URL
3. ✅ Push to GitHub
4. ✅ Enable GitHub Pages
5. ✅ Update install.sh with production URL
6. ✅ Test end-to-end
7. 🚀 Share with the world!

---

## Alternative: Custom Domain

Buy a domain ($12/year) and add to Railway:

1. Buy domain from Namecheap/Cloudflare
2. In Railway dashboard:
   - Settings → Domains
   - Add custom domain: `api.agent-mcp.dev`
3. Update DNS (CNAME):
   ```
   api.agent-mcp.dev → YOUR-APP.up.railway.app
   ```
4. Wait for SSL (automatic, ~5 min)
5. Update install.sh:
   ```
   MCP_SERVER_URL="https://api.agent-mcp.dev/sse"
   ```

Your professional one-liner:
```bash
bash <(curl -fsSL https://install.agent-mcp.dev/install.sh)
```

🎉 **You're now production-ready!**
