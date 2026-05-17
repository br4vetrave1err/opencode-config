# Opencode Agent Skills Guide

**Updated:** 2026-05-17
**Total Skills:** 36 (22 existing + 14 new)
**Total Agents:** 8 (5 built-in + 3 custom)
**Total Commands:** 8 (Postman workflow)
**Total MCP Servers:** 5 (3 local + 2 remote)

---

## Architecture Overview

All configuration consolidated under `~/.config/opencode/`:

```
~/.config/opencode/
├── opencode.json          ← MCP servers, agents, instructions, permissions
├── AGENTS.md              ← Global rules
├── agents/                ← 3 custom agents
├── commands/              ← 8 Postman commands
└── skills/                ← 36 skills
```

### Skill Sources

| Source | Count | Location |
|--------|-------|----------|
| Original OpenCode skills | 21 | `~/.agents/skills/` → moved to `~/.config/opencode/skills/` |
| Claude Code compatibility | 1 | `~/.claude/skills/` → moved |
| Postman plugin | 3 | `~/.cursor/plugins/cache/cursor-public/postman/` |
| Atlassian plugin | 5 | `~/.cursor/plugins/cache/cursor-public/atlassian/` |
| Cursor built-in (adapted) | 6 | `~/.cursor/skills-cursor/` |

---

## Quick Reference

### Planning & Design

| Need | Use | Type |
|------|-----|------|
| Convert idea to PRD | `to-prd` | Skill |
| Break plan into issues | `to-issues` | Skill |
| Stress-test a plan | `grill-me` | Skill |
| Design multiple interfaces | `design-an-interface` | Skill |
| Plan a refactor | `request-refactor-plan` | Skill |
| Analyze API agent-readiness | `@readiness-analyzer` | Agent |
| Keep PR merge-ready | `@pr-babysitter` | Agent |
| Split large change into PRs | `@split-to-prs` | Agent |
| Extract domain terms | `ubiquitous-language` | Skill |

### Development

| Need | Use | Type |
|------|-----|------|
| Build with TDD | `tdd` | Skill |
| Debug a bug | `triage-issue` | Skill |
| Triage Jira bug | `jira-triage-issue` | Skill |
| Improve architecture | `improve-codebase-architecture` | Skill |
| Generate client code from API | `/postman-codegen` | Command |
| Run API tests | `/postman-test` | Command |

### Project Management

| Need | Use | Type |
|------|-----|------|
| Create Jira tasks from meeting notes | `capture-tasks-from-meeting-notes` | Skill |
| Generate status report → Confluence | `generate-status-report` | Skill |
| Convert Confluence spec → Jira backlog | `spec-to-backlog` | Skill |
| Search company knowledge (Jira + Confluence) | `search-company-knowledge` | Skill |
| Triage GitHub issues | `github-triage` | Skill |
| Interactive QA → file issues | `qa` | Skill |

### API & Postman Workflow

| Need | Use | Type |
|------|-----|------|
| Sync API code ↔ Postman collections | `/postman-sync` | Command |
| Search APIs across workspaces | `/postman-search` | Command |
| Create mock server | `/postman-mock` | Command |
| Improve API documentation | `/postman-docs` | Command |
| Security audit (OWASP Top 10) | `/postman-security` | Command |
| Set up Postman MCP | `/postman-setup` | Command |
| Auto-route API requests | `postman-routing` | Skill |
| Postman MCP tool guidance | `postman-knowledge` | Skill |
| API agent-readiness knowledge | `agent-ready-apis` | Skill |

### Tooling & Setup

| Need | Use | Type |
|------|-----|------|
| Set up pre-commit hooks | `setup-pre-commit` | Skill |
| Block dangerous git | `git-guardrails-claude-code` | Skill |
| Create new skills | `write-a-skill` / `create-skill` | Skill |
| Create new agents | `create-subagent` | Skill |
| Create new rules | `create-rule` | Skill |
| Update OpenCode config | `update-opencode-config` | Skill |
| Update OpenCode settings | `update-opencode-settings` | Skill |
| OpenCode SDK guidance | `opencode-sdk` | Skill |

### Writing & Knowledge

| Need | Use | Type |
|------|-----|------|
| Edit/improve articles | `edit-article` | Skill |
| Manage Obsidian notes | `obsidian-vault` | Skill |
| Scaffold exercises | `scaffold-exercises` | Skill |
| Ultra-compressed communication | `caveman` | Skill |
| Zoom out for context | `zoom-out` | Skill |

### Browser Automation

| Need | Use | Type |
|------|-----|------|
| Automate browser interactions | `playwright-cli` | Skill |

---

## Agents

### Built-in Primary Agents

| Agent | Mode | Description |
|-------|------|-------------|
| `build` | primary | Default agent, all tools enabled |
| `plan` | primary | Read-only planning and analysis |

### Built-in Subagents

