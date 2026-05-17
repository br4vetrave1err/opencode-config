# OpenCode Agent Config — Overview

**Last Updated:** 2026-05-17
**Status:** Active — 122 skills, 4 agents, 10 commands

---

## Current State

| Component | Count | Status |
|-----------|-------|--------|
| MCP Servers | 5 (3 local + 2 remote) | ✅ Configured |
| Agents | 4 custom subagents | ✅ Complete |
| Skills | 122 (38 directories) | ✅ Complete |
| Commands | 10 | ✅ Complete |

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
- [[03-Skills/Skill-Catalog|Skill Catalog]] (all 36 skills)
- [[03-Skills/Agent-Catalog|Agent Catalog]] (all 8 agents)
- [[03-Skills/Command-Catalog|Command Catalog]] (all 8 commands)
- [[03-Skills/MCP-Catalog|MCP Catalog]] (all 5 MCP servers)

### Updates
- [[04-Updates/Changelog|Changelog]]
- [[04-Updates/2026-05-17-Initial-Migration|2026-05-17 Initial Migration]]

### Reference
- [[05-Reference/Opencode-Agent-Config-Project|Project Details]]
- [[05-Reference/Workflows|Recommended Workflows]]
- [[05-Reference/Troubleshooting|Troubleshooting]]

---

## Config Root

All configuration lives under `~/.config/opencode/`:

```
~/.config/opencode/
├── opencode.json          ← MCP, agents, instructions, permissions
├── agents/                ← 3 custom subagents
├── commands/              ← 8 Postman commands
└── skills/                ← 36 skills
```
