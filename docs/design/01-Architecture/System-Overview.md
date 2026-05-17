# System Overview

## OpenCode Agent System Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     OpenCode Agent System                    │
│                                                              │
│  ┌──────────  ┌──────────┐  ┌──────────┐  ┌──────────────┐ │
│  │  TUI     │  │  CLI     │  │ Desktop  │  │  IDE Ext     │ │
│  │ (main)   │  │ (run)    │  │ (beta)   │  │  (future)    │ │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └─────────────┘ │
│       │             │             │                │         │
│       └─────────────┴─────────────┴────────────────┘         │
│                         │                                     │
│                  ┌──────▼──────┐                              │
│                  │  opencode   │                              │
│                  │   engine    │                              │
│                  └────────────┘                              │
│                         │                                     │
│    ┌────────────────────┼────────────────────┐               │
│    │                    │                    │               │
│    ▼                    ▼                    ▼               │
│  ┌──────┐          ┌─────────┐         ┌──────────┐         │
│  │Agents│          │  MCP    │         │  Skills  │         │
│  │  8   │          │Servers  │         │   36     │         │
│  └──────          │   5     │         └──────────┘         │
│                    └─────────┘                               │
│                                                              │
│  ┌──────────  ┌──────────┐  ┌──────────┐  ┌──────────────┐ │
│  │ Commands │  │  Rules   │  │  Models  │  │  Permissions │ │
│  │    8     │  │ (AGENTS) │  │ (Zen+)   │  │  (fine-grain)│ │
│  └──────────┘  └──────────  └──────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## Configuration Layers (Precedence Order)

Config sources are **merged** (not replaced). Later sources override earlier ones for conflicting keys.

| Order | Source | Path | Purpose |
|-------|--------|------|---------|
| 1 | Remote config | `.well-known/opencode` | Organizational defaults |
| 2 | Global config | `~/.config/opencode/opencode.json` | User preferences |
| 3 | Custom config | `$OPENCODE_CONFIG` | Custom overrides |
| 4 | Project config | `<project>/opencode.json` | Project-specific settings |
| 5 | `.opencode/` dirs | `<project>/.opencode/` | Agents, commands, plugins, skills |
| 6 | Inline config | `$OPENCODE_CONFIG_CONTENT` | Runtime overrides |
| 7 | Managed config | `/etc/opencode/` (Linux) | Admin-controlled (highest) |

### Our Configuration

| Layer | File | Status |
|-------|------|--------|
| Global | `~/.config/opencode/opencode.json` | ✅ Active — MCP, agents, instructions, permissions |
| Global TUI | `~/.config/opencode/tui.json` | ⬜ Optional — theme, keybinds, scroll |
| Global Rules | `~/.config/opencode/AGENTS.md` | ⬜ Optional — global instructions |
| Project | `<project>/opencode.json` | ⬜ Per-project overrides |
| Project Rules | `<project>/AGENTS.md` | ✅ Active in some projects |

---

## Claude Code Compatibility

OpenCode automatically discovers skills in Claude Code locations as a fallback:

| Location | Pattern | Scope |
|----------|---------|-------|
| Project | `.claude/skills/<name>/SKILL.md` | Project-level |
| Global | `~/.claude/skills/<name>/SKILL.md` | Global |
| Agent compat | `.agents/skills/<name>/SKILL.md` | Project-level |
| Agent compat | `~/.agents/skills/<name>/SKILL.md` | Global |

**After migration:** All skills live in `~/.config/opencode/skills/`. Old locations are cleaned up but compatibility remains enabled (zero cost — empty dirs are skipped instantly).

To disable: `export OPENCODE_DISABLE_CLAUDE_CODE=1`

---

## Related

- [[01-Architecture/Directory-Structure|Directory Structure]]
- [[01-Architecture/MCP-Architecture|MCP Architecture]]
- [[01-Architecture/Agent-System|Agent System]]
