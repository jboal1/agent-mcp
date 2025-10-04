#!/usr/bin/env node

/**
 * Agent MCP Command Installer
 * Automatically creates slash commands for all your agents
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

const COMMANDS_DIR = path.join(os.homedir(), '.claude', 'commands');

// Ensure commands directory exists
if (!fs.existsSync(COMMANDS_DIR)) {
  fs.mkdirSync(COMMANDS_DIR, { recursive: true });
}

// Your agents (can be fetched from API in production)
const agents = [
  {
    id: 'react-expert',
    name: 'react-expert',
    description: 'Get expert React/TypeScript advice',
    emoji: '⚛️'
  },
  {
    id: 'sql-debugger',
    name: 'sql-debug',
    description: 'Debug and optimize SQL queries',
    emoji: '🔍'
  }
];

console.log('🚀 Installing Agent MCP slash commands...\n');

// Create a command for each agent
agents.forEach(agent => {
  const commandFile = path.join(COMMANDS_DIR, `${agent.name}.js`);

  const commandScript = `---
description: ${agent.description}
argument-hint: <your question>
---

Use the mcp__agent-mcp__agent_run tool to call the ${agent.id} agent with this request:

**Agent ID:** ${agent.id}
**User Input:** $ARGUMENTS
**Temperature:** 0.2

Please display the agent's response clearly and helpfully.
`;

  fs.writeFileSync(commandFile.replace('.js', '.md'), commandScript);

  console.log(`✅ Installed: /${agent.name}`);
});

// Create an agents list command
const listCommandFile = path.join(COMMANDS_DIR, 'agents.md');
const listCommand = `---
description: List all available Agent MCP agents
---

Use the mcp__agent-mcp__agent_list tool to display all available agents in a nice table format with their descriptions and capabilities.
`;

fs.writeFileSync(listCommandFile, listCommand);

console.log(`✅ Installed: /agents\n`);

console.log('🎉 Installation complete!');
console.log('\n💡 Available commands:');
agents.forEach(agent => {
  console.log(`   /${agent.name} - ${agent.description}`);
});
console.log(`   /agents - List all available agents`);

console.log('\n📖 Usage examples:');
console.log('   /react-expert Create a TypeScript Button component');
console.log('   /sql-debug SELECT * FROM users WHERE created_at > NOW()');
console.log('   /agents');

console.log('\n⚠️  Note: Restart Claude Code for commands to take effect');
