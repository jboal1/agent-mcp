import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { SSEServerTransport } from "@modelcontextprotocol/sdk/server/sse.js";
import fs from 'fs';
import path from 'path';
import { Anthropic } from '@anthropic-ai/sdk';
import { preFilter, postFilter } from '../guardrails';
import {
  ListToolsRequestSchema,
  CallToolRequestSchema,
  Tool
} from "@modelcontextprotocol/sdk/types.js";

const PORT = process.env.PORT || process.env.MCP_SSE_PORT || 3002;
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

// Create MCP server instance
const mcpServer = new Server({
  name: "agent-mcp-remote",
  version: "1.0.0"
}, {
  capabilities: {
    tools: {}
  }
});

// Register ListTools handler
mcpServer.setRequestHandler(ListToolsRequestSchema, async () => {
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
mcpServer.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    if (name === "agent_list") {
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

      const cleanInput = preFilter(user_input);
      const anthropic = new Anthropic({ apiKey: ANTHROPIC_API_KEY });
      const resp = await anthropic.messages.create({
        model: process.env.CLAUDE_MODEL || 'claude-sonnet-4-20250514',
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

// Create Express app for HTTP/SSE transport
const app = express();

// Enable CORS for remote access
app.use(cors({
  origin: '*', // Allow all origins (restrict this in production!)
  credentials: true
}));

app.use(express.json());

// Store active transports by session ID
const transports: Record<string, SSEServerTransport> = {};

// SSE endpoint for establishing the stream
app.get('/sse', async (req, res) => {
  console.error('Received GET request to /sse (establishing SSE stream)');

  try {
    // Create a new SSE transport for the client
    // The endpoint for POST messages is '/message'
    const transport = new SSEServerTransport('/message', res);

    // Store the transport by its session ID
    const sessionId = transport.sessionId;
    transports[sessionId] = transport;

    // Set up onclose handler to clean up transport when closed
    transport.onclose = () => {
      console.error(`SSE transport closed for session ${sessionId}`);
      delete transports[sessionId];
    };

    // Connect the transport to the MCP server
    await mcpServer.connect(transport);

    console.error(`Established SSE stream with session ID: ${sessionId}`);
  } catch (error) {
    console.error('Error establishing SSE stream:', error);
    if (!res.headersSent) {
      res.status(500).send('Error establishing SSE stream');
    }
  }
});

// Messages endpoint for receiving client JSON-RPC requests
app.post('/message', async (req, res) => {
  console.error('Received POST request to /message');

  // Extract session ID from URL query parameter
  const sessionId = req.query.sessionId as string;

  if (!sessionId) {
    console.error('No session ID provided in request URL');
    res.status(400).send('Missing sessionId parameter');
    return;
  }

  const transport = transports[sessionId];
  if (!transport) {
    console.error(`No active transport found for session ID: ${sessionId}`);
    res.status(404).send('Session not found');
    return;
  }

  try {
    // Handle the POST message with the transport
    await transport.handlePostMessage(req, res, req.body);
  } catch (error) {
    console.error('Error handling POST message:', error);
    if (!res.headersSent) {
      res.status(500).send('Error processing message');
    }
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    server: 'agent-mcp-sse',
    agents: AGENTS.map(a => a.id),
    timestamp: new Date().toISOString()
  });
});

// Install script endpoint
app.get('/install', (req, res) => {
  const installPath = path.join(__dirname, '../install.sh');
  const installScript = fs.readFileSync(installPath, 'utf8');
  res.setHeader('Content-Type', 'text/plain');
  res.send(installScript);
});

// Info endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'Agent MCP - Remote Access Server',
    version: '1.0.0',
    transport: 'SSE (Server-Sent Events)',
    endpoints: {
      sse: '/sse',
      health: '/health',
      info: '/',
      install: '/install'
    },
    install: {
      one_line: `curl -fsSL ${req.protocol}://${req.get('host')}/install | bash`,
      manual: [
        `claude mcp add -t sse jared-agents ${req.protocol}://${req.get('host')}/sse`,
        'Restart Claude Code'
      ]
    },
    usage: {
      sse: 'Connect via SSE for MCP protocol',
      config_example: {
        mcpServers: {
          'remote-agent-mcp': {
            type: 'sse',
            url: `${req.protocol}://${req.get('host')}/sse`
          }
        }
      }
    }
  });
});

app.listen(Number(PORT), '0.0.0.0', () => {
  console.error(`\n🌐 Remote MCP Server (SSE) running on http://0.0.0.0:${PORT}`);
  console.error(`📦 Loaded ${AGENTS.length} agents: ${AGENTS.map(a => a.id).join(', ')}`);
  console.error(`\nEndpoints:`);
  console.error(`  - SSE: http://0.0.0.0:${PORT}/sse`);
  console.error(`  - Health: http://0.0.0.0:${PORT}/health`);
  console.error(`  - Info: http://0.0.0.0:${PORT}/`);
  console.error(`\nRemote clients can connect via SSE transport`);
});
