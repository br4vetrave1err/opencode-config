# Eval Framework

**Last Updated:** 2026-05-17

---

## Overview

YAML-based evaluation framework for testing OpenCode agent behavior through real sessions. Runs locally only (not in CI) due to token costs and auth requirements.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Eval Runner (runner.sh)                   │
│                                                              │
│  1. Load YAML eval specs from tests/evals/                  │
│  2. For each spec:                                          │
│     a. Run N trials (default 3)                             │
│     b. For each trial:                                      │
│        - Open OpenCode session with specified agent         │
│        - Send prompt(s)                                     │
│        - Capture tool trace (JSON)                          │
│        - Validate behavior assertions                       │
│        - Validate content expectations                      │
│     c. Aggregate results across trials                      │
│  3. Save traces to tests/evals/traces/                      │
│  4. Output summary report                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## Eval Spec Format

```yaml
# tests/evals/agents/readiness-analyzer.eval.yaml
id: ra-001
name: "Readiness Analyzer - Postman MCP Scan"
description: "Verify agent can analyze MCP server tools for compatibility"
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

### Fields

| Field | Required | Type | Description |
|---|---|---|---|
| `id` | Yes | string | Unique identifier (format: `{agent}-{number}`) |
| `name` | Yes | string | Human-readable name |
| `description` | No | string | What this eval validates |
| `agent` | Yes | string | Agent to use (built-in or custom) |
| `category` | No | string | `developer`, `business`, `creative`, `edge-case` |
| `trials` | No | int | Number of runs (default: 3) |
| `prompts` | Yes | array | Prompt(s) to send |
| `behavior` | No | object | Behavior assertions |
| `contentExpectations` | No | array | Content validation rules |
| `timeout` | No | string | Max duration per trial (default: 300s) |

### Behavior Assertions

| Field | Type | Description |
|---|---|---|
| `mustUseTools` | array | Tools that must be called |
| `mustNotUseTools` | array | Tools that must not be called |
| `minToolCalls` | int | Minimum total tool calls |
| `maxToolCalls` | int | Maximum total tool calls |
| `requiresApproval` | bool | Whether approval was requested |
| `requiresContext` | bool | Whether context files were loaded |

### Content Expectations

| Field | Type | Description |
|---|---|---|
| `mustContain` | array | Strings that must appear in output |
| `mustNotContain` | array | Strings that must not appear in output |

---

## Eval Specs

### Agent Evals (3 files)

| File | Agent | Scenarios | Focus |
|---|---|---|---|
| `readiness-analyzer.eval.yaml` | readiness-analyzer | 3 | API analysis, scoring, recommendations |
| `pr-babysitter.eval.yaml` | pr-babysitter | 3 | PR triage, conflict resolution, CI fixing |
| `split-to-prs.eval.yaml` | split-to-prs | 3 | Change splitting, commit boundaries |

### Workflow Evals (2 files)

| File | Agent | Scenarios | Focus |
|---|---|---|---|
| `postman-workflow.eval.yaml` | build | 5 | Postman MCP workflows |
| `redis-config.eval.yaml` | build | 3 | Redis configuration tasks |

**Total: 17 scenarios × 3 trials = 51 eval runs**

---

## Running Evals

### Full Suite

```bash
cd ~/Desktop/projects/opencode-config
bash tests/evals/runner.sh
```

### Single Eval Spec

```bash
bash tests/evals/runner.sh --spec tests/evals/agents/readiness-analyzer.eval.yaml
```

### Single Scenario

```bash
bash tests/evals/runner.sh --spec tests/evals/agents/readiness-analyzer.eval.yaml --scenario ra-001
```

### With Debug Output

```bash
bash tests/evals/runner.sh --verbose
```

---

## Trace Format

Each eval run produces a JSON trace:

```json
{
  "eval_id": "ra-001",
  "eval_name": "Readiness Analyzer - Postman MCP Scan",
  "trial": 1,
  "agent": "readiness-analyzer",
  "prompt": "Analyze the Postman MCP server tools...",
  "start_time": "2026-05-17T22:00:00Z",
  "end_time": "2026-05-17T22:00:45Z",
  "duration_ms": 45000,
  "tool_calls": [
    {
      "tool": "read",
      "args": {"path": "~/.config/opencode/opencode.json"},
      "duration_ms": 120,
      "result": "success"
    },
    {
      "tool": "grep",
      "args": {"pattern": "mcp", "path": "~/.config/opencode/"},
      "duration_ms": 85,
      "result": "success"
    }
  ],
  "behavior_validation": {
    "mustUseTools": {"read": true, "grep": true},
    "tool_call_count": 8,
    "requiresApproval": false,
    "result": "PASS"
  },
  "content_validation": {
    "mustContain": {"compatibility": true, "score": true},
    "mustNotContain": {"error": false, "failed": false},
    "result": "PASS"
  },
  "result": "PASS"
}
```

---

## Trace Retention

| Location | Purpose | Retention |
|---|---|---|
| `tests/evals/traces/` | Latest traces | Last 10 runs |
| `tests/evals/traces/archive/` | Historical traces | 30 days |

Cleanup: `bash scripts/cleanup-traces.sh` (run weekly via cron)

---

## Quality Gates

| Metric | Threshold | Action |
|---|---|---|
| Pass rate | ≥ 80% | Investigate failures below threshold |
| Tool accuracy | ≥ 90% | Review eval spec if below |
| Avg latency | < 60s per scenario | Optimize prompts if above |
| Token cost | < $2.00 per run | Review if exceeds |

---

## Adding New Eval Specs

1. Create YAML file in `tests/evals/agents/` or `tests/evals/workflows/`
2. Define prompts, behavior assertions, content expectations
3. Test locally: `bash tests/evals/runner.sh --spec path/to/spec.yaml`
4. Review traces in `tests/evals/traces/`
5. Commit spec file

---

## CI Integration

Evals are NOT run in CI. They are triggered manually:

```yaml
# .github/workflows/agent-evals.yml
name: Agent Evals
on:
  workflow_dispatch:

jobs:
  run-evals:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run evals
        run: bash tests/evals/runner.sh
      - name: Upload traces
        uses: actions/upload-artifact@v4
        with:
          name: eval-traces
          path: tests/evals/traces/
```

---

## Related

- [[06-Testing/Test-Strategy|Test Strategy]]
- [[06-Testing/Config-Validation|Config Validation]]
- [[07-Observability/Audit-Trail|Audit Trail]]
