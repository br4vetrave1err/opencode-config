# Updates Changelog

All changes to the AI agent configuration, tracked by date.

---

## 2026-05-17: Consolidation — Phase 1 (Planning)

### Additional Changes
- Created comprehensive Agentic Architecture Guide (08-Development/) — complete reference for using the system effectively

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

---

## 2026-05-17: Consolidation — Phase 3 (Redis Skill + Playwright Tests)

### Additional Changes
- Created comprehensive Agentic Architecture Guide (08-Development/) — complete reference for using the system effectively

### What Changed
- Copied `redis-development` skill from Cursor plugin cache to `~/.config/opencode/skills/redis-development/`
- Updated instructions glob in `opencode.json` and `AGENTS.md` to point to new location
- Created playwright-cli test suite (`skills/playwright-cli/tests/run-tests.sh`)
- All 36 playwright-cli tests passing
- Updated Obsidian docs and git repo

### Final State
- **Skills:** 37 total (36 previous + redis-development)
- **Redis Rules:** 37 rule files across 11 categories, now in `skills/redis-development/rules/`
- **Playwright Tests:** 36/36 passing across 15 command categories

---

## 2026-05-17: Consolidation — Phase 2 (Execution Complete)

### Additional Changes
- Created comprehensive Agentic Architecture Guide (08-Development/) — complete reference for using the system effectively

### What Changed
- Moved 22 existing skills to `~/.config/opencode/skills/`
- Created 14 new skills (3 Postman, 5 Atlassian, 6 Cursor-adapted)
- Created 3 custom subagents in `~/.config/opencode/agents/`
- Created 8 Postman commands in `~/.config/opencode/commands/`
- Updated `opencode.json` with remote MCP servers, agents, permissions, instructions
- Created `AGENTS.md` with global rules + Redis rules glob
- Created `tui.json` with default TUI settings
- Authenticated both remote MCP servers via OAuth
- Removed old directories: `~/.agents/skills/`, `~/.claude/skills/`
- Removed old custom skills: autonomous-agent, problem-planner, output-validator, continuous-monitor, docker-monitor
- Copied Obsidian docs to git repo as backup (`docs/design/`)

### Final State
- **Skills:** 36 total (21 original + 14 new + 1 playwright-cli)
- **Agents:** 3 custom subagents
- **Commands:** 8 Postman workflow commands
- **MCP Servers:** 5 (3 local + 2 remote, both authenticated)
- **Config Files:** opencode.json, tui.json, AGENTS.md
- **Instructions:** Redis rules glob (30+ rules from Cursor plugin cache)
- **Documentation:** 22 files in Obsidian + git repo backup

### Verification
```
opencode mcp list
● ✓ postman  connected  (https://mcp.postman.com/mcp)
● ✓ atlassian  connected  (https://mcp.atlassian.com/v1/mcp)
```

### 4-Way Sync Status
| Component | Status |
|-----------|--------|
| `~/.config/opencode/` | ✅ Source of truth |
| Git repo | ✅ Synced (sanitized) |
| Obsidian vault | ✅ Synced |
| Git repo docs/design/ | ✅ Backup of Obsidian |

---

## Related
- [[00-Overview|Overview]]
- [[02-Migration/Plan|Migration Plan]]
