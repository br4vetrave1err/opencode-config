# Skill Discovery

## Search Locations

OpenCode searches for skills in these locations (walks up from CWD to git root):

| Location | Pattern | Scope |
|----------|---------|-------|
| Project | `.opencode/skills/<name>/SKILL.md` | Current project |
| Global | `~/.config/opencode/skills/<name>/SKILL.md` | All projects |
| Claude compat | `.claude/skills/<name>/SKILL.md` | Project-level |
| Claude compat | `~/.claude/skills/<name>/SKILL.md` | Global |
| Agent compat | `.agents/skills/<name>/SKILL.md` | Project-level |
| Agent compat | `~/.agents/skills/<name>/SKILL.md` | Global |

---

## SKILL.md Format

```markdown
---
name: skill-name                  # Required: 1-64 chars, lowercase + hyphens
description: Brief description    # Required: 1-1024 chars
license: MIT                      # Optional
compatibility: opencode           # Optional
metadata:                         # Optional
  audience: maintainers
  workflow: github
---

# Skill Name

## Instructions
Clear, step-by-step guidance for the agent.
```

### Name Validation

```regex
^[a-z0-9]+(-[a-z0-9]+)*$
```

- Must match the directory name containing `SKILL.md`
- No consecutive hyphens (`--`)
- No leading/trailing hyphens

---

## How Discovery Works

1. OpenCode walks up from CWD to git worktree root
2. At each level, checks `.opencode/skills/*/SKILL.md`, `.claude/skills/*/SKILL.md`, `.agents/skills/*/SKILL.md`
3. Also checks global locations: `~/.config/opencode/skills/`, `~/.claude/skills/`, `~/.agents/skills/`
4. Loads skill names and descriptions into the `skill` tool
5. Agent can invoke: `skill({ name: "skill-name" })`

---

## Skill Permissions

```json
{
  "permission": {
    "skill": {
      "*": "allow",
      "pr-review": "allow",
      "internal-*": "deny",
      "experimental-*": "ask"
    }
  }
}
```

| Permission | Behavior |
|------------|----------|
| `allow` | Skill loads immediately |
| `deny` | Skill hidden from agent, access rejected |
| `ask` | User prompted for approval before loading |

### Per-Agent Override

```json
{
  "agent": {
    "plan": {
      "permission": {
        "skill": {
          "internal-*": "allow"
        }
      }
    }
  }
}
```

### Disable Skill Tool

```json
{
  "agent": {
    "plan": {
      "tools": {
        "skill": false
      }
    }
  }
}
```

---

## Troubleshooting

If a skill does not show up:

1. Verify `SKILL.md` is spelled in all caps
2. Check frontmatter includes `name` and `description`
3. Ensure skill names are unique across all locations
4. Check permissions — skills with `deny` are hidden

---

## Claude Code Compatibility

OpenCode includes Claude Code compatibility as a fallback layer for zero-friction migration. After our migration, `~/.claude/skills/` and `~/.agents/skills/` will be empty, but compatibility remains enabled (zero cost — empty dirs are skipped instantly).

To disable: `export OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1`

---

## Related

- [[01-Architecture/Directory-Structure|Directory Structure]]
- [[03-Skills/Skill-Catalog|Skill Catalog]]
