# MCP Catalog

All 5 MCP servers.

---

## Local MCP Servers (3)

### confluence

- **Type:** local
- **Command:** `npx -y atlassian-confluence-mcp-server@latest`
- **Auth:** PAT (Personal Access Token)
- **Env:** `CONFLUENCE_BASE_URL`, `CONFLUENCE_USERNAME`, `PAT`
- **Tools:** Confluence pages, spaces, search, create, update, delete
- **Status:** ✅ Active

### obsidian

- **Type:** local
- **Command:** `npx @bitbonsai/mcpvault@latest /home/br4vetrave1er/Documents/br4vetrave1er notes`
- **Auth:** None
- **Tools:** Vault search, read, write, tags, frontmatter management
- **Status:** ✅ Active

### github

- **Type:** local
- **Command:** `npx -y @modelcontextprotocol/server-github`
- **Auth:** GitHub token
- **Env:** `GITHUB_TOKEN`
- **Tools:** Repos, issues, PRs, search, code search
- **Status:** ✅ Active

---

## Remote MCP Servers (2)

### postman

- **Type:** remote
- **URL:** `https://mcp.postman.com/mcp`
- **Auth:** OAuth 2.1
- **Tools:** 50+ tools
  - Collections: get, create, update, delete, sync
  - Specs: get, create, update, generate collection
  - Environments: get, create, patch, delete
  - Mocks: create, publish, unpublish, delete
  - Tests: run collection, get results
  - Search: private network, public network, tagged entities
  - Analytics, documentation, code generation
- **Status:** ⬜ Pending OAuth authentication

### atlassian

- **Type:** remote
- **URL:** `https://mcp.atlassian.com/v1/mcp`
- **Auth:** OAuth 2.1 (PKCE)
- **Tools:** Jira + Confluence
  - Jira: search issues, create/update issues, get projects, lookup account IDs
  - Confluence: get pages, create/update pages, search, get spaces
  - Cross-system: Rovo search across both
- **Status:** ⬜ Pending OAuth authentication

---

## Authentication

```bash
# Authenticate remote MCP servers
opencode mcp auth postman
opencode mcp auth atlassian

# List all MCP servers and auth status
opencode mcp list

# Debug connection
opencode mcp debug atlassian
```

---

## Tool Naming

| Server | Prefix | Example |
|--------|--------|---------|
| confluence | `confluence_` | `confluence_getPage` |
| obsidian | `obsidian_` | `obsidian_read_note` |
| github | `github_` | `github_search_repositories` |
| postman | `postman_` | `postman_getCollections` |
| atlassian | `atlassian_` | `atlassian_searchJiraIssuesUsingJql` |

---

## Related

- [[01-Architecture/MCP-Architecture|MCP Architecture]]
- [[03-Skills/Skills-Index|Skills Index]]
