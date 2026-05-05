# Autonomous Problem-Solving Agent

An autonomous agent system for opencode that ingests problems from Google Drive, solves them end-to-end, and uploads solutions back.

## Overview

The system consists of:

| Component | Purpose |
|-----------|---------|
| `autonomous-agent` skill | Orchestrator that manages the full workflow |
| `problem-planner` skill | Generates structured implementation plans |
| `output-validator` skill | Validates output against domain-specific criteria |
| Google Drive MCP | Drive file operations (ingest + upload) |
| Docker sandbox | Sandboxed code execution environment |
| Observer logger | Full trace logging for observability |

## Workflow

```
Drive Link → Ingest → Domain Classify → Plan → Plan Approval → Implement → Validator → Final Approval → Upload
```

## Invocation

### CLI Command

```bash
opencode solve "https://drive.google.com/drive/folders/..."
```

### Skill Invocation

Invoke the `autonomous-agent` skill:

```
Use the autonomous-agent skill to solve this problem from Drive: {drive-link}
```

## Input Format

The Drive folder should contain:

- **Problem statement**: PDF, DOCX, or MD file with problem description
  - Must include `format_spec` section specifying output format
- **Data files**: Any supporting data (CSV, images, etc.)
- **solution/**: Pre-existing subfolder for output upload

### Format Spec Example

```markdown
# Problem: Predict housing prices

## Requirements
- Use linear regression
- Output predictions with confidence intervals

## format_spec
- Output file: `solution.md`
- Sections: model, coefficients, predictions, visualization
- Upload to: solution/housing_predictions.md
```

## Output

Solution uploaded to `solution/` folder in the Drive directory with specified naming.

## Configuration

### 1. Google Drive API Setup

See `scripts/autonomous-agent/drive-ops.sh oauth-setup` for OAuth instructions.

1. Go to Google Cloud Console
2. Enable Google Drive API
3. Create OAuth credentials
4. Set in `opencode.json`:

```json
{
  "google-drive": {
    "enabled": true,
    "env": {
      "GOOGLE_API_KEY": "...",
      "GOOGLE_CLIENT_ID": "...",
      "GOOGLE_CLIENT_SECRET": "..."
    }
  }
}
```

### 2. Environment Variables

Copy `.env.example` to `.env` and fill in:

```bash
GOOGLE_API_KEY=...
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...
LANGSMITH_API_KEY=...  # optional
```

### 3. Enable Google Drive MCP

In `opencode.json`, set `enabled: true` for google-drive.

## Observability

All traces are stored locally:

```
~/.autonomous-agent/traces/{run_id}.jsonl
```

View traces:

```bash
# Read specific trace
~/.autonomous-agent/scripts/autonomous-agent/logger.sh read autonomous_20260101_120000

# List recent traces
ls -la ~/.autonomous-agent/traces/
```

## Execution Artifacts

Sandbox execution logs and docker-compose saved to:

```
~/.autonomous-agent/executions/{run_id}/
```

## Domains Supported

| Domain | Validation |
|--------|-----------|
| coding | Tests pass, lint clean, no syntax errors |
| math | Derivation verified, computation correct |
| physics | Units consistent, formulas correct |
| writing | Grammar, facts verified, coherent |

## Files Structure

```
opencode-config/
├── skills/
│   ├── autonomous-agent/SKILL.md
│   ├── problem-planner/SKILL.md
│   └── output-validator/
│       ├── SKILL.md
│       └── domain-checks/
│           ├── coding.md
│           ├── math.md
│           ├── physics.md
│           └── writing.md
├── scripts/
│   └── autonomous-agent/
│       ├── docker-sandbox.sh
│       ├── logger.sh
│       └── drive-ops.sh
├── docs/
├── opencode.json
└── .env
```

## Troubleshooting

### Drive MCP not connecting

1. Check credentials in `~/.autonomous-agent/credentials.json`
2. Verify OAuth scopes include `drive.file`

### Code execution failing

1. Check Docker is running
2. Verify sandbox container: `docker ps | grep autonomous`

### Validation always failing

1. Check domain classification is correct
2. Review validation criteria in domain-checks/