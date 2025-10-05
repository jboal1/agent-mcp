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

# Step 1.5: Configure Auto-Approval for Seamless Experience
log "Configuring auto-approval for seamless agent calls..."
SETTINGS_DIR="$HOME/.config/claude"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"
mkdir -p "$SETTINGS_DIR"

# Check if settings.json exists
if [ -f "$SETTINGS_FILE" ]; then
    # Settings file exists, merge with existing config
    if command -v jq &> /dev/null; then
        # Use jq if available for proper JSON merging
        jq '.autoApproveToolUsePatterns += ["mcp__agent-mcp__agent_run", "mcp__agent-mcp__agent_list"] | .autoApproveToolUsePatterns |= unique' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    else
        # Fallback: just append if jq not available
        warn "jq not found - appending to settings (may create duplicates)"
        # Simple merge without jq
        cat > "$SETTINGS_FILE" << 'SETTINGS_EOF'
{
  "autoApproveToolUsePatterns": [
    "mcp__agent-mcp__agent_run",
    "mcp__agent-mcp__agent_list"
  ]
}
SETTINGS_EOF
    fi
else
    # Create new settings file
    cat > "$SETTINGS_FILE" << 'SETTINGS_EOF'
{
  "autoApproveToolUsePatterns": [
    "mcp__agent-mcp__agent_run",
    "mcp__agent-mcp__agent_list"
  ]
}
SETTINGS_EOF
fi
success "✓ Auto-approval configured (agents will run instantly!)"

# Step 2: Install Slash Commands
log "Step 2/3: Installing slash commands..."
COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$COMMANDS_DIR"

# React Expert Command
cat > "$COMMANDS_DIR/react-expert.md" << 'CMDEOF'
---
description: Get expert React/TypeScript advice from the react-expert agent
argument-hint: <your question or 'examples'>
---

If the user typed "examples" or "help", show these examples instead of calling the agent:

**React Expert Examples:**

1. **Component Creation**
   `/react-expert Create a reusable Button component with TypeScript props for variant and size`

2. **Hook Usage**
   `/react-expert How do I use useCallback to optimize this component's performance?`

3. **State Management**
   `/react-expert Best practices for managing form state with React Hook Form`

4. **Testing**
   `/react-expert Write tests for a custom useAuth hook using React Testing Library`

5. **Architecture**
   `/react-expert How should I structure a large React app with feature-based folders?`

Otherwise, use the mcp__agent-mcp__agent_run tool to call the react-expert agent with this request:

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
argument-hint: <your SQL query or 'examples'>
---

If the user typed "examples" or "help", show these examples instead of calling the agent:

**SQL Debugger Examples:**

1. **Query Optimization**
   `/sql-debug SELECT * FROM users WHERE created_at > NOW() - INTERVAL 30 DAY`

2. **Index Suggestions**
   `/sql-debug SELECT u.name, COUNT(o.id) FROM users u LEFT JOIN orders o ON u.id = o.user_id GROUP BY u.id`

3. **Performance Issues**
   `/sql-debug Why is this query slow: SELECT * FROM posts WHERE title LIKE '%search%'`

4. **Join Optimization**
   `/sql-debug SELECT * FROM orders o JOIN users u ON o.user_id = u.id WHERE u.status = 'active'`

5. **Complex Queries**
   `/sql-debug Optimize this subquery: SELECT * FROM products WHERE id IN (SELECT product_id FROM sales WHERE date > '2024-01-01')`

Otherwise, use the mcp__agent-mcp__agent_run tool to call the sql-debugger agent with this query:

**Agent ID:** sql-debugger
**User Input:** $ARGUMENTS
**Temperature:** 0.2

Please analyze the query and display the agent's recommendations clearly.
CMDEOF
success "  ✓ /sql-debug"

# Git Helper Command
cat > "$COMMANDS_DIR/git-helper.md" << 'CMDEOF'
---
description: Get expert Git help with commands, workflows, and troubleshooting
argument-hint: <your git question or 'examples'>
---

If the user typed "examples" or "help", show these examples instead of calling the agent:

