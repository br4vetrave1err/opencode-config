# Updates Changelog

All changes to the AI agent configuration, tracked by date.

---

## 2026-05-17: Consolidation — Phase 1 (Planning)

### What Changed
- Analyzed all 13 Cursor built-in skills, mapped to OpenCode equivalents.
- Investigated Atlassian MCP authentication method (OAuth 2.1 PKCE).
- Audited existing OpenCode skills to prevent duplication.
- Designed consolidated directory structure under `~/.config/opencode/`.
- Created Obsidian documentation: architecture (8 files), migration plan (4 files), catalogs (5 files).

### Decisions
- No per-agent model configuration; inherit from global config.
- Keep Claude Code compatibility enabled but empty (zero cost).
- Rename Atlassian triage skill to `jira-triage-issue` to avoid conflict.
- Skip `cursor-ide-browser` MCP; use existing `playwright-cli` skill.
- Migrate `babysit` and `split-to-prs` as subagents, not skills.
- Adapt `sdk` skill to `opencode-sdk` for OpenCode-specific guidance.

### New Components
- 3 custom subagents: `readiness-analyzer`, `pr-babysitter`, `split-to-prs`.
- 8 Postman commands: sync, codegen, search, test, mock, docs, security, setup.
- 14 new skills (3 Postman, 5 Atlassian, 6 Cursor-adapted).
- 2 remote MCP servers: Postman, Atlassian.

### Files Created
- `agent config/` Obsidian folder: 23 documentation files.

### Files to Update (Next Phase)
- ✅ `~/.config/opencode/opencode.json` — MCP, agents, instructions, permissions.
- ✅ `~/.config/opencode/agents/` — 3 custom agent files.
- ✅ `~/.config/opencode/commands/` — 8 command files.
- ✅ `~/.config/opencode/skills/` — 14 new skill files.

### Files to Move
- ✅ 22 existing skills from `~/.agents/skills/` and `~/.claude/skills/` → `~/.config/opencode/skills/`.

### Files to Delete (After Verification)
- ✅ `~/.agents/skills/` (moved)
- ✅ `~/.claude/skills/` (moved)

### OAuth Authentication
- ✅ `opencode mcp auth postman` — Authenticated
- ✅ `opencode mcp auth atlassian` — Authenticated

### Obsidian Docs Backup
- ✅ Copied to git repo: `docs/design/` (22 files)

---

## 2026-05-17: Consolidation — Phase 2 (Execution Complete)

### What Changed
- Moved 22 existing skills to `~/.config/opencode/skills/`
- Created 14 new skills (3 Postman, 5 Atlassian, 6 Cursor-adapted)
- Created 3 custom subagents in `~/.config/opencode/agents/`
- Created 8 Postman commands in `~/.config/opencode/commands/`
- Updated `opencode.json` with remote MCP servers, agents, permissions
- Authenticated both remote MCP servers via OAuth
- Copied Obsidian docs to git repo as backup (`docs/design/`)

### Final State
- **Skills:** 41 total (22 original + 14 new + 5 existing custom)
- **Agents:** 3 custom subagents
- **Commands:** 8 Postman workflow commands
- **MCP Servers:** 5 (3 local + 2 remote, both authenticated)
- **Documentation:** 22 files in git repo `docs/design/`

### Verification
```
opencode mcp list
● ✓ postman  connected  (https://mcp.postman.com/mcp)
● ✓ atlassian  connected  (https://mcp.atlassian.com/v1/mcp)
```

---

## Related
- [[00-Overview|Overview]]
- [[02-Migration/Plan|Migration Plan]]
