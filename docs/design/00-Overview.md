# OpenCode Agent Config — Overview

**Last Updated:** 2026-05-17
**Status:** Unified /test command deployed, 97 tests passing

---

## Current State

| Component | Count | Status |
|-----------|-------|--------|
| MCP Servers | 5 (3 local + 2 remote) | ✅ Configured |
| Agents | 8 (5 built-in + 3 custom) | ✅ Complete |
| Skills | 37 (22 existing + 15 new) | ✅ Complete |
| Commands | 9 (8 Postman + 1 unified /test) | ✅ Complete |
| Tests | 97 (18 secrets + 13 config + 14 drift + 11 changelog + 41 orchestrator) | ✅ Complete |
| CI/CD | 3 workflows (validate, sync-log, evals) | ✅ Deployed |
| Scripts | 14 (5 config + 8 test + 1 orchestrator) | ✅ Complete |

---

## Quick Links

### Architecture
- [[01-Architecture/System-Overview|System Overview]]
- [[01-Architecture/Directory-Structure|Directory Structure]]
- [[01-Architecture/MCP-Architecture|MCP Architecture]]
- [[01-Architecture/Agent-System|Agent System]]
- [[01-Architecture/Command-System|Command System]]
- [[01-Architecture/Permission-System|Permission System]]
- [[01-Architecture/Rules-System|Rules System]]
- [[01-Architecture/Skill-Discovery|Skill Discovery]]

### Migration
- [[02-Migration/Plan|Migration Plan]]
- [[02-Migration/Before-After|Before/After Comparison]]
- [[02-Migration/Conflict-Resolution|Conflict Resolution]]
- [[02-Migration/Execution-Checklist|Execution Checklist]]

### Catalogs
- [[03-Skills/Skills-Index|Skills Index]] (quick reference)
- [[03-Skills/Skill-Catalog|Skill Catalog]] (all 37 skills)
- [[03-Skills/Agent-Catalog|Agent Catalog]] (all 8 agents)
- [[03-Skills/Command-Catalog|Command Catalog]] (all 8 commands)
- [[03-Skills/MCP-Catalog|MCP Catalog]] (all 5 MCP servers)

### Updates
- [[04-Updates/Changelog|Changelog]]

### Testing
- [[06-Testing/Test-Strategy|Test Strategy]]
- [[06-Testing/MCP-Conformance|MCP Conformance]]
- [[06-Testing/Config-Validation|Config Validation]]
- [[06-Testing/Eval-Framework|Eval Framework]]

### Observability
- [[07-Observability/Change-Log|Change Log]]
- [[07-Observability/Drift-Detection|Drift Detection]]
- [[07-Observability/Audit-Trail|Audit Trail]]

### Reference
- [[05-Reference/Quick-Start|Quick Start]]
- [[05-Reference/Authentication-Setup|Authentication Setup]]
- [[05-Reference/Reference-Index|Reference Index]]

---

## Config Root

All configuration lives under `~/.config/opencode/`:

```
~/.config/opencode/
├── opencode.json          ← MCP, agents, instructions, permissions
├── tui.json               ← TUI settings (theme, keybinds)
├── AGENTS.md              ← Global rules + Redis rules glob
├── agents/                ← 3 custom subagents
├── commands/              ← 8 Postman commands
├── skills/                ← 37 skills
├── plugins/               ← OpenCode plugin hooks
└── tests/                 ← Test suites (new)
```

## Git Repo

Mirror at `~/Desktop/projects/opencode-config/`:
- Sanitized `opencode.json` (secrets → env vars)
- All skills, agents, commands
- Documentation backup (`docs/design/`)
- CI/CD workflows (`.github/workflows/`)
- Test suites (`tests/`)
- Automation scripts (`scripts/`)
