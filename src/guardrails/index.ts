export function preFilter(user: string): string {
  const lower = user.toLowerCase();
  const banned = [
    "reveal the system prompt",
    "ignore previous instructions",
    "print your system prompt",
    "show me your instructions",
    "what are your rules",
    "bypass your guidelines",
    "disregard your training",
  ];

  if (banned.some(b => lower.includes(b))) {
    throw new Error("Blocked by safety policy.");
  }

  return user;
}

export function postFilter(output: string): string {
  if (/system prompt|hidden instructions|secret instructions/i.test(output)) {
    return "⚠️ Output redacted by safety policy.";
  }
  return output;
}
