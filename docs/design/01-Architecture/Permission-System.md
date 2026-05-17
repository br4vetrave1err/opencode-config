# Permission System

## Permission Levels

| Level | Behavior |
|-------|----------|
| `allow` | Execute without approval |
| `ask` | Prompt user before execution |
| `deny` | Block entirely |

---

## Permission Keys

| Key | Gates |
|-----|-------|
| `read` | File read |
| `edit` | write, edit, apply_patch |
| `glob` | File glob |
| `grep` | Content grep |
| `bash` | Shell commands |
| `task` | Subagent invocation |
| `skill` | Skill loading |
| `webfetch` | Web fetching |
| `websearch` | Web search |
| `lsp` | LSP operations |
| `external_directory` | Files outside project worktree |
| `todowrite` | todowrite, todoread |
| `question` | User question tool |
| `doom_loop` | Recovery prompts when agent stuck |

---

## Permission Scoping

```
Global permissions (opencode.json)
    │
    ├── Override per-agent (agent config)
    │       │
    │       └── Override per-skill (skill frontmatter)
    │
    └── Glob patterns supported
            "bash": {
              "*": "ask",
              "git status*": "allow",
              "git push*": "deny"
            }
```

### Global Permissions

```json
{
  "permission": {
    "edit": "ask",
    "bash": "ask",
    "skill": {
      "*": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

### Per-Agent Override

```json
{
  "agent": {
    "build": {
      "permission": {
        "edit": "allow",
        "bash": {
          "*": "ask",
          "git status*": "allow"
        }
      }
    }
  }
}
```

### Per-Skill Override (in SKILL.md frontmatter)

```yaml
---
name: my-skill
description: ...
permission:
  edit: deny
  bash:
    "*": ask
    "git diff*": allow
---
```

---

## MCP Tool Permissions

MCP tools use the same permission system with server name prefix:

```json
{
  "permission": {
    "postman_*": "allow",
    "atlassian_*": "ask",
    "confluence_getPage": "allow",
    "confluence_*": "deny"
  }
}
```

Glob patterns:
- `*` matches zero or more characters
- `?` matches exactly one character
- All other characters match literally

---

## Related

- [[01-Architecture/System-Overview|System Overview]]
- [[01-Architecture/Agent-System|Agent System]]
