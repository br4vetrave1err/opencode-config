---
name: agent-ready-apis
description: Knowledge about AI agent API compatibility (8 pillars, 48 checks)
---

# Agent-Ready APIs

Knowledge about what makes an API compatible with AI agents. Use this when evaluating APIs, designing new endpoints, or troubleshooting agent integration failures.

## 8 Pillars of Agent-Ready APIs

1. **Discoverability** — Can agents find and understand your API?
2. **Authentication** — Can agents authenticate without human intervention?
3. **Error Handling** — Do errors provide actionable information?
4. **Idempotency** — Can agents safely retry operations?
5. **State Management** — Can agents track and manage state?
6. **Rate Limiting** — Are limits predictable and documented?
7. **Data Formats** — Are schemas strict and well-documented?
8. **Observability** — Can agents monitor and debug interactions?

## 48 Checks

Each pillar has 6 specific checks. When scanning an API, evaluate each check and score 0-2:
- 0 = Not implemented
- 1 = Partially implemented
- 2 = Fully implemented

## Usage

Use with the `readiness-analyzer` subagent to scan OpenAPI specs and generate agent-readiness reports.
