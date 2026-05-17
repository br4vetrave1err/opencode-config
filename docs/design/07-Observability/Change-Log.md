# Change Log

**Last Updated:** 2026-05-17

---

## Overview

Automated changelog generation from git commits. Tracks all changes to the OpenCode agent configuration.

---

## Format

```markdown
## YYYY-MM-DD: Component — Description

### What Changed
- Bullet list of changes

### New Components
- New files, scripts, workflows

### Modified Components
- Updated files

### Removed Components
- Deleted files

### Metrics
- Skills: X
- Tests: Y/Z passing
- MCP: A/B conformance grade
```

---

## Auto-Generation

`scripts/generate-changelog.sh` parses git commits and generates changelog entries:

```bash
bash scripts/generate-changelog.sh
```

**Process:**
1. Find last changelog entry date in `docs/design/04-Updates/Changelog.md`
2. Parse git log since that date
3. Categorize commits by component:
   - `skills:` → skill additions/modifications
   - `agents:` → agent changes
   - `commands:` → command changes
   - `config:` → opencode.json, tui.json, AGENTS.md
   - `docs:` → documentation changes
   - `tests:` → test additions/fixes
   - `infra:` → CI/CD, scripts
4. Generate formatted entry
5. Append to Changelog.md
6. Commit if changes made

---

## Commit Message Conventions

For best changelog generation, use conventional commits:

```
feat(skills): add redis-development skill
fix(config): update instructions glob path
docs(testing): add test strategy documentation
infra(ci): add validate-config workflow
test(playwright): add 36 browser tests
```

**Types:**
- `feat` — New feature/component
- `fix` — Bug fix
- `docs` — Documentation
- `infra` — Infrastructure (CI/CD, scripts)
- `test` — Test additions/changes
- `refactor` — Code restructuring
- `chore` — Maintenance tasks

**Scopes:**
- `skills` — Skill additions/modifications
- `agents` — Agent changes
- `commands` — Command changes
- `config` — Config file changes
- `mcp` — MCP server changes
- `ci` — CI/CD changes
- `docs` — Documentation

---

## Manual Entries

For changes not captured by commits (e.g., external updates):

```markdown
## 2026-05-17: External — Postman MCP Update

### What Changed
- Postman MCP server updated to v2.1
- New tools added: postman_searchFlows, postman_getFlow

### Impact
- postman-knowledge skill now has access to 50+ tools (was 45)
- No breaking changes to existing tool signatures
```

---

## CI Integration

In `sync-and-log.yml`:

```yaml
changelog:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Generate changelog
      run: bash scripts/generate-changelog.sh
    - name: Commit changes
      run: |
        git add docs/design/04-Updates/Changelog.md
        git commit -m "docs: update changelog" || echo "No changes"
        git push
```

---

## Cron Schedule

Changelog generation runs at 10 PM daily:

```bash
0 22 * * * /path/to/scripts/generate-changelog.sh >> /tmp/opencode-changelog.log 2>&1
```

---

## Related

- [[07-Observability/Drift-Detection|Drift Detection]]
- [[07-Observability/Audit-Trail|Audit Trail]]
- [[06-Testing/Test-Strategy|Test Strategy]]
