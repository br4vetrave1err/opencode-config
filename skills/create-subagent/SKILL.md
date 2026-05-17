---
name: create-subagent
description: Create custom subagent .md files with system prompts
---

# Create Subagent

Create custom subagent files that define specialized agents for specific tasks.

## Subagent File Format

Subagents are markdown files in the `agents/` directory:

```markdown
# Agent Name

## Description
What this agent does and when to use it.

## Workflow
1. Step one
2. Step two
3. Step three

## Rules
- Rule 1
- Rule 2

## Output Format
How the agent should format its response.
```

## Where to Create Subagents

- **Project-level:** `.opencode/agents/<agent-name>.md`
- **Global:** `~/.config/opencode/agents/<agent-name>.md`

## Naming Convention

- File: kebab-case with `.md` extension (`readiness-analyzer.md`)
- No spaces or special characters

## Subagent Configuration

Subagents are registered in `opencode.json`:

```json
{
  "agent": {
    "my-agent": {
      "description": "What this agent does",
      "mode": "subagent",
      "permission": {
        "bash": "allow",
        "read": "allow",
        "glob": "allow",
        "grep": "allow"
      }
    }
  }
}
```

## Permission Levels

- `allow`: Agent can use this tool freely
- `deny`: Agent cannot use this tool
- `ask`: Agent must ask user before using

## When to Create Subagents

- Recurring multi-step workflow
- Specialized analysis task
- Automated monitoring loop
- Task requiring specific tool permissions

## Workflow

1. Define the agent's purpose and workflow
2. Create the `.md` file in `~/.config/opencode/agents/`
3. Register in `opencode.json` with appropriate permissions
4. Test by invoking the subagent
