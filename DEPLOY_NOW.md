# 🚀 Deploy to Production RIGHT NOW

## Steps (15 minutes total)

### PART 1: Deploy to Railway (5 min)

**Step 1:** Open a NEW terminal and run:
```bash
cd /Users/jaredboal/agent-mcp
railway login
```
→ Browser opens, login with GitHub (free)

**Step 2:** Initialize Railway project:
```bash
railway init
```
- Type: `agent-mcp`
- Press Enter

**Step 3:** Set environment variable (paste your actual key):
```bash
railway variables set ANTHROPIC_API_KEY=YOUR_ANTHROPIC_API_KEY
```

**Step 4:** Deploy!
```bash
railway up
```
→ Wait 2-3 minutes...

**Step 5:** Get your Railway URL:
```bash
railway domain
```

Copy the URL (looks like: `agent-mcp-production.up.railway.app`)

---

### PART 2: Update Install Script (2 min)

**Step 6:** Edit install.sh with your Railway URL:
```bash
# Open install.sh and change line 8:
# FROM: MCP_SERVER_URL="${MCP_SERVER_URL:-https://julien-semimanneristic-eugene.ngrok-free.dev/sse}"
# TO:   MCP_SERVER_URL="${MCP_SERVER_URL:-https://YOUR-RAILWAY-URL.up.railway.app/sse}"
```

---

### PART 3: Push to GitHub (5 min)

**Step 7:** Create GitHub repo:
```bash
gh repo create agent-mcp --public --source=. --remote=origin
```
→ Creates repo and sets remote

**Step 8:** Commit and push:
```bash
git add .
git commit -m "🚀 Production deployment ready"
git push -u origin main
```

**Step 9:** Enable GitHub Pages:
```bash
gh repo edit --enable-pages --pages-branch main --pages-path /
```
→ Wait 2 minutes for Pages to deploy

---

### PART 4: Test & Share! (3 min)

**Step 10:** Get your GitHub Pages URL:
```
https://YOUR_GITHUB_USERNAME.github.io/agent-mcp/install.sh
```

**Step 11:** Test it:
```bash
bash <(curl -fsSL https://YOUR_GITHUB_USERNAME.github.io/agent-mcp/install.sh)
```

**Step 12:** Share this with the world:
```bash
bash <(curl -fsSL https://YOUR_GITHUB_USERNAME.github.io/agent-mcp/install.sh)
```

---

## Troubleshooting

**Issue:** Railway login doesn't work
```bash
# Try:
railway login --browserless
# Copy the URL it gives you and open in browser
```

**Issue:** Build fails on Railway
```bash
# Check logs:
railway logs --build

# Common fix: Ensure .env is in .gitignore (it is)
```

**Issue:** GitHub Pages not loading
```bash
# Wait 2-3 minutes after enabling
# Check status:
gh repo view --web
# Go to Settings → Pages
```

---

## What You'll Have After This:

✅ **Railway MCP Server:** `https://YOUR-APP.up.railway.app`
✅ **GitHub Pages Install:** `https://YOUR_USERNAME.github.io/agent-mcp/install.sh`
✅ **One-Line Installer:** Working for everyone!

---

## Next Steps (Optional - Later):

1. **Buy Domain** ($12/year)
   - agent-mcp.dev
   - Point to GitHub Pages
   - Get: `https://agent-mcp.dev/install.sh`

2. **Add Analytics**
   - Track installs
   - See usage stats

3. **Add More Agents**
   - Create new .yaml files
   - Auto-available!

---

## Quick Reference Commands

```bash
# Railway
railway logs                    # View logs
railway open                    # Open dashboard
railway status                  # Check status
railway variables               # See env vars

# GitHub
gh repo view --web             # Open repo
gh repo edit --enable-pages    # Enable Pages
```

---

**🎯 You're ready! Just follow the steps above in order.**

**Start with:** `railway login` in a new terminal!