**Git Helper Examples:**

1. **Undo Last Commit**
   `/git-helper I committed to the wrong branch, how do I undo it?`

2. **Merge Conflicts**
   `/git-helper How do I resolve merge conflicts in package.json?`

3. **Rebase vs Merge**
   `/git-helper Should I rebase or merge my feature branch?`

4. **Recover Deleted Branch**
   `/git-helper I accidentally deleted a branch, how do I recover it?`

5. **Clean Up History**
   `/git-helper How do I squash my last 5 commits into one?`

Otherwise, use the mcp__agent-mcp__agent_run tool to call the git-helper agent with this request:

**Agent ID:** git-helper
**User Input:** $ARGUMENTS
**Temperature:** 0.2

Please display the agent's response clearly and helpfully.
CMDEOF
success "  ✓ /git-helper"

# Debug This Command
cat > "$COMMANDS_DIR/debug-this.md" << 'CMDEOF'
---
description: Analyze error messages and get debugging help
argument-hint: <paste your error message or 'examples'>
---

If the user typed "examples" or "help", show these examples instead of calling the agent:

**Debug This Examples:**

1. **Runtime Error**
   `/debug-this TypeError: Cannot read property 'map' of undefined at App.tsx:45`

2. **Import Error**
   `/debug-this Module not found: Can't resolve 'react-router-dom'`

3. **Network Error**
   `/debug-this CORS error: No 'Access-Control-Allow-Origin' header present`

4. **Database Error**
   `/debug-this PostgreSQL error: column "user_id" does not exist`

5. **Build Error**
   `/debug-this TS2345: Argument of type 'string' is not assignable to parameter of type 'number'`

Otherwise, use the mcp__agent-mcp__agent_run tool to call the debug-this agent with this request:

**Agent ID:** debug-this
**User Input:** $ARGUMENTS
**Temperature:** 0.2

Please display the agent's response clearly and helpfully.
CMDEOF
success "  ✓ /debug-this"

# Test Generator Command
cat > "$COMMANDS_DIR/test-gen.md" << 'CMDEOF'
---
description: Generate comprehensive tests for your code
argument-hint: <describe what to test or 'examples'>
---

If the user typed "examples" or "help", show these examples instead of calling the agent:

**Test Generator Examples:**

1. **Unit Test**
   `/test-gen Write Jest tests for a function that validates email addresses`

2. **Component Test**
   `/test-gen Generate React Testing Library tests for a LoginForm component`

3. **API Test**
   `/test-gen Create integration tests for a POST /users endpoint`

4. **Edge Cases**
   `/test-gen What edge cases should I test for a shopping cart calculation function?`

5. **Mock Data**
   `/test-gen Generate test fixtures for a User model with roles and permissions`

Otherwise, use the mcp__agent-mcp__agent_run tool to call the test-gen agent with this request:

**Agent ID:** test-gen
**User Input:** $ARGUMENTS
**Temperature:** 0.2

Please display the agent's response clearly and helpfully.
CMDEOF
success "  ✓ /test-gen"

# Help Command
cat > "$COMMANDS_DIR/help.md" << 'CMDEOF'
---
description: Show all available Agent MCP agents with examples
---

Use the mcp__agent-mcp__agent_list tool to get all available agents.

Then display them in a helpful format like this:

**Available AI Agents:**

For each agent, show:
- Agent name with slash command
- Description
- 2-3 example use cases
- How to use it

Make it visually appealing and easy to scan.

At the end, remind users they can also use:
- `/react-expert examples` - See React-specific examples
- `/sql-debug examples` - See SQL-specific examples
- `/git-helper examples` - See Git-specific examples
- `/debug-this examples` - See debugging examples
- `/test-gen examples` - See testing examples
- `/agents` - Quick list of all agents
CMDEOF
success "  ✓ /help"

# Agents List Command
cat > "$COMMANDS_DIR/agents.md" << 'CMDEOF'
---
description: List all available Agent MCP agents
---

Use the mcp__agent-mcp__agent_list tool to display all available agents in a nice table format with their descriptions and capabilities.
CMDEOF
success "  ✓ /agents"

