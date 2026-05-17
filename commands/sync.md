---
name: sync
description: Auto-sync configs to git repo, update documentation, and push changes
---

# /sync — Automated Config Sync & Documentation Update

## Purpose

Automatically detects changes in `~/.config/opencode/`, syncs to the git repo, updates all documentation, and optionally pushes to remote.

## Usage

```
/sync              # Detect changes, sync, update docs, commit (no push)
/sync --push       # Same as above + push to remote
/sync --dry-run    # Show what would change without making changes
/sync --local DIR  # Use custom local config directory
/sync --repo DIR   # Use custom git repo directory
```

## What It Does

1. **Detect Changes** — Compares local config with git repo
   - New/modified/deleted files in agents/, commands/, skills/, scripts/, plugins/
   - Changes to opencode.json, tui.json, AGENTS.md
   - Reports exact differences

2. **Sync to Repo** — Copies files with secret sanitization
   - Uses `sync-to-repo.sh` for secure file transfer
   - Redacts tokens, passwords, API keys from opencode.json

3. **Update Documentation** — Intelligently updates all docs
   - `00-Overview.md` — Current counts and status
   - `03-Skills/Skills-Index.md` — Skill count
   - `03-Skills/Agent-Catalog.md` — Agent count
   - `03-Skills/Command-Catalog.md` — Command count
   - `03-Skills/MCP-Catalog.md` — MCP server count
   - `04-Updates/Changelog.md` — Appends today's changes
   - Syncs docs/design/ → Obsidian vault

4. **Commit & Push** — Creates commit with change summary
   - Auto-generated commit message with timestamp
   - Push only if `--push` flag is provided

## Decision Logic

The agent automatically decides what to update based on detected changes:

| Change Detected | Documentation Updated |
|----------------|----------------------|
| New skill | Skills Index, Skill Catalog, Overview, Changelog |
| New agent | Agent Catalog, Overview, Changelog |
| New command | Command Catalog, Overview, Changelog |
| opencode.json change | MCP Catalog, Overview, Changelog |
| Any config change | All catalogs, Overview, Changelog, Obsidian |

## Examples

```bash
# Quick sync (no push)
/sync

# Full sync with push
/sync --push

# Preview changes
/sync --dry-run

# Custom directories
/sync --local ~/.config/opencode --repo ~/projects/opencode-config --push
```

## Exit Codes

- `0` — Success (changes synced or no changes detected)
- `1` — Error (missing directories, invalid options)

## Related Scripts

- `scripts/sync-to-repo.sh` — File sync with secret sanitization
- `scripts/update-docs.sh` — Documentation updater
- `scripts/detect-drift.sh` — Drift detection between local and repo
