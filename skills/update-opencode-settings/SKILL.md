---
name: update-opencode-settings
description: Update OpenCode TUI settings (theme, keybinds, scroll)
---

# Update OpenCode Settings

Update OpenCode TUI settings for theme, keybindings, and display preferences.

## Settings File

Location: `~/.config/opencode/tui.json`

## Available Settings

### Theme

```json
{
  "theme": "dark"
}
```

Options: `dark`, `light`, or custom theme name.

### Keybindings

```json
{
  "keybindings": {
    "submit": "Enter",
    "new_line": "Shift+Enter",
    "autocomplete": "Tab"
  }
}
```

### Display

```json
{
  "display": {
    "scrollback": 10000,
    "max_output_lines": 500,
    "show_token_count": true
  }
}
```

## Workflow

1. **Read current settings**
   - Read `tui.json` to understand current config

2. **Identify changes**
   - What setting does the user want to change?
   - What are valid values?

3. **Apply changes**
   - Edit only the relevant fields
   - Preserve existing settings

4. **Verify**
   - Confirm valid JSON
   - Restart OpenCode TUI to apply

## Common Requests

- "Change theme" → Update `theme` field
- "Change keybinding" → Update `keybindings` field
- "Increase scrollback" → Update `display.scrollback`
- "Hide token count" → Set `display.show_token_count` to false