# Build Feature Workflow Command
cat > "$COMMANDS_DIR/build-feature.md" << 'CMDEOF'
---
description: Build a complete feature with multiple agents (design → code → test → git)
argument-hint: <feature description>
---

You are going to orchestrate multiple AI agents to build a complete feature. Follow this workflow:

**Feature to Build:** $ARGUMENTS

## Step 1: Design the Architecture
Use the mcp__agent-mcp__agent_run tool to call the react-expert agent:
- **Agent ID:** react-expert
- **User Input:** "Design the architecture and component structure for: $ARGUMENTS. What components do we need? How should state flow? What's the folder structure?"
- **Temperature:** 0.3

Wait for the response, then proceed to Step 2.

## Step 2: Generate the Implementation
Use the mcp__agent-mcp__agent_run tool to call the react-expert agent again:
- **Agent ID:** react-expert
- **User Input:** "Based on the architecture we just discussed, implement the main components for: $ARGUMENTS. Include TypeScript types and proper error handling."
- **Temperature:** 0.2

Wait for the response, then proceed to Step 3.

## Step 3: Generate Tests
Use the mcp__agent-mcp__agent_run tool to call the test-gen agent:
- **Agent ID:** test-gen
- **User Input:** "Generate comprehensive tests for the feature we just built: $ARGUMENTS. Include unit tests and integration tests."
- **Temperature:** 0.2

Wait for the response, then proceed to Step 4.

## Step 4: Git Workflow
Use the mcp__agent-mcp__agent_run tool to call the git-helper agent:
- **Agent ID:** git-helper
- **User Input:** "What's the best Git workflow for committing this feature: $ARGUMENTS? Suggest branch name, commit structure, and PR description."
- **Temperature:** 0.2

## Final Summary
After all agents complete, provide:
1. Summary of what was built
2. Files that should be created
3. Commands to run
4. Next steps

Present everything in a clean, actionable format.
CMDEOF
success "  ✓ /build-feature"

# Debug Flow Workflow Command
cat > "$COMMANDS_DIR/debug-flow.md" << 'CMDEOF'
---
description: Debug an issue with multiple agents (analyze → fix → test → verify)
argument-hint: <error or issue description>
---

You are going to orchestrate multiple AI agents to debug and fix an issue. Follow this workflow:

**Issue to Debug:** $ARGUMENTS

## Step 1: Analyze the Error
Use the mcp__agent-mcp__agent_run tool to call the debug-this agent:
- **Agent ID:** debug-this
- **User Input:** "Analyze this error and identify the root cause: $ARGUMENTS. What's causing this and what are the likely fixes?"
- **Temperature:** 0.2

Wait for the response, then proceed to Step 2.

## Step 2: Implement the Fix
Use the mcp__agent-mcp__agent_run tool to call the react-expert agent:
- **Agent ID:** react-expert
- **User Input:** "Based on the error analysis, implement a fix for: $ARGUMENTS. Show the corrected code with explanations."
- **Temperature:** 0.2

Wait for the response, then proceed to Step 3.

## Step 3: Add Tests to Prevent Regression
Use the mcp__agent-mcp__agent_run tool to call the test-gen agent:
- **Agent ID:** test-gen
- **User Input:** "Generate tests to catch this bug and prevent regression: $ARGUMENTS"
- **Temperature:** 0.2

Wait for the response, then proceed to Step 4.

## Step 4: Git Commit Strategy
Use the mcp__agent-mcp__agent_run tool to call the git-helper agent:
- **Agent ID:** git-helper
- **User Input:** "How should I commit this bug fix: $ARGUMENTS? Suggest commit message and any git best practices."
- **Temperature:** 0.2

## Final Summary
After all agents complete, provide:
1. Root cause of the issue
2. The fix implemented
3. Tests added
4. Git workflow
5. How to verify the fix

Present everything in a clean, actionable format.
CMDEOF
success "  ✓ /debug-flow"

# Code Review Workflow Command
cat > "$COMMANDS_DIR/code-review.md" << 'CMDEOF'
---
description: Comprehensive code review with multiple specialized agents
argument-hint: <code or file to review>
---

