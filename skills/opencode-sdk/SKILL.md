---
name: opencode-sdk
description: Guide for building with the OpenCode SDK (@opencode-ai/sdk)
---

# OpenCode SDK

Guide for building applications with the OpenCode SDK (`@opencode-ai/sdk`).

## Installation

```bash
npm install @opencode-ai/sdk
```

## Core Concepts

### Client

```typescript
import { OpenCode } from "@opencode-ai/sdk";

const client = new OpenCode({
  apiKey: process.env.OPENCODE_API_KEY,
});
```

### Sessions

Create and manage coding sessions:

```typescript
const session = await client.sessions.create({
  model: "anthropic/claude-sonnet-4-20250514",
  instructions: "Build a REST API with Express",
});
```

### Messages

Send messages to a session:

```typescript
const response = await client.sessions.message(session.id, {
  role: "user",
  content: "Create a GET /users endpoint",
});
```

### Tools

Available tools in sessions:
- `bash`: Execute shell commands
- `read`: Read files
- `write`: Write files
- `edit`: Edit files
- `glob`: Find files by pattern
- `grep`: Search file contents

## Best Practices

1. Always handle tool errors gracefully
2. Use sessions for stateful conversations
3. Set clear instructions when creating sessions
4. Monitor session usage and costs

## Common Patterns

### Code Generation

```typescript
const session = await client.sessions.create({
  instructions: "Generate TypeScript code following project conventions",
});
await client.sessions.message(session.id, {
  content: "Create a User model with name, email, and createdAt fields",
});
```

### Code Review

```typescript
const session = await client.sessions.create({
  instructions: "Review code for bugs, security issues, and style",
});
await client.sessions.message(session.id, {
  content: "Review src/auth.ts",
});
```

## Resources

- SDK documentation: `npm info @opencode-ai/sdk`
- API reference: OpenCode docs
