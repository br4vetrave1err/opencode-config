# Before/After Comparison

## Configuration Locations

### Before (Scattered)

```
~/.agents/skills/          ← 21 skills
~/.claude/skills/          ← 1 skill
~/.cursor/skills-cursor/   ← 13 skills (Cursor-internal)
~/.cursor/plugins/cache/   ← 8 plugin skills
~/.config/opencode/        ← 3 MCP servers
~/.cursor/projects/*/mcps/ ← 3 project MCPs
```

### After (Consolidated)

```
~/.config/opencode/
├── opencode.json          ← 5 MCP, 3 agents, instructions, permissions
├── agents/                ← 3 custom agents
├── commands/              ← 8 Postman commands
├── skills/                ← 36 skills (all sources)
└── AGENTS.md              ← Global rules
```

---

## Numbers

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Config locations | 6 | 1 | -5 |
| MCP servers | 6 (3+3) | 5 | -1 (browser MCP → playwright-cli skill) |
| Skills | 43 (21+1+13+8) | 36 | -7 (Cursor-internal skipped) |
| Agents | 5 (built-in) | 8 (5+3) | +3 |
| Commands | 0 | 8 | +8 |

---

## Skill Source Breakdown

| Source | Before Location | After Location | Count |
|--------|----------------|----------------|-------|
| Original OpenCode | `~/.agents/skills/` | `~/.config/opencode/skills/` | 21 |
| Claude Code compat | `~/.claude/skills/` | `~/.config/opencode/skills/` | 1 |
| Postman plugin | `~/.cursor/plugins/cache/.../postman/` | `~/.config/opencode/skills/` | 3 |
| Atlassian plugin | `~/.cursor/plugins/cache/.../atlassian/` | `~/.config/opencode/skills/` | 5 |
| Cursor built-in (adapted) | `~/.cursor/skills-cursor/` | `~/.config/opencode/skills/` | 6 |
| **Total** | | | **36** |

---

## MCP Server Migration

| Server | Before | After | Change |
|--------|--------|-------|--------|
| confluence | `~/.config/opencode/opencode.json` | Same | No change |
| obsidian | `~/.config/opencode/opencode.json` | Same | No change |
| github | `~/.config/opencode/opencode.json` | Same | No change |
| postman | `~/.cursor/projects/*/mcps/` | `~/.config/opencode/opencode.json` | Moved to global |
| atlassian | `~/.cursor/projects/*/mcps/` | `~/.config/opencode/opencode.json` | Moved to global |
| cursor-ide-browser | `~/.cursor/projects/*/mcps/` | Removed | Replaced by playwright-cli skill |

---

## Related

- [[02-Migration/Plan|Migration Plan]]
- [[02-Migration/Conflict-Resolution|Conflict Resolution]]
