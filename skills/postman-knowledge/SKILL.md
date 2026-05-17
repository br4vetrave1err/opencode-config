---
name: postman-knowledge
description: Postman concepts and MCP tool guidance
---

# Postman Knowledge

Knowledge about Postman concepts and how to use the Postman MCP tools effectively.

## Core Concepts

- **Collections**: Grouped API requests with shared configuration
- **Environments**: Variable sets for different contexts (dev, staging, prod)
- **Mock Servers**: Simulated API endpoints for testing
- **Monitors**: Scheduled collection runs
- **API Network**: Public and private API discovery

## MCP Tool Categories

### Collections
- `postman_getCollections` — List all collections
- `postman_createCollection` — Create a new collection
- `postman_updateCollection` — Update collection metadata
- `postman_syncCollection` — Sync with OpenAPI spec

### Specs
- `postman_getSpecs` — List API specs
- `postman_createSpec` — Create from OpenAPI/Swagger
- `postman_generateCollection` — Generate collection from spec

### Environments
- `postman_getEnvironments` — List environments
- `postman_createEnvironment` — Create variable set
- `postman_patchEnvironment` — Update variables

### Mocks
- `postman_createMockServer` — Create mock from collection
- `postman_publishMockServer` — Make mock public
- `postman_unpublishMockServer` — Hide mock
- `postman_deleteMockServer` — Remove mock

### Tests
- `postman_runCollection` — Execute collection tests
- `postman_getTestResults` — Get run results

### Search
- `postman_searchPrivateNetwork` — Search private APIs
- `postman_searchPublicNetwork` — Search public APIs

## Best Practices

1. Always use environments for variable management
2. Keep collections organized by API domain
3. Write assertions for every request
4. Use mock servers for frontend development
5. Sync collections with OpenAPI specs for accuracy
