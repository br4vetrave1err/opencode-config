# Command Catalog

All 8 Postman workflow commands. Trigger with `/` prefix in TUI.

---

## Commands

| Command | Description | Agent |
|---------|-------------|-------|
| `/postman-sync` | Sync Postman collections with local API code | build |
| `/postman-codegen` | Generate typed client code from Postman collections | build |
| `/postman-search` | Discover APIs across Postman workspaces | build |
| `/postman-test` | Run collection tests, diagnose failures | build |
| `/postman-mock` | Create Postman mock servers | build |
| `/postman-docs` | Analyze and improve API documentation | build |
| `/postman-security` | Security audit against OWASP API Top 10 | build |
| `/postman-setup` | First-run Postman MCP configuration | build |

---

## Command Files

All stored in `~/.config/opencode/commands/`:

### postman-sync.md
Keep Postman collections in sync with local API code. Detects OpenAPI specs, creates new collections, or updates existing ones when specs change.

### postman-codegen.md
Generate typed client code from Postman collections. Reads private APIs and writes production-ready client code matching project conventions.

### postman-search.md
Answer natural language questions about available APIs. Search across Postman workspaces to find endpoints, understand capabilities, and drill into details.

### postman-test.md
Execute Postman collection tests. Analyze results, diagnose failures, and suggest code fixes.

### postman-mock.md
Create Postman mock servers from collections or API specs. Get a working mock URL for frontend development, integration testing, or demos.

### postman-docs.md
Analyze API documentation completeness, generate missing descriptions and examples, and improve documentation quality.

### postman-security.md
Audit API for security vulnerabilities. Checks against OWASP API Security Top 10, finds missing auth, exposed sensitive data, insecure transport, weak validation.

### postman-setup.md
Guide user through connecting to Postman account via MCP Server. Configure API key, verify connection, select workspace.

---

## Command Format

```markdown
---
description: "Shown in TUI command picker"
agent: build
---

[Full workflow content]
```

---

## Related

- [[01-Architecture/Command-System|Command System]]
- [[03-Skills/Skills-Index|Skills Index]]
