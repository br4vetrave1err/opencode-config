---
name: autonomous-agent
description: Autonomous problem-solving agent that ingests problems from Drive, classifies domain, creates/executes plans, validates output, and uploads solutions back. Use when you provide a Drive link and want end-to-end problem solving with full observability.
---

# Autonomous Agent Orchestrator

This skill orchestrates the complete problem-solving workflow from Drive input to solution output.

## Workflow Phases

```
┌──────────────────────────────────────────────────────────────────────────┐
│  PHASE 1: INGEST                                                 │
│  - Receive Drive link from user                                  │
│  - Fetch problem statement (PDF/DOCX/MD) + data files           │
│  - Download to ~/autonomous-work/{run_id}/                      │
│  - Emit observability event                                    │
└──────────────────────────────────────────────────────────────────────────┘
                              ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  PHASE 2: DOMAIN CLASSIFY                                        │
│  - Analyze problem statement content                             │
│  - Extract domain, subdomain, key entities                      │
│  - Identify required skills, tools, and MCP servers            │
│  - Emit observability event                                    │
└──────────────────────────────────────────────────────────────────────────┘
                              ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  PHASE 3: PLAN                                                   │
│  - Load problem-planner skill                                    │
│  - Pass problem + domain classification                        │
│  - Generate structured implementation plan                     │
│  - Plan includes steps, tools, skills, rollback, success criteria│
│  - Emit observability event                                    │
└──────────────────────────────────────────────────────────────────────────┘
                              ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  PHASE 4: PLAN APPROVAL                                          │
│  - Present plan to user in structured format                    │
│  - Wait for Y/N response                                      │
│  - On rejection: collect feedback, revise plan                 │
│  - Retry until approved or user chooses to restart              │
│  - Emit observability event                                    │
└──────────────────────────��───────────────────────────────────────────────┘
                              ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  PHASE 5: IMPLEMENT                                              │
│  - Execute each step sequentially                              │
│  - Use Docker sandbox for code execution                     │
│  - Apply TDD pattern for coding problems                     │
│  - Use web-search/webfetch for research                    │
│  - Log every tool call, response, tokens, latency           │
│  - On step failure: retry 3x with exponential backoff      │
│  - Emit observability events for each step                  │
└──────────────────────────────────────────────────────────────────────────┘
                              ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  PHASE 6: APPROVAL CHECK                                         │
│  - Load output-validator skill                                │
│  - Run domain-specific validation                            │
│  - Coding: tests pass, lint clean, no syntax errors          │
│  - Math: derivation verified, dimensionally correct         │
│  - Physics: units consistent, formulas correct            │
│  - Writing: grammar, coherence, facts verified             │
│  - Emit observability event                                    │
└──────────────────────────────────────────────────────────────────────────┘
                              ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  PHASE 7: FINAL APPROVAL                                         │
│  - Present validated output to user                         │
│  - Wait for Y/N response                                      │
│  - On rejection: return to IMPLEMENT or restart               │
│  - Emit observability event                                    │
└──────────────────────────────────────────────────────────────────────────┘
                              ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  PHASE 8: UPLOAD                                                 │
│  - Read format_spec from problem statement                   │
│  - Upload solution to solution/ folder in Drive            │
│  - Use filename from format_spec                              │
│  - Emit observability event                                    │
└──────────────────────────────────────────────────────────────────────────┘
```

## Step-by-Step Execution

### Step 1: Receive and Validate Input

When invoked, expect one of:
- A Google Drive link (full URL or folder ID)
- A CLI command: `opencode solve "https://drive.google.com/..."`

Validate the link is a valid Drive URL or folder ID.

### Step 2: Ingest Phase

1. Extract folder ID from Drive link
2. List all files in the folder using Drive MCP
3. Identify problem statement file:
   - `.pdf`, `.docx`, `.md` files are candidates
   - Look for file with "problem" or "statement" in name
   - If multiple, ask user which is problem file
4. Download all files to `~/autonomous-work/{run_id}/`
5. Generate unique `run_id` = `autonomous_{timestamp}`
6. Emit event:
```json
{
  "event": "phase_completed",
  "phase": "ingest",
  "run_id": "autonomous_20260101_120000",
  "files_downloaded": ["problem.pdf", "data.csv"],
  "status": "success"
}
```

### Step 3: Domain Classification

1. Read problem statement content (handle PDF/DOCX via conversion)
2. Extract key entities, requirements
3. Classify into:
   - `coding` (python, javascript, go, etc.)
   - `math` (calculus, algebra, statistics, etc.)
   - `physics` (mechanics, quantum, electromagnetism, etc.)
   - `writing` (technical, creative, academic, etc.)
   - `data_analysis` (visualization, modeling, etc.)
   - `general` (unclassified)
