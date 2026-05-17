# Quick Start Guide

One-page setup checklist for the consolidated OpenCode configuration.

---

## Prerequisites

- [ ] OpenCode installed and working
- [ ] Node.js installed (for npx MCP servers)
- [ ] GitHub account with token
- [ ] Postman account
- [ ] Atlassian account (Jira + Confluence)

---

## Step 1: Verify Directory Structure

```bash
mkdir -p ~/.config/opencode/{skills,agents,commands}
```

## Step 2: Move Existing Skills

```bash
# Move from .agents
mv ~/.agents/skills/* ~/.config/opencode/skills/

# Move from .claude (compatibility)
mv ~/.claude/skills/* ~/.config/opencode/skills/
```

## Step 3: Create New Components

```bash
# Create 3 custom agents in ~/.config/opencode/agents/
# Create 8 commands in ~/.config/opencode/commands/
# Create 14 new skills in ~/.config/opencode/skills/
```

## Step 4: Update Config

Update `~/.config/opencode/opencode.json` with:
- MCP servers (add postman, atlassian)
- Instructions (add redis rules glob)
- Agents (add 3 custom subagents)
- Permissions (allow all tools)

## Step 5: Authenticate MCP Servers

```bash
opencode mcp auth postman
opencode mcp auth atlassian
```

## Step 6: Verify

```bash
opencode mcp list
# Should show 5 servers (3 local + 2 remote)
```

## Step 7: Test

```bash
opencode
# Try: /postman-setup
# Try: Trigger obsidian-vault skill
# Try: Trigger github-triage skill
```

## Step 8: Clean Up

```bash
# After verifying everything works:
rmdir ~/.agents/skills/
rmdir ~/.claude/skills/
rmdir ~/.cursor/skills-cursor/
```

---

## Post-Setup

- Review [[03-Skills/Skills-Index|Skills Index]] for available skills.
- Review [[03-Skills/Agent-Catalog|Agent Catalog]] for available agents.
- Review [[03-Skills/Command-Catalog|Command Catalog]] for available commands.
- Review [[01-Architecture/System-Architecture|System Architecture]] for full picture.

---

## Related

- [[05-Reference/Reference-Index|Reference Index]]
- [[04-Updates/Changelog|Changelog]]
