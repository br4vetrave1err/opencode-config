---
description: "First-run Postman MCP configuration"
agent: build
---

# Postman Setup

Guide user through connecting to Postman account via MCP Server.

## Workflow

1. **Check Connection**
   - Test if Postman MCP server is configured
   - Check authentication status

2. **Authenticate (if needed)**
   - Instruct user to run: `opencode mcp auth postman`
   - Explain the OAuth flow
   - Wait for authentication to complete

3. **Verify Connection**
   - List workspaces to confirm connection
   - Show available collections
   - Confirm MCP tools are working

4. **Select Workspace**
   - List available workspaces
   - Ask user which to use as default
   - Note workspace for future commands

5. **Quick Test**
   - Run a simple search to verify everything works
   - Show user what they can do next

## Next Steps

After setup, user can:
- `/postman-sync` — Sync local API code to Postman
- `/postman-search` — Discover APIs
- `/postman-test` — Run tests
- `/postman-mock` — Create mock servers
- `/postman-docs` — Improve documentation
- `/postman-security` — Security audit
- `/postman-codegen` — Generate client code

## Troubleshooting

- "Not authenticated" → Run `opencode mcp auth postman`
- "No workspaces" → Check Postman account has workspaces
- "Connection refused" → Check network connectivity to `mcp.postman.com`
