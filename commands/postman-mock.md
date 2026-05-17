---
description: "Create Postman mock servers"
agent: build
---

# Postman Mock

Create Postman mock servers from collections or API specs.

## Workflow

1. **Select Source**
   - List available collections
   - Ask user which to mock
   - Or offer to create from OpenAPI spec

2. **Configure Mock**
   - Set mock server name
   - Select environment (for variable substitution)
   - Configure response delays (optional)
   - Set up example responses for each endpoint

3. **Create Mock**
   - Use `postman_createMockServer`
   - Publish if needed (`postman_publishMockServer`)
   - Get mock URL

4. **Verify**
   - Test mock URL with sample requests
   - Confirm responses match expected examples
   - Report mock URL and usage instructions

5. **Share**
   - Provide mock URL
   - List available endpoints
   - Show example requests

## Use Cases

- Frontend development before backend is ready
- Integration testing with predictable responses
- Demos and presentations
- Contract testing

## Output

- Mock server URL
- List of mocked endpoints
- Example request/response pairs
- Instructions for using the mock
