# 2026-05-17: Major Consolidation

## Summary

Migrated all AI agent configuration from scattered locations (Cursor, Claude Code, `~/.agents/skills/`) into a single consolidated OpenCode configuration under `~/.config/opencode/`.

## Changes

### New Components Added

| Component | Count | Details |
|-----------|-------|---------|
| MCP Servers | +2 | Postman (remote OAuth), Atlassian (remote OAuth) |
| Skills | +19 | 3 Postman, 5 Atlassian, 6 Cursor-adapted, 5 existing custom |
| Agents | +3 | readiness-analyzer, pr-babysitter, split-to-prs |
| Commands | +8 | Postman workflow commands |

### Skills Added

**Postman (3):**
- `agent-ready-apis` — AI agent API compatibility knowledge (8 pillars, 48 checks)
- `postman-knowledge` — Postman concepts and MCP tool guidance
- `postman-routing` — Auto-route API requests to correct command

**Atlassian (5):**
- `capture-tasks-from-meeting-notes` — Extract action items → create Jira tasks
- `generate-status-report` — Jira status reports → publish to Confluence
- `spec-to-backlog` — Confluence specs → Jira backlogs with Epics
- `search-company-knowledge` — Search Confluence + Jira for internal docs
- `jira-triage-issue` — Triage bugs, check Jira duplicates, create/link issues

**Cursor-Adapted (6):**
- `create-rule` — Create rule files for persistent AI guidance
- `create-skill` — Create SKILL.md files with proper structure
- `create-subagent` — Create custom subagent .md files
- `opencode-sdk` — Guide for building with OpenCode SDK
- `update-opencode-config` — Edit opencode.json configuration
- `update-opencode-settings` — Update TUI settings

**Existing Custom (5):**
- `autonomous-agent` — Autonomous agent operations
- `continuous-monitor` — Docker continuous monitoring
- `docker-monitor` — Docker container debugging
- `output-validator` — Output validation with domain checks
- `problem-planner` — Problem planning and decomposition

### Agents Added

- `readiness-analyzer` — Scan OpenAPI specs for agent-readiness (8 pillars, 48 checks)
- `pr-babysitter` — Keep PRs merge-ready (conflicts, comments, CI loop)
- `split-to-prs` — Split large changes into multiple PRs

### Commands Added

All Postman workflow commands (trigger with `/` prefix):
- `/postman-sync` — Sync collections with local API code
- `/postman-codegen` — Generate typed client code
- `/postman-search` — Discover APIs across workspaces
- `/postman-test` — Run collection tests, diagnose failures
- `/postman-mock` — Create mock servers
- `/postman-docs` — Analyze and improve API documentation
- `/postman-security` — Security audit (OWASP API Top 10)
- `/postman-setup` — First-run Postman MCP configuration

### Directory Structure

```
~/.config/opencode/
├── opencode.json          ← MCP (5), agents (3), instructions, permissions
├── AGENTS.md              ← Global rules
├── skills/                ← 41 skills total
├── agents/                ← 3 custom subagents
└── commands/              ← 8 Postman commands
```

### MCP Servers

| Server | Type | Auth | Status |
|--------|------|------|--------|
| confluence | local | PAT | ✅ Active |
| obsidian | local | None | ✅ Active |
| github | local | Token | ✅ Active |
| postman | remote | OAuth 2.1 | ⬜ Pending auth |
| atlassian | remote | OAuth 2.1 (PKCE) | ⬜ Pending auth |

### Decisions

- No per-agent model configuration; inherit from global config
- Keep Claude Code compatibility enabled but empty (zero cost)
- Rename Atlassian triage to `jira-triage-issue` to avoid conflict with existing `triage-issue`
- Skip `cursor-ide-browser` MCP; use existing `playwright-cli` skill
- Migrate `babysit` and `split-to-prs` as subagents, not skills
- Adapt `sdk` skill to `opencode-sdk` for OpenCode-specific guidance

### Cleanup

- Removed `~/.agents/skills/` (moved to `~/.config/opencode/skills/`)
- Removed `~/.claude/skills/` (moved to `~/.config/opencode/skills/`)

### Pending

- [ ] `opencode mcp auth postman` — OAuth flow
- [ ] `opencode mcp auth atlassian` — OAuth flow
