# Drift Detection

**Last Updated:** 2026-05-17

---

## Overview

Detects configuration drift between the local OpenCode config (`~/.config/opencode/`) and the git repository (`~/Desktop/projects/opencode-config/`).

---

## What Is Drift?

Drift occurs when the local configuration diverges from what's tracked in git:

| Drift Type | Example | Risk |
|---|---|---|
| Modified file | Local `opencode.json` has new MCP server not in git | Lost changes if repo is pulled |
| New file | New skill added locally but not committed | Not backed up, not shared |
| Deleted file | Skill removed locally but still in git | Inconsistent state |
| Permission change | Script lost execute permission | Broken automation |

---

## Detection Method

`scripts/detect-drift.sh` uses checksum comparison:

```bash
bash scripts/detect-drift.sh
```

**Process:**
1. List all files in `~/.config/opencode/` (excluding temp/lock files)
2. List all files in git repo (excluding gitignored files)
3. Compare file counts
4. For each file present in both:
   - Compute md5sum of local file
   - Compute md5sum of repo file
   - Compare checksums
5. Identify:
   - Files only in local (new, uncommitted)
   - Files only in repo (deleted locally)
   - Files with different checksums (modified)

**Output:**
```
DRIFT DETECTED
  Modified: 3 files
    - skills/postman-knowledge/SKILL.md
    - opencode.json
    - AGENTS.md
  Added: 1 file
    - skills/new-skill/SKILL.md
  Deleted: 0 files
  Sync Status: OUT OF SYNC
```

**Exit codes:**
- `0` — No drift (in sync)
- `1` — Drift detected

---

## Excluded Files

These files are excluded from drift detection:

| Pattern | Reason |
|---|---|
| `node_modules/` | Generated, not tracked |
| `.git/` | Git metadata |
| `*.log` | Temporary logs |
| `tests/conformance/results/` | Test artifacts |
| `tests/evals/traces/` | Eval artifacts |
| `.env` | Secrets (gitignored) |
| `package-lock.json` | Generated |

---

## Remediation Workflow

When drift is detected:

1. **Review drift report**
   ```bash
   bash scripts/detect-drift.sh
   ```

2. **For modified files:**
   - If local changes are intentional → commit to repo
   - If local changes are accidental → restore from repo

3. **For new files:**
   - If should be tracked → add to repo
   - If should not be tracked → add to `.gitignore`

4. **For deleted files:**
   - If deletion was intentional → commit deletion
   - If deletion was accidental → restore from repo

5. **Verify sync:**
   ```bash
   bash scripts/detect-drift.sh
   # Should output: "IN SYNC"
   ```

---

## CI Integration

In `sync-and-log.yml`:

```yaml
drift-check:
  runs-on: ubuntu-latest
  needs: changelog
  steps:
    - uses: actions/checkout@v4
    - name: Check drift
      run: bash scripts/detect-drift.sh || true
    - name: Post drift report
      if: failure()
      run: |
        # Post drift report as commit comment
        gh api repos/${{ github.repository }}/commits/${{ github.sha }}/comments \
          -f body="⚠️ Drift detected: $(bash scripts/detect-drift.sh 2>&1)"
```

---

## Cron Schedule

Drift detection runs at 10 PM daily:

```bash
0 22 * * * /path/to/scripts/detect-drift.sh >> /tmp/opencode-drift.log 2>&1
```

---

## Metrics

| Metric | Target | Alert Threshold |
|---|---|---|
| Drift frequency | < 1 per week | > 3 per week |
| Time to remediate | < 24 hours | > 48 hours |
| False positive rate | < 5% | > 10% |

---

## Related

- [[07-Observability/Change-Log|Change Log]]
- [[07-Observability/Audit-Trail|Audit Trail]]
- [[06-Testing/Test-Strategy|Test Strategy]]
