# Agent Catalog

Complete catalog of all 8 agents.

---

## Built-in Primary Agents

| Agent | Mode | Tools | Description |
|-------|------|-------|-------------|
| `build` | primary | all | Default development agent with all tools enabled |
| `plan` | primary | read-only | Planning and analysis, no file modifications |

---

## Built-in Subagents

| Agent | Mode | Tools | Description |
|-------|------|-------|-------------|
| `general` | subagent | all (except todo) | Multi-step tasks, parallel work |
| `explore` | subagent | read-only | Fast read-only codebase exploration |
| `scout` | subagent | read-only + fetch | External docs and dependency research |

---

## Custom Subagents

### readiness-analyzer

- **Source:** Migrated from Cursor subagent
- **Mode:** subagent
- **Permission:** edit, bash, read, glob, grep
- **Model:** Inherits from global config
- **Description:** Analyze any API for AI agent compatibility. Scans OpenAPI specs across 8 pillars (48 checks), scores agent-readiness, and provides fix recommendations.
- **Triggers:** "Is my API agent-ready?", "Scan my API", "Analyze my spec"

### pr-babysitter

- **Source:** Migrated from Cursor `babysit` skill
- **Mode:** subagent
- **Permission:** bash, read, glob, grep
- **Model:** Inherits from global config
- **Description:** Keep a PR merge-ready by triaging comments, resolving conflicts, and fixing CI in a loop.
- **Workflow:**
  1. Resolve merge conflicts intelligently
  2. Review and resolve active comments (including Bugbot)
  3. Fix CI issues within PR scope
  4. Push fixes and re-watch CI until mergeable + green

### split-to-prs

- **Source:** Migrated from Cursor `split-to-prs` skill
- **Mode:** subagent
- **Permission:** bash, read, glob, grep
- **Model:** Inherits from global config
- **Description:** Split a large change into multiple PRs with proper commit boundaries.
- **Use case:** When a change is too large for a single PR

---

## Agent Configuration

All custom agents configured in `~/.config/opencode/opencode.json`:

```json
{
  "agent": {
    "readiness-analyzer": {
      "description": "...",
      "mode": "subagent",
      "permission": { "edit": "allow", "bash": "allow", "read": "allow", "glob": "allow", "grep": "allow" }
    },
    "pr-babysitter": {
      "description": "...",
      "mode": "subagent",
      "permission": { "bash": "allow", "read": "allow", "glob": "allow", "grep": "allow" }
    },
    "split-to-prs": {
      "description": "...",
      "mode": "subagent",
      "permission": { "bash": "allow", "read": "allow", "glob": "allow", "grep": "allow" }
    }
  }
}
```

---

## Related

- [[01-Architecture/Agent-System|Agent System]]
- [[03-Skills/Skills-Index|Skills Index]]
