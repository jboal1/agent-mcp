import 'dotenv/config';
import express from 'express';
import morgan from 'morgan';
import fs from 'fs';
import path from 'path';
import { z } from 'zod';
import { Anthropic } from '@anthropic-ai/sdk';
import { preFilter, postFilter } from './guardrails';

const PORT = process.env.PORT || 3000;
const API_KEY = process.env.API_KEY || "dev-key";
const ANTHROPIC_API_KEY = process.env.ANTHROPIC_API_KEY!;

const app = express();
app.use(express.json());
app.use(morgan('dev'));

// Simple API key authentication
app.use((req, res, next) => {
  if (req.headers['x-api-key'] !== API_KEY) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
});

const agentsDir = path.join(__dirname, 'agents');
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

function loadAgents(): Agent[] {
  return fs.readdirSync(agentsDir)
    .filter(f => f.endsWith('.yaml'))
    .map((f) => yaml.load(fs.readFileSync(path.join(agentsDir, f), 'utf8')) as Agent);
}

const AGENTS = loadAgents();

// Endpoint: List all agents (metadata only, no system prompts)
app.get('/agent.list', (_req, res) => {
  const publicAgents = AGENTS.map(({ system, ...rest }) => rest);
  res.json({ agents: publicAgents });
});

// Endpoint: Run an agent
const RunSchema = z.object({
  agent_id: z.string(),
  user_input: z.string(),
  temperature: z.number().optional()
});

app.post('/agent.run', async (req, res) => {
  const parsed = RunSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({ error: parsed.error.flatten() });
  }

  const { agent_id, user_input, temperature = 0.2 } = parsed.data;
  const agent = AGENTS.find((a) => a.id === agent_id);

  if (!agent) {
    return res.status(404).json({ error: 'Agent not found' });
  }

  try {
    // Apply pre-filter to block prompt injection attempts
    const cleanInput = preFilter(user_input);

    // Call Claude API with the agent's system prompt
    const anthropic = new Anthropic({ apiKey: ANTHROPIC_API_KEY });
    const resp = await anthropic.messages.create({
      model: process.env.CLAUDE_MODEL || 'claude-3-5-sonnet-20241022',
      max_tokens: 1200,
      temperature,
      messages: [{ role: 'user', content: cleanInput }],
      system: agent.system,
    });

    const text = (resp.content?.[0] as any)?.text ?? '';

    // Apply post-filter to redact any leaked instructions
    res.json({
      output: postFilter(text),
      usage: resp.usage,
      agent: {
        id: agent.id,
        version: agent.version
      }
    });
  } catch (err: any) {
    res.status(400).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Agent MCP Server running on port ${PORT}`);
  console.log(`📦 Loaded ${AGENTS.length} agents: ${AGENTS.map(a => a.id).join(', ')}`);
});
