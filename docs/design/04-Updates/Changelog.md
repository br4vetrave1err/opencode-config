# Updates Changelog

All changes to the AI agent configuration, tracked by date.

---

## 2026-05-17: Consolidation — Phase 4 (Testing & Observability Framework)

### What Changed
- Designed 3-layer testing framework (unit/smoke → conformance → evals)
- Created GitHub Actions CI/CD pipeline (3 workflows)
- Created 12 skill smoke tests for external service validation
- Created MCP conformance test runner (5 servers)
- Created agent eval framework (17 scenarios × 3 trials)
- Created config validation, secrets scanning, drift detection scripts
- Created changelog auto-generation script
- Set up cron jobs for 10 PM daily drift detection + changelog
- Added shields.io badges to README
- Created testing and observability documentation (7 files)

### Decisions
- Evals run locally only (not in CI) to avoid token costs and auth complexity
- MCP conformance tests core scenarios only (server-initialize, tools-list, tools-call) for CI speed
- Secrets scanner uses regex patterns (no external deps)
- Drift detection uses checksums (faster than full diff)
- Badge format: shields.io static badges updated by sync-and-log workflow
- Eval trials: 3 per scenario for stochastic averaging

### New Components
- **Scripts:** 5 (validate-config, secrets-scan, detect-drift, generate-changelog, run-all-tests)
- **Smoke Tests:** 12 (one per skill requiring external service)
- **Conformance Tests:** 2 (runner + expected-failures baseline)
- **Eval Specs:** 5 YAML files (3 agent + 2 workflow)
- **CI/CD Workflows:** 3 (validate-config, sync-and-log, agent-evals)
- **Documentation:** 7 files (testing strategy + observability)

### Final State
- **Skills:** 37 total
- **Tests:** 56 total (18 secrets + 13 config + 14 drift + 11 changelog) — all passing
- **Scripts:** 5 (secrets-scan, validate-config, detect-drift, generate-changelog, sync-to-repo)
- **Eval Scenarios:** 17 (local only)
- **CI/CD:** 3 workflows (deployed)
- **Cron Jobs:** 2 (drift detection + changelog at 10 PM daily)

---

## 2026-05-17: Consolidation — Phase 3 (Redis Skill + Playwright Tests)

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
