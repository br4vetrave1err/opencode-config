# MCP Architecture

## Connection Types

| Type | Description | Config Fields |
|------|-------------|---------------|
| local | Spawned as child process | `command`, `environment`, `timeout` |
| remote | HTTP endpoint | `url`, `headers`, `oauth`, `timeout` |

---

## Our MCP Servers

### Local MCP Servers

```
┌─────────────────────────────────────────────────────────────┐
│                    LOCAL MCP SERVERS                         │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ confluence   │  │ obsidian     │  │ github       │      │
│  │ (npx)        │  │ (npx)        │  │ (npx)        │      │
│  │ PAT auth     │  │ vault path   │  │ token auth   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

| Server | Command | Auth | Tools |
|--------|---------|------|-------|
| confluence | `npx atlassian-confluence-mcp-server@latest` | PAT | Confluence pages, spaces, search |
| obsidian | `npx @bitbonsai/mcpvault@latest` | None | Vault search, read, write, tags |
| github | `npx @modelcontextprotocol/server-github` | Token | Repos, issues, PRs, search |

### Remote MCP Servers

```
┌─────────────────────────────────────────────────────────────┐
│                    REMOTE MCP SERVERS                        │
│                                                              │
│  ┌──────────────┐                ┌──────────────┐           │
│  │ postman      │                │ atlassian    │           │
│  │ (OAuth 2.1)  │                │ (OAuth 2.1)  │           │
│  │ 50+ tools    │                │ Jira+Confl.  │           │
│  └──────────────┘                └──────────────┘           │
└─────────────────────────────────────────────────────────────┘
```

| Server | URL | Auth | Tools |
|--------|-----|------|-------|
| postman | `https://mcp.postman.com/mcp` | OAuth 2.1 | 50+ tools (collections, specs, mocks, tests, environments) |
| atlassian | `https://mcp.atlassian.com/v1/mcp` | OAuth 2.1 (PKCE) | Jira issues, Confluence pages, search, projects |

---

## OAuth Flow (Remote MCP)

```
Agent detects 401
    │
    ▼
OpenCode initiates OAuth 2.1 + PKCE
    │
    ▼
Opens browser → user consents
    │
    ▼
Callback → tokens stored
    │
    ▼
~/.local/share/opencode/mcp-auth.json
    │
    ▼
MCP server connected ✅
```

### Authentication Commands

```bash
# Authenticate remote MCP servers
opencode mcp auth postman
opencode mcp auth atlassian

# List all MCP servers and auth status
opencode mcp list

# Debug MCP connection
opencode mcp debug atlassian

# Remove stored credentials
opencode mcp logout atlassian
```

---

## Atlassian MCP Authentication Detail

The Atlassian MCP uses **OAuth 2.1 (3LO) with PKCE** — no API key or PAT needed:

- **Server:** `https://mcp.atlassian.com/v1/mcp`
- **Auth flow:** Browser-based OAuth consent
- **Token storage:** `~/.local/share/opencode/mcp-auth.json`
- **Current Cursor state:** Stuck in `needsAuth` — never completed OAuth flow

**Note:** This is separate from the existing `confluence` MCP which uses PAT auth. The new Atlassian MCP covers Jira + Confluence via OAuth.

---

## Browser MCP (cursor-ide-browser)

**Status:** Cursor-IDE-only — not a standalone MCP server.
**Alternative:** `playwright-cli` skill provides browser automation via CLI (navigate, click, fill, screenshot, etc.). OpenCode loads this automatically via Claude Code compatibility.

---

## Tool Naming Convention

MCP tools are prefixed with server name:

| Server | Example Tools |
|--------|--------------|
| confluence | `confluence_getPage`, `confluence_search`, `confluence_createPage` |
| obsidian | `obsidian_read_note`, `obsidian_write_note`, `obsidian_search_notes` |
| github | `github_search_repositories`, `github_create_issue`, `github_create_pull_request` |
| postman | `postman_getCollections`, `postman_createCollection`, `postman_runCollection` |
| atlassian | `atlassian_searchJiraIssuesUsingJql`, `atlassian_createJiraIssue`, `atlassian_createConfluencePage` |

### Permission Patterns

```json
{
  "permission": {
    "postman_*": "allow",
    "atlassian_*": "ask",
    "confluence_getPage": "allow",
    "github_*": "allow"
  }
}
```

---

## Related

- [[01-Architecture/System-Overview|System Overview]]
- [[03-Skills/MCP-Catalog|MCP Catalog]]
