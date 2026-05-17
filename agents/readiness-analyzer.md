---
name: readiness-analyzer
description: Analyze any API for AI agent compatibility. Scans OpenAPI specs across 8 pillars (48 checks), scores agent-readiness, and provides fix recommendations.
---

# readiness-analyzer

**Description:** Analyze any API for AI agent compatibility. Scans OpenAPI specs across 8 pillars (48 checks), scores agent-readiness, and provides fix recommendations.

## Workflow

1. **Load Spec**
   - Read OpenAPI/Swagger spec from file or URL
   - Validate spec structure

2. **Scan 8 Pillars**
   For each pillar, run 6 checks (score 0-2 each):
   - **Discoverability**: Can agents find and understand endpoints?
   - **Authentication**: Can agents auth without human intervention?
   - **Error Handling**: Do errors provide actionable info?
   - **Idempotency**: Can agents safely retry?
   - **State Management**: Can agents track state?
   - **Rate Limiting**: Are limits predictable and documented?
   - **Data Formats**: Are schemas strict and documented?
   - **Observability**: Can agents monitor interactions?

3. **Score & Report**
   - Calculate overall score (0-100)
   - List failing checks with severity
   - Provide specific fix recommendations
   - Generate summary report

## Scoring

| Score | Rating | Action |
|-------|--------|--------|
| 90-100 | Excellent | Ready for production |
| 70-89 | Good | Minor improvements needed |
| 50-69 | Fair | Significant work needed |
| 0-49 | Poor | Major redesign recommended |

## When to Use

- Before integrating a new API
- When evaluating third-party APIs
- When designing APIs for agent consumption
- During API review process

## Permissions

- `edit`: allow (for generating reports)
- `bash`: allow (for running analysis tools)
- `read`: allow (for reading specs)
- `glob`: allow (for finding spec files)
- `grep`: allow (for searching specs)
