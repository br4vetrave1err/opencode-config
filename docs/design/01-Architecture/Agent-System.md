# Agent System

## Agent Types

| Type | Description | Invocation |
|------|-------------|------------|
| Primary | Main conversation agent | Tab key to cycle |
| Subagent | Specialized assistant | @mention or auto-delegated |

---

## Built-in Agents

### Primary Agents

| Agent | Tools | Description |
|-------|-------|-------------|
| `build` | all | Default development agent, all tools enabled |
| `plan` | read-only | Planning and analysis, no file modifications |

### Subagents

| Agent | Tools | Description |
|-------|-------|-------------|
| `general` | all (except todo) | Multi-step tasks, parallel work |
| `explore` | read-only | Fast codebase exploration |
| `scout` | read-only + fetch | External docs and dependency research |

---

## Custom Agents

| Agent | Type | Permission | Description |
|-------|------|------------|-------------|
| `readiness-analyzer` | subagent | edit, bash, read, glob, grep | API agent-readiness (8 pillars, 48 checks) |
| `pr-babysitter` | subagent | bash, read, glob, grep | PR merge-readiness loop |
| `split-to-prs` | subagent | bash, read, glob, grep | Split changes into PRs |

**Model:** No per-agent model override — inherits from global OpenCode config (auto-selected via `/connect` or `opencode.json` `model` field).

---

## Agent Configuration Format

```markdown
---
description: "What this agent does and when to use it"
mode: subagent          # primary | subagent | all
# model: anthropic/...  # Optional — omit to inherit from global config
temperature: 0.3
steps: 50               # max agentic iterations
permission:
  edit: allow
  bash: allow
  read: allow
  glob: allow
  grep: allow
  task:
    "*": deny
    "orchestrator-*": allow
color: accent
---

System prompt / instructions for this agent...
```

---

## Agent Files Location

| Scope | Path |
|-------|------|
| Global | `~/.config/opencode/agents/<name>.md` |
| Project | `<project>/.opencode/agents/<name>.md` |

---

## Related

- [[01-Architecture/System-Overview|System Overview]]
- [[03-Skills/Agent-Catalog|Agent Catalog]]
- [[01-Architecture/Permission-System|Permission System]]
