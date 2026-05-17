---
description: "Sync Postman collections with local API code"
agent: build
---

# Postman Sync

Keep Postman collections in sync with local API code.

## Workflow

1. **Detect API Specs**
   - Search for OpenAPI/Swagger specs in the project
   - Common locations: `openapi.yaml`, `openapi.json`, `swagger.yaml`, `docs/api/`
   - Ask user to confirm which spec to sync

2. **Check Existing Collections**
   - List Postman collections via MCP
   - Check if a collection already exists for this API
   - If exists: offer to update
   - If not exists: offer to create new

3. **Sync**
   - **Create new**: Use `postman_generateCollection` from the spec
   - **Update existing**: Use `postman_syncCollection` to sync spec changes
   - Preserve any manual edits (descriptions, test scripts)

4. **Verify**
   - Confirm collection is up to date
   - Report number of endpoints synced
   - List any endpoints that couldn't be synced

5. **Environments**
   - Check if matching environments exist
   - Create/update environments with base URLs and variables

## Output

- Collection name and link
- Number of endpoints synced
- Any warnings or skipped endpoints
- Environment status
