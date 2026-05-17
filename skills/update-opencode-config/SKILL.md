---
name: update-opencode-config
description: Edit opencode.json and tui.json configuration files
---

# Update OpenCode Config

Edit OpenCode configuration files (`opencode.json`, `tui.json`) safely.

## Config Files

### opencode.json

Location: `~/.config/opencode/opencode.json`

Key sections:
- `$schema`: JSON schema reference
- `mcp`: MCP server configurations
- `agent`: Custom agent definitions
- `permission`: Tool permission rules
- `instructions`: Glob patterns for rule files

### tui.json

Location: `~/.config/opencode/tui.json`

Key sections:
- Theme settings
- Keybindings
- Display preferences

## Workflow

1. **Read current config**
   - Read the existing file first
   - Understand current structure

2. **Plan changes**
   - Identify exact fields to add/modify/remove
   - Ensure valid JSON structure

3. **Apply changes**
   - Use precise edits (not full file rewrite)
   - Preserve existing formatting
   - Validate JSON after edit

4. **Verify**
   - Parse the file to confirm valid JSON
   - Check that changes are correct
   - Test by running OpenCode

## Common Changes

### Add MCP Server
```json
{
  "mcp": {
    "new-server": {
      "type": "local",
      "command": ["npx", "-y", "package@latest"],
      "enabled": true
    }
  }
}
```

### Add Agent
```json
{
  "agent": {
    "my-agent": {
      "description": "What it does",
      "mode": "subagent",
      "permission": { "read": "allow", "bash": "allow" }
    }
  }
}
```

### Add Instructions Glob
```json
{
  "instructions": {
    "my-rules": ["path/to/rules/*.md"]
  }
}
```

## Safety Rules

- Always read before editing
- Never remove existing entries without confirmation
- Validate JSON after every edit
- Backup config before major changes
