# Migration Plan

**Status:** Planned
**Created:** 2026-05-17
**Scope:** Migrate all Cursor plugins, skills, subagents, commands, MCP servers, and rules into OpenCode under `~/.config/opencode/`

---

## Executive Summary

Consolidate **all** AI agent configuration from scattered locations into a single OpenCode config directory.

### Current State (Scattered)

```
~/.agents/skills/          ← 21 OpenCode-compatible skills
~/.claude/skills/          ← 1 skill (playwright-cli)
~/.cursor/skills-cursor/   ← 13 Cursor built-in skills
~/.cursor/plugins/cache/   ← 8 plugin skills (Postman + Atlassian)
~/.config/opencode/        ← 3 MCP servers (confluence, obsidian, github)
~/.cursor/projects/*/mcps/ ← 3 project MCPs (postman, atlassian, browser)
```

### Target State (Consolidated)

```
~/.config/opencode/
├── opencode.json          ← Single source of truth (MCP + agents + instructions)
├── agents/                ← 3 custom agents
├── commands/              ← 8 Postman commands
├── skills/                ← 36 skills (22 existing + 14 new)
└── AGENTS.md              ← Global rules
```

---

## Phase 1: MCP Servers

### Existing (Keep)

| Server | Type | Config | Status |
|--------|------|--------|--------|
| confluence | local | `npx atlassian-confluence-mcp-server@latest` + PAT | ✅ Keep |
| obsidian | local | `npx @bitbonsai/mcpvault@latest` + vault path | ✅ Keep |
| github | local | `npx @modelcontextprotocol/server-github` + token | ✅ Keep |

### New (Add)

| Server | Type | URL | Auth | Notes |
|--------|------|-----|------|-------|
| postman | remote | `https://mcp.postman.com/mcp` | OAuth 2.1 | 50+ tools |
| atlassian | remote | `https://mcp.atlassian.com/v1/mcp` | OAuth 2.1 (PKCE) | Jira + Confluence |

### Atlassian MCP Authentication

OAuth 2.1 (3LO) with PKCE — no API key needed:
1. Config: `{"type": "remote", "url": "https://mcp.atlassian.com/v1/mcp"}`
2. Auth: `opencode mcp auth atlassian`
3. Tokens stored in `~/.local/share/opencode/mcp-auth.json`

### Browser MCP

Cursor-IDE-only. Alternative: `playwright-cli` skill already exists.

---

## Phase 2: Agents

### New Agents

| Agent | Source | Mode | Permission |
|-------|--------|------|------------|
| `readiness-analyzer` | Cursor subagent | subagent | edit, bash, read, glob, grep |
| `pr-babysitter` | Cursor `babysit` skill | subagent | bash, read, glob, grep |
| `split-to-prs` | Cursor `split-to-prs` skill | subagent | bash, read, glob, grep |

**Model:** No per-agent override — inherits from global config.

---

## Phase 3: Commands (8)

| Command | Description |
|---------|-------------|
| `/postman-codegen` | Generate typed client code |
| `/postman-docs` | Analyze/improve API docs |
| `/postman-mock` | Create mock servers |
| `/postman-search` | Discover APIs |
| `/postman-security` | OWASP security audit |
| `/postman-setup` | First-run Postman MCP setup |
| `/postman-sync` | Sync collections ↔ code |
| `/postman-test` | Run collection tests |

---

## Phase 4: Skills (36 Total)

### Existing (22 — Move)

From `~/.agents/skills/` (21): caveman, design-an-interface, domain-model, edit-article, find-skills, git-guardrails-claude-code, github-triage, grill-me, improve-codebase-architecture, obsidian-vault, qa, request-refactor-plan, scaffold-exercises, setup-pre-commit, tdd, to-issues, to-prd, triage-issue, ubiquitous-language, write-a-skill, zoom-out

From `~/.claude/skills/` (1): playwright-cli

### New from Plugins (8)

From Postman: agent-ready-apis, postman-knowledge, postman-routing
From Atlassian: capture-tasks-from-meeting-notes, generate-status-report, spec-to-backlog, search-company-knowledge, jira-triage-issue (renamed)

### New from Cursor Built-in (6)

create-rule, create-skill, create-subagent, opencode-sdk, update-opencode-config, update-opencode-settings

### Skipped Cursor Built-in (7)

canvas (UI-only), migrate-to-skills (not needed), shell (native), statusline (UI-only), babysit→agent, split-to-prs→agent, sdk→opencode-sdk

---

## Phase 5: Redis Rules

Add to `opencode.json` instructions:
```json
"instructions": ["~/.cursor/plugins/cache/cursor-public/redis-development/*/rules/*.md"]
```

---

## Execution Checklist

See [[02-Migration/Execution-Checklist|Execution Checklist]] for step-by-step tasks.

---

## Related

- [[02-Migration/Before-After|Before/After Comparison]]
- [[02-Migration/Conflict-Resolution|Conflict Resolution]]
- [[02-Migration/Execution-Checklist|Execution Checklist]]
