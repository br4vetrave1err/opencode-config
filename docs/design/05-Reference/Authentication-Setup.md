# Authentication Setup

Commands and procedures for authenticating all MCP servers.

---

## Local MCP Servers

### confluence

**Auth Type:** Personal Access Token (PAT)

```bash
# Set environment variables
export CONFLUENCE_BASE_URL="https://your-domain.atlassian.net/wiki"
export CONFLUENCE_USERNAME="your-email@example.com"
export PAT="your-personal-access-token"
```

**Get PAT:**
1. Go to Confluence → Profile → Personal Access Tokens
2. Create token with read/write permissions
3. Copy and store securely

### obsidian

**Auth Type:** None (local file access)

No authentication needed. MCP server accesses vault via filesystem path.

### github

**Auth Type:** Personal Access Token

```bash
export GITHUB_TOKEN="your-github-token"
```

**Get Token:**
1. GitHub → Settings → Developer Settings → Personal Access Tokens
2. Create token with `repo`, `read:org` scopes
3. Store in environment or OpenCode config

---

## Remote MCP Servers

### postman

**Auth Type:** OAuth 2.1

```bash
# Interactive OAuth flow
opencode mcp auth postman
```

**Process:**
1. Run command above
2. Browser opens for Postman login
3. Authorize the application
4. Token stored automatically

**Verify:**
```bash
opencode mcp list
# Should show postman as authenticated
```

### atlassian

**Auth Type:** OAuth 2.1 (PKCE)

```bash
# Interactive OAuth flow
opencode mcp auth atlassian
```

**Process:**
1. Run command above
2. Browser opens for Atlassian login
3. Authorize Jira and Confluence access
4. Token stored automatically

**Verify:**
```bash
opencode mcp list
# Should show atlassian as authenticated

# Test connection
opencode mcp debug atlassian
```

---

## Troubleshooting

### "Not authenticated" error

```bash
# Re-authenticate
opencode mcp auth <server-name>

# Check status
opencode mcp list
```

### Token expired

```bash
# Remote servers: re-authenticate (tokens auto-refresh)
opencode mcp auth postman
opencode mcp auth atlassian

# Local servers: update environment variables
export PAT="new-token"
export GITHUB_TOKEN="new-token"
```

### Connection refused

```bash
# Check if npx can download the server
npx -y atlassian-confluence-mcp-server@latest --help
npx -y @modelcontextprotocol/server-github --help

# Check network connectivity
curl -I https://mcp.postman.com/mcp
curl -I https://mcp.atlassian.com/v1/mcp
```

---

## Security Notes

- Never commit tokens to git
- Use environment variables for local MCP tokens
- Remote MCP tokens stored by OpenCode (encrypted at rest)
- Rotate tokens periodically
- Revoke unused tokens in respective dashboards

---

## Related

- [[05-Reference/Reference-Index|Reference Index]]
- [[01-Architecture/MCP-Architecture|MCP Architecture]]
