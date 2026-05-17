# Test Strategy

**Last Updated:** 2026-05-17
**Framework Version:** 1.0.0

---

## Overview

3-layer testing framework for OpenCode agent configuration, following 2026 community standards for AI agent testing.

```
┌─────────────────────────────────────────────────────────────┐
│  Layer 3: Agent Evals (Local Only)                          │
│  - Real OpenCode sessions                                   │
│  - YAML-based eval specs                                    │
│  - 17 scenarios × 3 trials = 51 runs                       │
│  - Behavior assertions + content expectations               │
│  - Tool trace capture                                       │
│  Run: Manual (workflow_dispatch)                            │
├─────────────────────────────────────────────────────────────┤
│  Layer 2: MCP Conformance + Config Validation (CI)          │
│  - MCP server conformance (5 servers, core scenarios)       │
│  - Config schema validation                                 │
│  - Skill smoke tests (12 skills)                            │
│  - Drift detection                                          │
│  Run: On every push/PR                                      │
├─────────────────────────────────────────────────────────────┤
│  Layer 1: Unit & Smoke Tests (CI)                           │
│  - Secrets scanning (regex patterns)                        │
│  - Config validation (JSON schema + frontmatter)            │
│  - Playwright CLI tests (36 tests)                          │
│  Run: On every push/PR                                      │
└─────────────────────────────────────────────────────────────┘
```

---

## Layer 1: Unit & Smoke Tests

### Purpose
Fast, deterministic checks that catch obvious issues before they reach CI.

### Components

| Script | Purpose | Time | Fail Condition |
|---|---|---|---|
| `scripts/secrets-scan.sh` | Detect leaked secrets | ~10s | Any secret pattern found |
| `scripts/validate-config.sh` | Validate config structure | ~30s | Any validation fails |
| `skills/playwright-cli/tests/run-tests.sh` | Browser automation tests | ~5 min | Any test fails |
| `skills/*/tests/smoke.sh` | External service connectivity | ~3 min total | Service unreachable |

### Secrets Scan Patterns

| Pattern | Example | Severity |
|---|---|---|
| GitHub token | `ghp_[a-zA-Z0-9]{36}` | Critical |
| Atlassian token | `ATATT[a-zA-Z0-9_-]+` | Critical |
| OpenAI key | `sk-[a-zA-Z0-9]{20,}` | Critical |
| Google key | `AIza[a-zA-Z0-9_-]{35}` | Critical |
| AWS key | `AKIA[0-9A-Z]{16}` | Critical |
| JWT token | `eyJ[a-zA-Z0-9_-]+\.eyJ` | Critical |

### Config Validation Checks

1. `opencode.json` — valid JSON, `$schema` reference, required fields
2. All 37 skills — `SKILL.md` exists, frontmatter has `name` + `description`
3. All 3 agents — `.md` file exists, has description
4. All 8 commands — `.md` file exists, has `template` or `description`
5. Instructions globs — all patterns resolve to at least 1 file
6. No duplicate skill/agent/command names
7. No broken symlinks

### Quality Gates

| Check | Threshold | Action |
|---|---|---|
| Secrets scan | 0 findings | Block merge |
| Config validation | 100% pass | Block merge |
| Playwright tests | 36/36 | Block merge |
| Skill smoke tests | 12/12 | Block merge |

---

## Layer 2: MCP Conformance & Config Validation

### Purpose
Validate MCP server protocol compliance and detect configuration drift.

### MCP Conformance

Uses `@modelcontextprotocol/conformance` (official MCP framework).

| Server | Type | Scenarios | Est. Time |
|---|---|---|---|
| postman | remote (HTTP) | server-initialize, tools-list, tools-call-simple-text | ~1 min |
| atlassian | remote (HTTP) | server-initialize, tools-list, tools-call-simple-text | ~1 min |
| confluence | local (stdio) | server-initialize, tools-list, tools-call-simple-text | ~1 min |
| obsidian | local (stdio) | server-initialize, tools-list, tools-call-simple-text | ~1 min |
| github | local (stdio) | server-initialize, tools-list, tools-call-simple-text | ~1 min |

**Total: ~5 min**

### Expected Failures Baseline

`tests/conformance/expected-failures.yaml` tracks known failures:
- Local servers may fail in CI due to auth requirements
- CI passes if failures match baseline
- New failures trigger investigation

### Drift Detection

`scripts/detect-drift.sh` compares `~/.config/opencode/` vs git repo:
- File count mismatch
- File checksum differences (md5sum)
- New files in local not in repo
- Modified files not committed