4. Identify required tools:
   - coding: `bash`, `read`, `write`, `edit`, `codesearch`
   - math: `bash` (python/sympy), `web-search`
   - physics: `bash`, `web-search`
   - writing: `read`, `edit`, `web-search`
5. Emit event:
```json
{
  "event": "phase_completed",
  "phase": "domain_classify",
  "run_id": "autonomous_20260101_120000",
  "domain": "coding",
  "subdomain": "python/machine-learning",
  "confidence": 0.94,
  "required_skills": ["tdd"],
  "required_tools": ["bash", "read", "write"],
  "status": "success"
}
```

### Step 4: Plan Generation

1. Load skill: `problem-planner`
2. Pass the following to planner:
   - Problem statement text
   - Domain classification result
   - Data files available
   - Format specification from problem
3. Receive plan in structured format
4. Emit event

### Step 5: Plan Approval

Present plan to user in this format:

```
═══════════════════════════════════════════
                    PLAN APPROVAL
═══════════════════════════════════════════

Domain: {domain}
Complexity: {complexity}

Steps:
1. {action} → {tool/skill} [{inputs} → {expected_output}]
2. {action} → {tool/skill} [{inputs} → {expected_output}]
...

Estimated Duration: {duration}
Risks: {risks}

Success Criteria:
- {criterion 1}
- {criterion 2}

═══════════════════════════════════════════

APPROVE? (Y/N/Revise/Restart)
```

- On `Y`: Proceed to implement
- On `N`: Abort, report to user
- On `Revise`: Collect feedback, go back to Step 4
- On `Restart`: Go back to domain classification

### Step 6: Implementation

1. For each step in the plan:
   a. Log step start event
   b. Execute using appropriate tool/skill/MCP
   c. For code: use Docker sandbox
   d. Verify expected output matches
   e. Log step complete event
   f. On failure: retry 3x with exponential backoff
   g. If still failing: escalate to user with error report

2. Docker sandbox usage:
   - Create container from saved docker-compose
   - Execute code inside
   - Capture stdout/stderr
   - Save logs to `~/.autonomous-agent/executions/{run_id}/`
   - Save docker-compose used

3. Observability logging for each tool call:
```json
{
  "event": "tool_call",
  "run_id": "autonomous_20260101_120000",
  "step": 3,
  "tool": "bash",
  "command": "python train.py",
  "input_tokens": 0,
  "output_tokens": 2048,
  "duration_ms": 45200,
  "status": "success",
  "stdout": "...",
  "stderr": "..."
}
```

### Step 7: Approval Check

1. Load skill: `output-validator`
2. Pass domain + output + execution logs
3. Receive validation result:
```json
{
  "passed": true,
  "score": 92,
  "issues": [],
  "recommendations": []
}
```
4. If not passed:
   - Present issues to user
   - Ask: Fix and retry, or Abort?

### Step 8: Final Approval

Present final result to user with validation score.

- On `Y`: Proceed to upload
- On `N`: Ask what to fix, return to implement

### Step 9: Upload

1. Read format_spec from problem statement
2. Check for `solution/` subfolder in Drive
3. Upload output file with specified naming
4. Confirm upload success

## Observability Requirements

Every phase and tool call MUST emit structured JSON events:

Trace file: `~/.autonomous-agent/traces/{run_id}.jsonl`

Event types:
- `phase_started` - when a phase begins
- `phase_completed` - when a phase ends
- `tool_call` - every tool invocation
- `tool_response` - every tool response
- `error` - any error
- `user_approval` - approval requests/responses

Fields per event:
```json
{
  "timestamp": "ISO8601",
  "run_id": "autonomous_YYYYMMDD_HHMMSS",
  "event": "phase_completed",
  "phase": "implement",
  "step": 3,
  "domain": "coding",
  "input_tokens": 512,
  "output_tokens": 2048,
  "duration_ms": 45200,
  "status": "success",
  "metadata": {}
}
```

## Sensitive Data Handling

If problem contains potential sensitive data (API keys, passwords, credentials):
1. Log a warning
2. Ask user: "This problem involves potential sensitive data. Proceed?"
3. On approval: continue but mask in traces
4. On rejection: abort

## Error Recovery

- Tool failure: retry 3x with exponential backoff (1s, 2s, 4s)
- After 3 failures: escalate to user with full error report
- Plan rejection: offer revision or restart

## File Paths

- Working directory: `~/autonomous-work/{run_id}/`
- Execution logs: `~/.autonomous-agent/executions/{run_id}/`
- Traces: `~/.autonomous-agent/traces/{run_id}.jsonl`
- Credentials: `~/.autonomous-agent/credentials.json`

## Skills Auto-loading

Based on domain classification:

| Domain | Auto-loaded Skills |
|--------|-------------------|
| coding | `tdd` |
| math | None needed |
| physics | None needed |
| writing | `edit-article` |
| data_analysis | `tdd` |

Load skills dynamically before implementation phase.