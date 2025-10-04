import 'dotenv/config';
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import fs from 'fs';
import path from 'path';
import { Anthropic } from '@anthropic-ai/sdk';
import { preFilter, postFilter } from '../guardrails/index.js';
import {
  ListToolsRequestSchema,
  CallToolRequestSchema,
  Tool
} from "@modelcontextprotocol/sdk/types.js";

const ANTHROPIC_API_KEY = process.env.ANTHROPIC_API_KEY!;
const yaml = require('js-yaml');

interface Agent {
  id: string;
  version: string;
  title: string;
  desc: string;
  price: number;
  tags: string[];
  system: string;
  eval_summary?: {
    latency_ms_p50?: number;
    notes?: string;
  };
}

// Load agents from YAML files
const agentsDir = path.join(__dirname, '../agents');
function loadAgents(): Agent[] {
  return fs.readdirSync(agentsDir)
    .filter(f => f.endsWith('.yaml'))
    .map((f) => yaml.load(fs.readFileSync(path.join(agentsDir, f), 'utf8')) as Agent);
}

const AGENTS = loadAgents();

// Create MCP server
const server = new Server({
  name: "agent-mcp",
  version: "1.0.0"
}, {
  capabilities: {
    tools: {}
  }
});

// Register ListTools handler
server.setRequestHandler(ListToolsRequestSchema, async () => {
  const tools: Tool[] = [
    {
      name: "agent_list",
      description: "List all available AI agents with their metadata (excluding system prompts)",
      inputSchema: {
        type: "object",
        properties: {}
      }
    },
    {
      name: "agent_run",
      description: "Execute a specific AI agent with user input. The agent's system prompt remains hidden and secure.",
      inputSchema: {
        type: "object",
        properties: {
          agent_id: {
            type: "string",
            description: "The ID of the agent to run (e.g., 'react-expert', 'sql-debugger')"
          },
          user_input: {
            type: "string",
            description: "The user's input/question for the agent"
          },
          temperature: {
            type: "number",
            description: "Optional temperature for response randomness (0.0-1.0, default: 0.2)",
            minimum: 0,
            maximum: 1
          }
        },
        required: ["agent_id", "user_input"]
      }
    }
  ];

  return { tools };
});

// Register CallTool handler
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    if (name === "agent_list") {
      // Return metadata only (no system prompts)
      const publicAgents = AGENTS.map(({ system, ...rest }) => rest);

      return {
        content: [{
          type: "text",
          text: JSON.stringify({ agents: publicAgents }, null, 2)
        }]
      };
    }

    if (name === "agent_run") {
      const { agent_id, user_input, temperature = 0.2 } = args as {
        agent_id: string;
        user_input: string;
        temperature?: number;
      };

      // Find the agent
      const agent = AGENTS.find((a) => a.id === agent_id);
      if (!agent) {
        return {
          isError: true,
          content: [{
            type: "text",
            text: `Agent not found: ${agent_id}. Available agents: ${AGENTS.map(a => a.id).join(', ')}`
          }]
        };
      }

      // Apply guardrails
      const cleanInput = preFilter(user_input);

      // Call Claude with the agent's system prompt
      const anthropic = new Anthropic({ apiKey: ANTHROPIC_API_KEY });
      const resp = await anthropic.messages.create({
        model: process.env.CLAUDE_MODEL || 'claude-3-5-sonnet-20241022',
        max_tokens: 1200,
        temperature,
        messages: [{ role: 'user', content: cleanInput }],
        system: agent.system,
      });

      const text = (resp.content?.[0] as any)?.text ?? '';
      const filteredOutput = postFilter(text);

      return {
        content: [{
          type: "text",
          text: JSON.stringify({
            output: filteredOutput,
            usage: resp.usage,
            agent: {
              id: agent.id,
              version: agent.version,
              title: agent.title
            }
          }, null, 2)
        }]
      };
    }

    return {
      isError: true,
      content: [{
        type: "text",
        text: `Unknown tool: ${name}`
      }]
    };
  } catch (error: any) {
    return {
      isError: true,
      content: [{
        type: "text",
        text: `Error: ${error.message}`
      }]
    };
  }
});

// Start the server
async function main() {
  try {
    const transport = new StdioServerTransport();
    await server.connect(transport);

    // Log to stderr since stdout is used for MCP protocol
    console.error(`🚀 Agent MCP Server started`);
    console.error(`📦 Loaded ${AGENTS.length} agents: ${AGENTS.map(a => a.id).join(', ')}`);
  } catch (error) {
    console.error("Failed to start MCP server:", error);
    process.exit(1);
  }
}

main();
