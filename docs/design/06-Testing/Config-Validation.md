# Config Validation

**Last Updated:** 2026-05-17

---

## Overview

Validates the structural integrity of all OpenCode configuration files before they reach CI or production.

---

## Validation Scripts

### `scripts/validate-config.sh`

Master validation script. Runs all checks in sequence.

```bash
bash scripts/validate-config.sh
```

**Exit codes:**
- `0` — All checks pass
- `1` — One or more checks fail

### `scripts/secrets-scan.sh`

Scans all tracked files for leaked secrets.

```bash
bash scripts/secrets-scan.sh
```

**Exit codes:**
- `0` — No secrets found
- `1` — Secrets detected (lists files)

---

## Validation Rules

### opencode.json

| Check | Rule | Severity |
|---|---|---|
| Valid JSON | Must parse without errors | Critical |
| Schema reference | Must have `$schema` field | Warning |
| MCP section | Must have at least 1 server | Critical |
| Agent section | Valid agent configs if present | Critical |
| Permission section | Must exist | Critical |
| Instructions section | Must exist | Critical |
| No secrets | No raw tokens in environment values | Critical |

### Skill Files (SKILL.md)

| Check | Rule | Severity |
|---|---|---|
| File exists | `skills/{name}/SKILL.md` must exist | Critical |
| Frontmatter | Must have `---` delimiters | Critical |
| Name field | Required, must match directory name | Critical |
| Description field | Required, 1-1024 characters | Critical |
| Naming convention | `^[a-z0-9]+(-[a-z0-9]+)*$` | Warning |
| No consecutive hyphens | `--` not allowed | Warning |
| No leading/trailing hyphens | `-name` or `name-` invalid | Warning |

### Agent Files (.md)

| Check | Rule | Severity |
|---|---|---|
| File exists | `agents/{name}.md` must exist | Critical |
| Description | Must have description in frontmatter or content | Critical |
| Naming convention | Lowercase, hyphens only | Warning |

### Command Files (.md)

| Check | Rule | Severity |
|---|---|---|
| File exists | `commands/{name}.md` must exist | Critical |
| Template or description | Must have at least one | Critical |
| Naming convention | Lowercase, hyphens only | Warning |

### Instructions Globs

| Check | Rule | Severity |
|---|---|---|
| Glob resolves | Each glob pattern must match ≥1 file | Critical |
| No broken globs | Patterns like `nonexistent/*.md` fail | Critical |

### Cross-Reference Checks

| Check | Rule | Severity |
|---|---|---|
| No duplicate names | Skill/agent/command names must be unique | Critical |
| No broken symlinks | All symlinks must resolve | Warning |
| File permissions | Executable scripts must have +x | Warning |

---

## Secrets Scan Patterns

| Pattern | Regex | Examples |
|---|---|---|
| GitHub token | `ghp_[a-zA-Z0-9]{36}` | `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` |
| Atlassian token | `ATATT[a-zA-Z0-9_-]+` | `ATATTxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` |
| OpenAI key | `sk-[a-zA-Z0-9]{20,}` | `sk-proj-abc123...` |
| Google key | `AIza[a-zA-Z0-9_-]{35}` | `AIzaSyA1234567890abcdef...` |
| AWS key | `AKIA[0-9A-Z]{16}` | `AKIAIOSFODNN7EXAMPLE` |
| JWT token | `eyJ[a-zA-Z0-9_-]+\.eyJ` | `eyJhbGciOiJIUzI1NiJ9.eyJzdWIi...` |

**Skipped paths:** `node_modules/`, `.git/`, `*.lock`, `tests/conformance/results/`, `tests/evals/traces/`, `.env.example`

---

## Running Validation

### Full Validation

```bash
cd ~/Desktop/projects/opencode-config
bash scripts/validate-config.sh
```

### Secrets Scan Only

```bash
bash scripts/secrets-scan.sh
```

### CI Integration

In `validate-config.yml`:

```yaml
secrets-scan:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Scan for secrets
      run: bash scripts/secrets-scan.sh

config-validation:
  runs-on: ubuntu-latest
  needs: secrets-scan
  steps:
    - uses: actions/checkout@v4
    - name: Validate configuration
      run: bash scripts/validate-config.sh
```

---

## Adding New Validation Rules

1. Edit `scripts/validate-config.sh`
2. Add new check function
3. Add to validation sequence
4. Test locally: `bash scripts/validate-config.sh`
5. Commit with description of new rule

---

## Related

- [[06-Testing/Test-Strategy|Test Strategy]]
- [[06-Testing/MCP-Conformance|MCP Conformance]]
- [[07-Observability/Audit-Trail|Audit Trail]]
