---
description: Unified test command — run backend, frontend, or full test suites with auto-detection
template: /test [backend|frontend|full|smoke|api|db|perf|security|unit|integration|component|e2e] [options]
---

# /test — Unified Test Command

## Usage

```
/test                          # Auto-detect project type, run all applicable tests
/test backend                  # All backend tests (api + db + perf + security)
/test frontend                 # All frontend tests (unit + integration + component + e2e)
/test full                     # Everything (backend + frontend + smoke)
/test smoke                    # Quick smoke: config validation + secrets scan
/test backend api              # API endpoint testing via Postman
/test backend db               # Database testing
/test backend perf             # Performance/load testing
/test backend security         # Security audit (OWASP + secrets)
/test frontend unit            # Unit tests (language-specific)
/test frontend integration     # Integration tests
/test frontend component       # Component tests
/test frontend e2e             # End-to-end browser tests via Playwright
```

## Options

```
--verbose          # Detailed output
--parallel         # Run tests in parallel where possible
--coverage         # Generate coverage report
--target <path>    # Specific file/directory to test
--env <name>       # Environment to test against (dev, staging, prod)
--report <format>  # Output format: console, markdown, json
```

## Auto-Detection Rules

The agent scans the project root for:

| File Found | Detected As | Tests Enabled |
|------------|-------------|---------------|
| `package.json` + `src/` | Node.js/React/Vue | unit, integration, component, e2e |
| `requirements.txt` or `pyproject.toml` | Python | unit, integration, api |
| `pom.xml` or `build.gradle` | Java | unit, integration, api |
| `go.mod` | Go | unit, integration, api |
| `Cargo.toml` | Rust | unit, integration |
| `docker-compose.yml` | Multi-service | api, integration, perf |
| `*.spec.ts` or `*.test.ts` | TypeScript tests | unit, integration |
| `*.spec.js` or `*.test.js` | JavaScript tests | unit, integration |
| `playwright.config.*` | Playwright setup | e2e |
| `postman_collection.json` | Postman setup | api |
| `k6` or `autocannon` config | Perf setup | perf |

## Skills Used

| Test Type | Skills Loaded | MCP Tools |
|-----------|--------------|-----------|
| `api` | `postman-knowledge`, `postman-routing`, `postman-test` | postman, github |
| `db` | `tdd`, `redis-development` (if Redis) | — |
| `perf` | Auto-detect (k6/autocannon/JMeter) | — |
| `security` | `postman-security`, built-in secret scanner | github |
| `unit` | `tdd` | — |
| `integration` | `tdd`, `postman-knowledge` | postman |
| `component` | `tdd` | — |
| `e2e` | `playwright-cli` | — |
| `smoke` | Built-in config validation | — |

## Execution Flow

1. **Detect** — Scan project for language, framework, existing test setup
2. **Plan** — Generate test plan based on detection + user input
3. **Route** — Load appropriate skills and MCP tools
4. **Execute** — Run tests via scripts or MCP tools
5. **Report** — Summarize results, create issues for failures
6. **Persist** — Save results to `tests/results/`

## Output Format

```
=== Test Results ===
Type: backend/api
Project: /path/to/project
Date: 2026-05-17 16:00:00

PASS  12  API endpoint tests
PASS   5  Contract validation
FAIL   2  Security checks
WARN   1  Performance regression

Total: 20 | Pass: 17 | Fail: 2 | Warn: 1

Failed tests:
  - POST /api/users returns 500 instead of 201
  - JWT expiry not enforced on /api/admin

See: tests/results/backend-api-2026-05-17.md
```
