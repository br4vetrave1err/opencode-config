---
name: test-orchestrator
description: Unified test orchestration — auto-detects project type, routes to appropriate test tools and skills, executes backend/frontend/full test suites
---

# Test Orchestrator

Unified testing skill that auto-detects project context and routes to the right testing tools.

## When to Use

User invokes `/test` or asks to run tests, create tests, or validate code quality.

## Project Detection

Scan the project root for these markers:

```bash
# Node.js/JavaScript
[ -f package.json ] && echo "node"
[ -f tsconfig.json ] && echo "typescript"
[ -f playwright.config.ts ] && echo "playwright"
[ -f vitest.config.ts ] && echo "vitest"
[ -f jest.config.js ] && echo "jest"

# Python
[ -f requirements.txt ] && echo "python"
[ -f pyproject.toml ] && echo "python"
[ -f pytest.ini ] && echo "pytest"

# Java
[ -f pom.xml ] && echo "java-maven"
[ -f build.gradle ] && echo "java-gradle"

# Go
[ -f go.mod ] && echo "go"

# Rust
[ -f Cargo.toml ] && echo "rust"

# Infrastructure
[ -f docker-compose.yml ] && echo "docker"
[ -f k6-config.js ] && echo "k6"
[ -d postman ] && echo "postman"
```

## Test Type Routing

| User Input | Test Category | Scripts | Skills to Load | MCP Tools |
|------------|--------------|---------|----------------|-----------|
| `api` | Backend API | `test-backend-api.sh` | postman-knowledge, postman-routing | postman |
| `db` | Backend Database | `test-backend-db.sh` | redis-development (if applicable) | — |
| `perf` | Backend Performance | `test-backend-perf.sh` | — | — |
| `security` | Backend Security | `test-backend-security.sh` | postman-security | github |
| `unit` | Frontend Unit | `test-frontend-unit.sh` | tdd | — |
| `integration` | Frontend Integration | `test-frontend-integration.sh` | tdd | — |
| `component` | Frontend Component | `test-frontend-component.sh` | tdd | — |
| `e2e` | Frontend E2E | `test-frontend-e2e.sh` | playwright-cli | — |
| `backend` | All Backend | api + db + perf + security | all backend skills | postman, github |
| `frontend` | All Frontend | unit + integration + component + e2e | all frontend skills | — |
| `full` | Everything | all scripts | all skills | all |
| `smoke` | Quick Smoke | config validation + secrets scan | — | — |

## Execution Workflow

### 1. Detect Phase

```bash
bash ~/.config/opencode/scripts/test-orchestrator.sh detect <project-path>
```

Returns JSON:
```json
{
  "language": "node",
  "framework": "react",
  "testTools": ["jest", "playwright"],
  "hasPostman": true,
  "hasDocker": false,
  "testDirs": ["tests/", "__tests__/"]
}
```

### 2. Plan Phase

Based on detection + user input, generate a test plan:

```
Test Plan:
  1. Backend API (12 endpoints via Postman)
  2. Backend Security (OWASP Top 10 + secret scan)
  3. Frontend Unit (45 tests via Jest)
  4. Frontend E2E (3 critical paths via Playwright)

Estimated time: 4 minutes
Parallel: yes (api + unit can run together)
```

### 3. Execute Phase

Run the appropriate scripts:

```bash
# Single test type
bash ~/.config/opencode/scripts/test-backend-api.sh <project-path> [options]

# All backend
bash ~/.config/opencode/scripts/test-orchestrator.sh backend <project-path>

# All frontend
bash ~/.config/opencode/scripts/test-orchestrator.sh frontend <project-path>

# Everything
bash ~/.config/opencode/scripts/test-orchestrator.sh full <project-path>
```

### 4. Report Phase

Scripts output structured results. Agent should:

1. Parse test output for pass/fail counts
2. Identify specific failures
3. Create GitHub issues for failures (using github MCP)
4. Save results to `tests/results/<type>-<date>.md`
5. Summarize for user

## Backend Test Categories

### API Testing
- Use Postman MCP to run collection tests
- Validate status codes, response schemas, headers
- Check contract compliance against OpenAPI spec
- Test error responses (4xx, 5xx)
- Verify pagination, filtering, sorting

### Database Testing
- Connection and query validation
- Data integrity checks
- Migration testing
- Transaction isolation
- For Redis: use redis-development skill rules

### Performance Testing
- Response time benchmarks (p50, p95, p99)
- Throughput (requests/sec)
- Memory usage under load
- Connection pool behavior
- Use k6, autocannon, or built-in timing

### Security Testing
- OWASP API Top 10 checks
- Authentication/authorization
- Input validation (SQLi, XSS, injection)
- Rate limiting
- Secret scanning
- CORS configuration
- TLS/HTTPS enforcement

## Frontend Test Categories

### Unit Testing
- Pure functions, utilities, hooks
- Fast (<100ms per test)
- No DOM, no network
- Use project's existing test runner (Jest, Vitest, pytest, etc.)

### Integration Testing
- Components with providers (Router, Context, Store)
- API mocking via MSW or similar
- User interactions (click, type, submit)
- State transitions
- **Largest layer** — most confidence per line

### Component Testing
- Isolated component rendering
- Props validation
- Event handling
- Accessibility (a11y) checks
- Visual regression (optional)

### E2E Testing
- Critical user journeys only
- Authentication flows
- Multi-page workflows
- Form submissions
- Use Playwright MCP skill
- Reserve for expensive failures

## Test Result Format

All scripts output in this format:

```
=== Test Results: <type> ===
Project: <path>
Date: <timestamp>

PASS  <count>  <description>
FAIL  <count>  <description>
WARN  <count>  <description>
SKIP  <count>  <description>

Total: <n> | Pass: <n> | Fail: <n> | Warn: <n> | Skip: <n>
Duration: <time>

Failed tests:
  - <specific failure 1>
  - <specific failure 2>
```

## Error Handling

- If project detection fails: ask user to specify language/framework
- If test tools not installed: offer to install or use alternative
- If tests fail: create GitHub issues with reproduction steps
- If MCP tools unavailable: fall back to CLI tools
- If no tests exist: offer to scaffold using TDD skill

## Best Practices

1. **Test behavior, not implementation** — verify what users see/do
2. **Integration tests > unit tests** for frontend (testing trophy)
3. **API tests > unit tests** for backend (contract validation)
4. **E2E only for critical paths** — expensive to maintain
5. **Parallelize where safe** — api + unit can run together
6. **Fast feedback first** — run smoke tests before full suite
7. **Persist results** — save to tests/results/ for tracking