**Output:** `DRIFT: 3 files modified, 1 file added, 0 files deleted`

**Schedule:** 10 PM daily via cron

---

## Layer 3: Agent Evals (Local Only)

### Purpose
Validate agent behavior through real OpenCode sessions.

### Why Local Only

- Requires `opencode` CLI with MCP auth tokens
- Token costs ($0.50-2.00 per eval run)
- LLM latency (30-60 min for full suite)
- Not suitable for CI (no auth, cost, time)

### Eval Spec Format

```yaml
id: ra-001
name: "Readiness Analyzer - Postman MCP Scan"
agent: readiness-analyzer
category: developer
trials: 3
prompts:
  - text: "Analyze the Postman MCP server tools for agent compatibility"
behavior:
  mustUseTools: [read, grep]
  minToolCalls: 2
  maxToolCalls: 20
  requiresApproval: false
contentExpectations:
  - mustContain: ["compatibility", "score"]
  - mustNotContain: ["error", "failed"]
timeout: 300s
```

### Eval Specs

| File | Agent | Scenarios | Total Runs |
|---|---|---|---|
| `readiness-analyzer.eval.yaml` | readiness-analyzer | 3 | 9 |
| `pr-babysitter.eval.yaml` | pr-babysitter | 3 | 9 |
| `split-to-prs.eval.yaml` | split-to-prs | 3 | 9 |
| `postman-workflow.eval.yaml` | build | 5 | 15 |
| `redis-config.eval.yaml` | build | 3 | 9 |
| **Total** | | **17** | **51** |

### Trace Format

Each eval run produces a JSON trace:

```json
{
  "eval_id": "ra-001",
  "trial": 1,
  "agent": "readiness-analyzer",
  "prompt": "Analyze the Postman MCP server tools...",
  "tool_calls": [
    {"tool": "read", "args": {...}, "duration_ms": 120},
    {"tool": "grep", "args": {...}, "duration_ms": 85}
  ],
  "behavior": {
    "mustUseTools": {"read": true, "grep": true},
    "tool_call_count": 8,
    "requiresApproval": false
  },
  "content": {
    "mustContain": {"compatibility": true, "score": true},
    "mustNotContain": {"error": false, "failed": false}
  },
  "result": "PASS",
  "duration_ms": 45000
}
```

### Quality Gates

| Metric | Threshold | Action |
|---|---|---|
| Pass rate | ≥ 80% | Investigate failures |
| Tool accuracy | ≥ 90% | Review eval spec |
| Avg latency | < 60s per scenario | Optimize prompts |

---

## CI/CD Integration

### Workflows

| Workflow | Trigger | Jobs | Est. Time |
|---|---|---|---|
| `validate-config.yml` | push, PR | secrets, config, conformance, smoke, playwright | 10-15 min |
| `sync-and-log.yml` | push to main | changelog, badges, drift | 2-3 min |
| `agent-evals.yml` | workflow_dispatch | run-evals | 30-60 min |

### Pipeline Flow

```
push/PR
  │
  ├── secrets-scan (fail fast) ── FAIL → block merge
  │
  ├── config-validation ── FAIL → block merge
  │
  ├── mcp-conformance ── FAIL (if new failures) → block merge
  │
  ├── skill-smoke-tests (parallel) ── FAIL → block merge
  │
  └── playwright-tests ── FAIL → block merge
        │
        └── ALL PASS → merge allowed

push to main
  │
  ├── changelog (auto-generate)
  ├── badge-update (README shields)
  └── drift-check (post report)
```

---

## Maintenance

### Adding New Tests

1. **Unit/smoke test** — Add to `scripts/` or `skills/{name}/tests/`
2. **Conformance test** — Update `tests/conformance/run-all.sh`
3. **Eval spec** — Add YAML file to `tests/evals/agents/` or `tests/evals/workflows/`

### Updating Baselines

When MCP servers update and conformance results change:
1. Run `tests/conformance/run-all.sh` locally
2. Review new failures
3. Update `tests/conformance/expected-failures.yaml`
4. Commit with explanation

### Trace Retention

- Keep last 10 eval runs in `tests/evals/traces/`
- Auto-cleanup via `scripts/cleanup-traces.sh` (run weekly)
- Older traces archived to `tests/evals/traces/archive/`

---

## Related

- [[06-Testing/MCP-Conformance|MCP Conformance]]
- [[06-Testing/Config-Validation|Config Validation]]
- [[06-Testing/Eval-Framework|Eval Framework]]
- [[07-Observability/Drift-Detection|Drift Detection]]
- [[07-Observability/Audit-Trail|Audit Trail]]