| Agent | Mode | Description |
|-------|------|-------------|
| `general` | subagent | Multi-step tasks, parallel work |
| `explore` | subagent | Fast read-only codebase exploration |
| `scout` | subagent | External docs and dependency research |

### Custom Subagents

| Agent | Type | Permission | Description |
|-------|------|------------|-------------|
| `readiness-analyzer` | subagent | edit, bash, read, glob, grep | API agent-readiness (8 pillars, 48 checks) |
| `pr-babysitter` | subagent | bash, read, glob, grep | PR merge-readiness loop |
| `split-to-prs` | subagent | bash, read, glob, grep | Split changes into PRs |

**Model:** No per-agent override — inherits from global OpenCode config.

---

## Commands

All Postman workflow commands (trigger with `/` prefix):

| Command | Description |
|---------|-------------|
| `/postman-sync` | Sync Postman collections with local API code |
| `/postman-codegen` | Generate typed client code from Postman collections |
| `/postman-search` | Discover APIs across Postman workspaces |
| `/postman-test` | Run collection tests, diagnose failures |
| `/postman-mock` | Create Postman mock servers |
| `/postman-docs` | Analyze and improve API documentation |
| `/postman-security` | Security audit against OWASP API Top 10 |
| `/postman-setup` | First-run Postman MCP configuration |

---

## MCP Servers

### Local MCP Servers

| Server | Command | Auth | Tools |
|--------|---------|------|-------|
| confluence | `npx atlassian-confluence-mcp-server@latest` | PAT | Confluence pages, spaces, search |
| obsidian | `npx @bitbonsai/mcpvault@latest` | None | Vault search, read, write, tags |
| github | `npx @modelcontextprotocol/server-github` | Token | Repos, issues, PRs, search |

### Remote MCP Servers

| Server | URL | Auth | Tools |
|--------|-----|------|-------|
| postman | `https://mcp.postman.com/mcp` | OAuth 2.1 | 50+ tools (collections, specs, mocks, tests, environments) |
| atlassian | `https://mcp.atlassian.com/v1/mcp` | OAuth 2.1 (PKCE) | Jira issues, Confluence pages, search, projects |

### Authentication

```bash
# Authenticate remote MCP servers (OAuth flow)
opencode mcp auth postman
opencode mcp auth atlassian

# List all MCP servers and auth status
opencode mcp list

# Debug MCP connection
opencode mcp debug atlassian
```

---

## Recommended Workflows

### Feature Implementation
1. `grill-me` — Clarify requirements
2. `design-an-interface` — Explore interface options
3. `to-prd` — Create formal spec
4. `to-issues` — Break into issues
5. `tdd` — Implement one issue at a time

### API Development (Postman Workflow)
1. `/postman-setup` — Connect Postman account
2. Write API code locally
3. `/postman-sync` — Push to Postman collections
4. `/postman-docs` — Generate documentation
5. `/postman-mock` — Create mock server for frontend
6. `/postman-test` — Run tests
7. `/postman-security` — Security audit
8. `/postman-codegen` — Generate client SDK

### Bug Fix
1. `triage-issue` — Investigate root cause (codebase bugs)
2. `jira-triage-issue` — Check Jira for duplicates (Jira bugs)
3. `tdd` — Write failing test first
4. Implement fix
5. Verify test passes

### Refactor
1. `improve-codebase-architecture` — Find opportunities
2. `request-refactor-plan` — Plan the refactor
3. `tdd` — Implement in small steps

### Meeting → Action Items
1. `capture-tasks-from-meeting-notes` — Extract action items → create Jira tasks
2. `generate-status-report` — Generate weekly status → publish to Confluence

### Spec → Implementation
1. `spec-to-backlog` — Convert Confluence spec → Jira backlog with Epics
2. `search-company-knowledge` — Search for related internal docs

---

## Skill Permissions

All skills are allowed by default (`"*": "allow"`). To restrict:

```jsonc
{
  "permission": {
    "skill": {
      "*": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

---

## Redis Development Rules

30+ rules loaded via `instructions` in `opencode.json`:

- **Connection:** pooling, blocking, pipelining, timeouts, client cache
- **Data:** structure selection, transactions, key naming, incr, hash field expiry
- **JSON:** partial updates, JSON vs Hash comparison
- **RAM:** limits, TTL management
- **RQE:** index management, query optimization, field types, dialect, skip initial scan
- **Cluster:** hash tags, read replicas
- **Security:** ACLs, auth, network
- **Semantic Cache:** best practices, LangCache usage
- **Streams:** choosing patterns
- **Vector:** algorithm choice, hybrid search, index creation, RAG pattern
- **Observability:** commands, metrics

---

## Related

- [[00-Overview|Overview]]
- [[02-Migration/Plan|Migration Plan]]
- [[03-Skills/Skill-Catalog|Skill Catalog]]
- [[05-Reference/Opencode-Agent-Config-Project|Project Details]]
