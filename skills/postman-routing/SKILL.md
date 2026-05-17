---
name: postman-routing
description: Auto-route API/Postman requests to correct command
---

# Postman Routing

Automatically route user requests about APIs and Postman to the correct command.

## Routing Rules

| User Intent | Route To |
|-------------|----------|
| "Sync my API to Postman" | `/postman-sync` |
| "Generate client code" | `/postman-codegen` |
| "Find an API for..." | `/postman-search` |
| "Run my tests" | `/postman-test` |
| "Create a mock server" | `/postman-mock` |
| "Improve API docs" | `/postman-docs` |
| "Security audit" | `/postman-security` |
| "Set up Postman" | `/postman-setup` |
| "Is my API agent-ready?" | `agent-ready-apis` skill + `readiness-analyzer` agent |
| "How do I use Postman MCP?" | `postman-knowledge` skill |

## Workflow

1. Identify user intent from their request
2. Match to routing table above
3. If matching command exists, invoke it
4. If matching skill exists, load it
5. If ambiguous, ask clarifying question

## Fallback

If no route matches:
1. Check if the postman MCP server is connected
2. If not, suggest `/postman-setup`
3. If connected, use `postman-knowledge` skill to help
