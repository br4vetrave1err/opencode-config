# Command System

Commands are triggered with `/` prefix in the TUI.

---

## Command Flow

```
User types: /postman-sync
     │
     ▼
OpenCode loads command template from:
~/.config/opencode/commands/postman-sync.md
     │
     ▼
Template injected into agent prompt:
"Keep Postman collections in sync with local API code..."
     │
     ▼
Agent executes with specified agent/model:
agent: build, model: (default)
     │
     ▼
Agent uses MCP tools to complete workflow
```

---

## Our Commands

All Postman workflow commands:

| Command | Description | Agent |
|---------|-------------|-------|
| `/postman-sync` | Sync Postman collections with local API code | build |
| `/postman-codegen` | Generate typed client code from Postman collections | build |
| `/postman-search` | Discover APIs across Postman workspaces | build |
| `/postman-test` | Run collection tests, diagnose failures | build |
| `/postman-mock` | Create Postman mock servers | build |
| `/postman-docs` | Analyze and improve API documentation | build |
| `/postman-security` | Security audit against OWASP API Top 10 | build |
| `/postman-setup` | First-run Postman MCP configuration | build |

---

## Command Format

```markdown
---
description: "Shown in TUI command picker"
agent: build              # Which agent executes (default: current)
# model: anthropic/...   # Optional model override
subtask: false            # Force subagent invocation
---

Command template (prompt sent to agent)...
$ARGUMENTS               # User arguments
$1, $2, $3               # Positional arguments
!`git log --oneline -5`  # Shell output injection
@src/api.ts              # File reference
```

---

## Command Files Location

| Scope | Path |
|-------|------|
| Global | `~/.config/opencode/commands/<name>.md` |
| Project | `<project>/.opencode/commands/<name>.md` |

---

## Related

- [[01-Architecture/System-Overview|System Overview]]
- [[03-Skills/Command-Catalog|Command Catalog]]
