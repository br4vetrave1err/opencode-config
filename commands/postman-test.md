---
description: "Run collection tests, diagnose failures"
agent: build
---

# Postman Test

Execute Postman collection tests and diagnose failures.

## Workflow

1. **Select Collection & Environment**
   - List available collections
   - Ask user which to test
   - Select appropriate environment (dev, staging, prod)

2. **Run Tests**
   - Use `postman_runCollection` to execute
   - Wait for results
   - Fetch results via `postman_getTestResults`

3. **Analyze Results**
   - Summary: total, passed, failed, skipped
   - For each failure:
     - Identify the failing assertion
     - Show request details (method, URL, body)
     - Show expected vs actual response
     - Diagnose root cause

4. **Suggest Fixes**
   - For each failure, suggest:
     - Code fix (if server-side issue)
     - Test fix (if test is wrong)
     - Environment fix (if config issue)
   - Offer to apply fixes

5. **Re-run** (optional)
   - After fixes, re-run tests
   - Compare before/after results

## Output

- Test summary (pass/fail counts)
- Detailed failure analysis
- Suggested fixes with code snippets
- Option to re-run