You are going to orchestrate multiple AI agents to perform a thorough code review. Follow this workflow:

**Code to Review:** $ARGUMENTS

## Step 1: React/Architecture Review
Use the mcp__agent-mcp__agent_run tool to call the react-expert agent:
- **Agent ID:** react-expert
- **User Input:** "Review this code for React best practices, performance, and architecture: $ARGUMENTS. Point out issues and suggest improvements."
- **Temperature:** 0.3

Wait for the response, then proceed to Step 2.

## Step 2: Test Coverage Analysis
Use the mcp__agent-mcp__agent_run tool to call the test-gen agent:
- **Agent ID:** test-gen
- **User Input:** "Analyze test coverage for this code: $ARGUMENTS. What tests are missing? What edge cases aren't covered?"
- **Temperature:** 0.3

Wait for the response, then proceed to Step 3.

## Step 3: Potential Bugs & Issues
Use the mcp__agent-mcp__agent_run tool to call the debug-this agent:
- **Agent ID:** debug-this
- **User Input:** "Identify potential bugs, errors, or issues in this code: $ARGUMENTS. What could go wrong?"
- **Temperature:** 0.3

## Final Code Review Summary
After all agents complete, provide:

### 🎯 Overall Assessment
- Code quality score (1-10)
- Main strengths
- Critical issues to fix

### 🔧 Action Items (Prioritized)
1. **Critical** - Must fix before merge
2. **Important** - Should fix soon
3. **Nice to have** - Optional improvements

### ✅ What's Good
- Highlight positive aspects
- Good patterns to keep

### 📝 Specific Recommendations
- File by file improvements
- Line-specific suggestions

Present everything in a clean, structured format ready for a PR comment.
CMDEOF
success "  ✓ /code-review"

# Quick Review Command
cat > "$COMMANDS_DIR/review.md" << 'CMDEOF'
---
description: Quick code review of current file or selection
---

## Instructions

Review the code the user is currently working on:

1. **Identify what to review:**
   - If the user has text selected in the editor, review that
   - If they mention a file path, read that file
   - Otherwise, ask which file or code to review

2. **Use the react-expert agent:**
   Use the mcp__agent-mcp__agent_run tool:
   - **Agent ID:** react-expert
   - **User Input:** "Quick code review: analyze this code for issues, improvements, and best practices.\n\n[Code here with file path]"
   - **Temperature:** 0.3

3. **Provide concise output:**
   - ✅ What's good
   - ⚠️ Issues found (with line numbers)
   - 💡 Quick wins (easy improvements)
   - 🎯 Suggestions (bigger improvements)

Keep it brief and actionable. Focus on the most important issues.
CMDEOF
success "  ✓ /review"

# Fix Command
cat > "$COMMANDS_DIR/fix.md" << 'CMDEOF'
---
description: Analyze and fix the current error or issue
argument-hint: <error message or description>
---

## Instructions

Help the user debug and fix an issue:

1. **Understand the problem:**
   - If $ARGUMENTS contains an error message, analyze it
   - If it's vague, ask for the full error or stack trace
   - Check if user has relevant files open (offer to read them)

2. **Analyze with debug-this agent:**
   Use the mcp__agent-mcp__agent_run tool:
   - **Agent ID:** debug-this
   - **User Input:** "Analyze and fix this issue: $ARGUMENTS\n\n[Include relevant code if available]"
   - **Temperature:** 0.2

3. **Provide the fix:**
   - 🔍 Root cause (1-2 sentences)
   - ✅ The fix (show exact code changes)
   - 📝 Why it works (brief explanation)
   - 🚀 How to prevent it (optional best practice)

Be direct and actionable. Show them exactly what to change.
CMDEOF
success "  ✓ /fix"

# Optimize Command
cat > "$COMMANDS_DIR/optimize.md" << 'CMDEOF'
---
description: Optimize code for performance and best practices
argument-hint: <file path or description>
---

## Instructions

Help optimize the user's code:

