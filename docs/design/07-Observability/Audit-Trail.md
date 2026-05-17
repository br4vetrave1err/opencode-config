# Audit Trail

**Last Updated:** 2026-05-17

---

## Overview

Comprehensive audit trail for all changes to the OpenCode agent configuration. Provides traceability, compliance, and incident response capabilities.

---

## Audit Sources

| Source | What It Tracks | Retention |
|---|---|---|
| Git history | All file changes with author, timestamp, commit message | Indefinite |
| Changelog | Human-readable change summaries | Indefinite |
| MCP conformance results | Server compliance over time | 90 days |
| Eval traces | Agent behavior traces | 30 days |
| Drift reports | Configuration sync status | 30 days |
| CI/CD logs | Build and test results | 90 days |

---

## Git History

All changes are tracked via git:

```bash
# View full history
git log --oneline

# View changes to specific file
git log --follow -- skills/postman-knowledge/SKILL.md

# View who changed what
git blame skills/postman-knowledge/SKILL.md

# View changes between versions
git diff HEAD~5..HEAD -- opencode.json
```

---

## Changelog

Human-readable change summaries in `docs/design/04-Updates/Changelog.md`:

```markdown
## 2026-05-17: Consolidation — Phase 4 (Testing & Observability Framework)

### What Changed
- Designed 3-layer testing framework
- Created GitHub Actions CI/CD pipeline
- ...

### Decisions
- Evals run locally only
- MCP conformance tests core scenarios only
- ...
```

---

## MCP Conformance History

Conformance results are saved as JSON artifacts:

```
tests/conformance/results/
├── postman-2026-05-17.json
├── atlassian-2026-05-17.json
├── confluence-2026-05-17.json
├── obsidian-2026-05-17.json
└── github-2026-05-17.json
```

Track compliance trends over time:

```bash
# View latest results
cat tests/conformance/results/postman-*.json | jq '.summary'

# Compare with previous run
diff <(cat tests/conformance/results/postman-2026-05-16.json) \
     <(cat tests/conformance/results/postman-2026-05-17.json)
```

---

## Eval Trace History

Eval traces capture agent behavior:

```
tests/evals/traces/
├── ra-001-trial-1-2026-05-17.json
├── ra-001-trial-2-2026-05-17.json
├── ra-001-trial-3-2026-05-17.json
├── pb-001-trial-1-2026-05-17.json
└── ...
```

Trace contents:
- Agent name and prompt
- Tool call sequence with timing
- Behavior validation results
- Content validation results
- Pass/fail status

---

## Incident Response

When an issue is detected:

### 1. Identify the Change

```bash
# Find when the issue started
git log --all --oneline -- skills/{problematic-skill}/

# View the change
git show <commit-hash>
```

### 2. Review Traces

```bash
# Check eval traces for behavior changes
cat tests/evals/traces/ra-001-trial-*.json | jq '.tool_calls'

# Check conformance results for MCP issues
cat tests/conformance/results/postman-*.json | jq '.scenarios[] | select(.status == "FAIL")'
```

### 3. Rollback if Needed

```bash
# Revert to previous version
git checkout <previous-commit> -- skills/{problematic-skill}/
cp -r skills/{problematic-skill}/ ~/.config/opencode/skills/
```

### 4. Document the Incident

Add to changelog:

```markdown
## 2026-05-17: Incident — Skill Regression

### Issue
postman-knowledge skill failed to discover workspaces after update.

### Root Cause
Tool description changed from "List workspaces" to "List your workspaces", breaking pattern matching.

### Resolution
Reverted tool description, added regression test.

### Prevention
Added smoke test for workspace discovery.
```

---

## Compliance

### What We Track

| Requirement | How We Meet It |
|---|---|
| Change authorization | Git commits require review (PR process) |
| Change traceability | Git history + changelog |
| Change reversibility | Git revert/checkout |
| Secret protection | Secrets scan + .gitignore + env vars |
| Access control | GitHub repo permissions |
| Audit log retention | Git history (indefinite) + CI logs (90 days) |

### Secret Protection

1. **Prevention:** `.gitignore` excludes `.env` and secret files
2. **Detection:** `scripts/secrets-scan.sh` runs on every commit
3. **Response:** If secret leaked, rotate immediately and scrub git history

---

## Retention Policy

| Data Type | Retention | Cleanup Method |
|---|---|---|
| Git history | Indefinite | N/A |
| Changelog | Indefinite | N/A |
| MCP conformance results | 90 days | `scripts/cleanup-conformance.sh` |
| Eval traces | 30 days | `scripts/cleanup-traces.sh` |
| Drift reports | 30 days | Log rotation |
| CI/CD logs | 90 days | GitHub auto-cleanup |

---

## Related

- [[07-Observability/Change-Log|Change Log]]
- [[07-Observability/Drift-Detection|Drift Detection]]
- [[06-Testing/Test-Strategy|Test Strategy]]
