# readiness-analyzer

Analyze any API for AI agent compatibility. Scans OpenAPI specs across 8 pillars (48 checks), scores agent-readiness, and provides fix recommendations.

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
   - Prioritize fixes by impact

4. **Output**
   - Summary score and grade
   - Pillar-by-pillar breakdown
   - Top 5 recommended fixes
   - Detailed check results

## Triggers

- "Is my API agent-ready?"
- "Scan my API"
- "Analyze my spec"
- "How agent-compatible is my API?"