1. **Get the code:**
   - If $ARGUMENTS is a file path, use Read tool to get it
   - If user mentions specific code, get that context
   - Otherwise ask what they want to optimize

2. **Analyze with react-expert:**
   Use the mcp__agent-mcp__agent_run tool:
   - **Agent ID:** react-expert
   - **User Input:** "Optimize this code for performance and best practices: $ARGUMENTS\n\n[Code with file path]"
   - **Temperature:** 0.2

3. **Provide optimizations:**
   - 🎯 Performance issues found
   - ⚡️ Optimized code (show the changes)
   - 📊 Expected improvement
   - 💡 Additional optimizations (optional)

Focus on practical, measurable improvements.
CMDEOF
success "  ✓ /optimize"

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
echo "2. Quick Commands (Most Common):"
echo -e "   ${BLUE}/review${NC}                  - Quick code review of current file"
echo -e "   ${BLUE}/fix${NC} <error>             - Analyze and fix an error"
echo -e "   ${BLUE}/optimize${NC} <file>         - Optimize code performance"
echo ""
echo "3. Multi-Agent Workflows:"
echo -e "   ${BLUE}/build-feature${NC} <desc>   - Design → Code → Test → Git"
echo -e "   ${BLUE}/debug-flow${NC} <issue>     - Analyze → Fix → Test → Commit"
echo -e "   ${BLUE}/code-review${NC} <file>     - Comprehensive 3-agent review"
echo ""
echo "4. Individual Agents:"
echo -e "   ${BLUE}/react-expert${NC} <question> - React/TypeScript expert"
echo -e "   ${BLUE}/sql-debug${NC} <query>      - SQL query optimizer"
echo -e "   ${BLUE}/git-helper${NC} <question>  - Git commands & workflows"
echo -e "   ${BLUE}/debug-this${NC} <error>     - Error message analyzer"
echo -e "   ${BLUE}/test-gen${NC} <description> - Test generator"
echo ""
echo "5. Help:"
echo -e "   ${BLUE}/help${NC}                    - Show all agents with examples"
echo -e "   ${BLUE}/agents${NC}                  - Quick list"
echo ""
echo "6. Try it:"
echo -e "   ${BLUE}/review${NC}                                 - Review current file"
echo -e "   ${BLUE}/fix${NC} TypeError: Cannot read property 'map'"
echo -e "   ${BLUE}/build-feature${NC} User login with OAuth"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}⚠️  IMPORTANT: RESTART CLAUDE CODE NOW!${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}Auto-approval has been configured, but Claude Code${NC}"
echo -e "${YELLOW}must be restarted to enable instant agent responses.${NC}"
echo ""
echo -e "${GREEN}After restart:${NC}"
echo -e "  • Agents run ${GREEN}instantly${NC} with no approval prompts"
echo -e "  • Workflows execute ${GREEN}automatically${NC}"
echo -e "  • Completely ${GREEN}seamless${NC} experience"
echo ""
echo -e "${BLUE}To activate seamless mode:${NC}"
echo -e "  ${BLUE}1.${NC} Close Claude Code completely (Cmd+Q or Ctrl+Q)"
echo -e "  ${BLUE}2.${NC} Reopen Claude Code"
echo -e "  ${BLUE}3.${NC} Try: ${GREEN}/review${NC} or ${GREEN}/fix <error>${NC}"
echo ""

# Check if Claude Code is running and offer to restart
if pgrep -x "Claude" > /dev/null 2>&1; then
    echo -e "${YELLOW}📍 Claude Code is currently running${NC}"
    echo ""
    read -p "$(echo -e ${GREEN}Would you like to restart it now? [y/N]:${NC} )" -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "Restarting Claude Code..."
        killall "Claude" 2>/dev/null || true
        sleep 2
        open -a "Claude" 2>/dev/null || {
            warn "Could not auto-restart. Please restart manually."
        }
        success "✨ Claude Code restarted! Seamless mode activated."
    else
        warn "Remember to restart Claude Code manually for seamless mode!"
    fi
else
    success "✨ Setup complete! Launch Claude Code to use your agents."
fi
