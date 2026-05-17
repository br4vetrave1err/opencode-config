# MCP Conformance Testing

**Last Updated:** 2026-05-17

---

## Overview

MCP conformance testing validates that all 5 MCP servers comply with the Model Context Protocol specification. Uses the official `@modelcontextprotocol/conformance` framework.

---

## Test Framework

**Tool:** `@modelcontextprotocol/conformance` (official MCP conformance suite)

**Coverage:** 88 tests across 8 categories for HTTP servers, ~75 for stdio servers.

**Categories:**
1. Transport (13 tests) — HTTP POST, content-type, notifications
2. Lifecycle (4 tests) — initialize, initialized, serverInfo, ping
3. Tools (5+ tests) — tools/list, tools/call, schema validation
4. Resources (5 tests) — resources/list, resources/read
5. Prompts (3 tests) — prompts/list, prompts/get
6. Error Handling (10 tests) — unknown method, invalid JSON, error codes
7. Schema Validation (6 tests) — tool schemas, prompt schemas
8. Security (23 tests) — auth required, WWW-Authenticate, session IDs

---

## Server Test Matrix

| Server | Type | URL/Command | Auth | Status |
|---|---|---|---|---|
| postman | remote HTTP | `https://mcp.postman.com/mcp` | OAuth 2.1 | ✅ Tested |
| atlassian | remote HTTP | `https://mcp.atlassian.com/v1/mcp` | OAuth 2.1 PKCE | ✅ Tested |
| confluence | local stdio | `npx -y atlassian-confluence-mcp-server@latest` | PAT | ⚠️ Auth required |
| obsidian | local stdio | `npx @bitbonsai/mcpvault@latest /path` | None | ✅ Tested |
| github | local stdio | `npx -y modelcontextprotocol/server-github` | Token | ⚠️ Auth required |

---

## Core Scenarios (CI)

For CI speed, only core scenarios are tested:

| Scenario | What It Validates | Required |
|---|---|---|
| `server-initialize` | Handshake, capabilities, version negotiation | Yes |
| `tools-list` | Tool listing, schema validation, pagination | Yes |
| `tools-call-simple-text` | Basic tool invocation, response format | Yes |

**Total: 3 scenarios × 5 servers = 15 conformance checks**

---

## Running Tests

### All Servers (Local)

```bash
cd ~/Desktop/projects/opencode-config
bash tests/conformance/run-all.sh
```

### Single Server

```bash
# Remote server
npx @modelcontextprotocol/conformance server --url https://mcp.postman.com/mcp --scenario server-initialize

# Local server (stdio)
npx @modelcontextprotocol/conformance server --command "npx -y atlassian-confluence-mcp-server@latest" --scenario server-initialize
```

### List Available Scenarios

```bash
npx @modelcontextprotocol/conformance list --server
```

---

## Expected Failures

`tests/conformance/expected-failures.yaml` tracks known failures:

```yaml
# Known failures that don't block CI
servers:
  confluence:
    - scenario: tools-call-simple-text
      reason: "Requires PAT authentication not available in CI"
  github:
    - scenario: tools-call-simple-text
      reason: "Requires GITHUB_TOKEN not available in CI"
```

**Rule:** CI passes if actual failures match expected failures. New failures trigger investigation.

---

## Results Format

Results saved as JSON in `tests/conformance/results/`:

```json
{
  "server": "postman",
  "url": "https://mcp.postman.com/mcp",
  "timestamp": "2026-05-17T22:00:00Z",
  "scenarios": [
    {
      "name": "server-initialize",
      "status": "PASS",
      "checks": [
        {"id": "lifecycle-initialize", "status": "PASS"},
        {"id": "lifecycle-serverInfo", "status": "PASS"},
        {"id": "versioning-protocol", "status": "PASS"}
      ]
    }
  ],
  "summary": {
    "total": 15,
    "passed": 13,
    "failed": 2,
    "skipped": 0,
    "grade": "A"
  }
}
```

---

## Grading

| Grade | Score | Meaning |
|---|---|---|
| A | 90-100% | Excellent compliance |
| B | 80-89% | Good, minor issues |
| C | 70-79% | Acceptable, some gaps |
| D | 60-69% | Needs improvement |
| F | < 60% | Significant compliance issues |

---

## CI Integration

In `validate-config.yml`:

```yaml
mcp-conformance:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Run conformance tests
      run: bash tests/conformance/run-all.sh
    - name: Upload results
      uses: actions/upload-artifact@v4
      with:
        name: conformance-results
        path: tests/conformance/results/
```

---

## Troubleshooting

### Server Not Responding

```bash
# Test basic connectivity
curl -v https://mcp.postman.com/mcp

# Check server logs (local)
npx -y atlassian-confluence-mcp-server@latest 2>&1 | head -20
```

### Auth Failures

```bash
# Verify auth tokens
opencode mcp list

# Re-authenticate
opencode mcp auth postman
opencode mcp auth atlassian
```

### Timeout Issues

```bash
# Increase timeout
npx @modelcontextprotocol/conformance server --url https://mcp.postman.com/mcp --timeout 60000
```

---

## Related

- [[06-Testing/Test-Strategy|Test Strategy]]
- [[06-Testing/Config-Validation|Config Validation]]
- [[07-Observability/Audit-Trail|Audit Trail]]
