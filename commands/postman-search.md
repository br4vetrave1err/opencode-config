---
description: "Discover APIs across Postman workspaces"
agent: build
---

# Postman Search

Discover APIs across Postman workspaces using natural language.

## Workflow

1. **Understand Query**
   - Parse user's natural language request
   - Identify: what functionality they need, any constraints

2. **Search**
   - Use `postman_searchPrivateNetwork` for private APIs
   - Use `postman_searchPublicNetwork` for public APIs
   - Filter by workspace if specified

3. **Present Results**
   - List matching APIs with:
     - Name and description
     - Number of endpoints
     - Key capabilities
   - Offer to drill into specific API details

4. **Drill Down** (if user selects an API)
   - Show endpoint list
   - Show authentication requirements
   - Show request/response examples
   - Offer to generate code or create mock

## Example Queries

- "Find an API for payment processing"
- "What APIs do we have for user management?"
- "Search for endpoints that handle file uploads"
- "Find APIs with webhook support"

## Output

- Search results ranked by relevance
- Option to explore individual APIs
- Option to use found APIs (generate code, create mock, etc.)
