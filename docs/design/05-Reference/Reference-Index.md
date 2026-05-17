# Reference Files

Quick-reference files for common tasks and configurations.

---

## Available Files

- [[Opencode-Agent-Config-Project|Project Details]] — Full project context, source paths, skill lists
- [[Quick-Start|Quick Start Guide]] — One-page setup checklist
- [[Authentication-Setup|MCP Authentication]] — OAuth and PAT setup commands

---

## Quick Commands Reference

```bash
# MCP
opencode mcp list                    # List all servers
opencode mcp auth postman            # Authenticate Postman
opencode mcp auth atlassian          # Authenticate Atlassian
opencode mcp debug atlassian         # Debug connection

# OpenCode
opencode --help                      # General help
opencode config                      # View/edit config

# File Operations
mv ~/.agents/skills/* ~/.config/opencode/skills/
mv ~/.claude/skills/* ~/.config/opencode/skills/
```

---

## Configuration Paths

| Component | Path |
|-----------|------|
| Main config | `~/.config/opencode/opencode.json` |
| Skills | `~/.config/opencode/skills/` |
| Agents | `~/.config/opencode/agents/` |
| Commands | `~/.config/opencode/commands/` |
| AGENTS.md | `~/.config/opencode/AGENTS.md` |

---

## Related

- [[00-Overview|Overview]]
- [[03-Skills/Skills-Index|Skills Index]]
