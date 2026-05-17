---
description: "Analyze and improve API documentation"
agent: build
---

# Postman Docs

Analyze API documentation completeness and improve documentation quality.

## Workflow

1. **Select Collection or Spec**
   - List available collections
   - Ask user which to analyze

2. **Analyze Documentation**
   - Check each endpoint for:
     - Description present and meaningful
     - Request parameters documented
     - Request body schema documented
     - Response schemas documented
     - Example requests provided
     - Example responses provided
     - Authentication requirements documented
   - Calculate completeness score

3. **Identify Gaps**
   - List endpoints missing descriptions
   - List endpoints missing examples
   - List endpoints missing response schemas
   - Prioritize gaps by importance

4. **Generate Improvements**
   - For each gap, generate:
     - Endpoint description based on path/method
     - Parameter descriptions from names and types
     - Example requests with realistic data
     - Example responses matching schemas
   - Apply improvements to collection

5. **Review & Publish**
   - Show summary of improvements
   - Ask for user approval
   - Apply approved changes
   - Publish updated documentation

## Output

- Completeness score (before/after)
- List of improvements made
- Remaining gaps (if any)
- Link to published documentation
