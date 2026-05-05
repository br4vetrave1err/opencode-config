---
name: output-validator
description: Validates solution outputs against domain-specific criteria. Use after implementation to verify accuracy, correctness, and completeness before final approval. Also use for domain-specific checks (coding, math, physics, writing).
---

# Output Validator Skill

This skill validates the autonomous agent's output against domain-specific criteria, ensuring accuracy and correctness.

## Input Format

When invoking this skill, provide:

```
DOMAIN: {coding|math|physics|writing|data_analysis|general}
OUTPUT: {path to output file or content}
EXECUTION_LOGS: {path to logs or summary}
ADDITIONAL_CONTEXT: {any domain-specific info}
```

## Output Format

Return validation result:

```json
{
  "validation_id": "val_{timestamp}",
  "domain": "coding",
  "passed": true,
  "score": 92,
  "issues": [
    {
      "severity": "critical|warning|info",
      "check": "Test execution",
      "description": "Test 'edge_case' failed",
      "recommendation": "Add handling for empty input"
    }
  ],
  "checks_performed": [
    {
      "check": "Test execution",
      "status": "pass",
      "details": "All 15 tests passed"
    }
  ],
  "recommendations": [
    "Consider adding more edge case tests"
  ]
}
```

## Validation Process

### Step 1: Domain-Specific Load

Load the appropriate domain check file:

- `domain-checks/coding.md` - for coding domain
- `domain-checks/math.md` - for math domain
- `domain-checks/physics.md` - for physics domain
- `domain-checks/writing.md` - for writing domain

### Step 2: Execute Domain Checks

For each check in the domain file:
1. Read the output file
2. Run the validation command
3. Record the result

### Step 3: Scoring

Compute weighted score:
- Critical issues: -30 points each
- Warnings: -15 points each
- Info: no penalty

Starting score: 100

### Step 4: Threshold Check

- Score >= 80: PASS
- Score < 80: FAIL with issues

### Step 5: Recommendations

Based on issues, generate actionable recommendations for improvement.

## Domain-Specific Checks

### Coding Domain Checks

1. **Test Execution**: Run test suite, all must pass
2. **Syntax**: No syntax errors
3. **Linting**: No lint errors
4. **Logic**: Implementation matches requirements
5. **Edge Cases**: Handle edge cases

### Math Domain Checks

1. **Derivation**: Steps are mathematically sound
2. **Computation**: Final answer is correct
3. **Units**: Dimensional consistency
4. **Formula**: Correct formulas applied

### Physics Domain Checks

1. **Units**: SI unit consistency
2. **Formulas**: Correct physics formulas
3. **Reasoning**: Physical principles applied
4. **Accuracy**: Numerical correctness

### Writing Domain Checks

1. **Grammar**: No grammatical errors
2. **Structure**: Coherent organization
3. **Facts**: Claims verified via web search
4. **Completeness**: All required sections present

## Cross-Domain Validation

For mixed-domain problems:
1. Identify each domain component
2. Run checks for each domain
3. Composite score: average of domain scores
4. Pass only if ALL domains pass

## Error Handling

If validation fails:
1. Present issues in order of severity
2. For each issue, provide recommendation
3. Ask: Fix and retry, or Abort?

## Validation Examples

### Coding Pass Example

```json
{
  "validation_id": "val_20260101_120000",
  "domain": "coding",
  "passed": true,
  "score": 95,
  "issues": [],
  "checks_performed": [
    {"check": "Test execution", "status": "pass", "details": "12/12 tests passed"},
    {"check": "Syntax", "status": "pass", "details": "No syntax errors"},
    {"check": "Linting", "status": "pass", "details": "flake8 passed"},
    {"check": "Logic", "status": "pass", "details": "Implementation correct"},
    {"check": "Edge Cases", "status": "pass", "details": "All edge cases handled"}
  ],
  "recommendations": ["Good coverage, consider adding integration tests"]
}
```

### Math Pass Example

```json
{
  "validation_id": "val_20260101_120001",
  "domain": "math",
  "passed": true,
  "score": 88,
  "issues": [
    {
      "severity": "warning",
      "check": "Derivation steps",
      "description": "Step 3 could be more explicit",
      "recommendation": "Show intermediate algebraic steps"
    }
  ],
  "checks_performed": [
    {"check": "Derivation", "status": "pass", "details": "Verified via sympy"},
    {"check": "Computation", "status": "pass", "details": "y(2) = 0.1353"},
    {"check": "Units", "status": "pass", "details": "Dimensionally consistent"},
    {"check": "Formula", "status": "pass", "details": "Correct differential equation solution"}
  ],
  "recommendations": []
}
```

### Writing Fail Example

```json
{
  "validation_id": "val_20260101_120002",
  "domain": "writing",
  "passed": false,
  "score": 65,
  "issues": [
    {
      "severity": "critical",
      "check": "Factual accuracy",
      "description": "Claim 'Einstein received Nobel in 1921' is incorrect - it was 1921 for photoelectric effect",
      "recommendation": "Verify facts via web search"
    },
    {
      "severity": "warning",
      "check": "Grammar",
      "description": "3 grammar errors found in paragraph 2",
      "recommendation": "Run through grammar checker"
    }
  ],
  "checks_performed": [
    {"check": "Grammar", "status": "warning", "details": "3 errors found"},
    {"check": "Structure", "status": "pass", "details": "Good flow"},
    {"check": "Facts", "status": "fail", "details": "2 claims unverified"},
    {"check": "Completeness", "status": "pass", "details": "All sections present"}
  ],
  "recommendations": ["Fix factual errors", "Run grammar check"]
}
```

## Integration with Orchestrator

The output-validator is called from the autonomous-agent orchestrator in Phase 6 (Approval Check).

On validation result:
- `passed: true` → Proceed to final approval
- `passed: false` → Present issues to user, ask: Fix and retry or Abort?

## Tools Used

- `read` - Read output files and logs
- `bash` - Run validation commands (pytest, flake8, sympy, etc.)
- `web-search` - Verify factual claims for writing domain
- `edit` - If fixing minor issues before retry