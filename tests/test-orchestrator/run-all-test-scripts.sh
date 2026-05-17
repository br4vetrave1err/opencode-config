#!/usr/bin/env bash
# Test Orchestrator Tests — Tests for all test scripts
# Run: bash tests/test-orchestrator/run-all-test-scripts.sh

PASS=0
FAIL=0
TOTAL=0

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

assert_exit() {
  local name="$1"
  local expected="$2"
  local actual="$3"
  TOTAL=$((TOTAL + 1))
  if [ "$actual" -eq "$expected" ]; then
    echo -e "${GREEN}PASS${NC} $name (exit=$actual)"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}FAIL${NC} $name (expected exit=$expected, got=$actual)"
    FAIL=$((FAIL + 1))
  fi
}

assert_output_contains() {
  local name="$1"
  local expected="$2"
  local actual="$3"
  TOTAL=$((TOTAL + 1))
  if echo "$actual" | grep -qi "$expected"; then
    echo -e "${GREEN}PASS${NC} $name"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}FAIL${NC} $name (expected '$expected' in output)"
    FAIL=$((FAIL + 1))
  fi
}

FIXTURE_DIR=$(mktemp -d)
trap "rm -rf $FIXTURE_DIR" EXIT

FIXTURE() {
  local name="$1"
  local dir="$FIXTURE_DIR/$name"
  rm -rf "$dir"
  mkdir -p "$dir"
  echo "$dir"
}

SCRIPT_DIR="$(cd "$(dirname "$0")/../.." && pwd)/scripts"

echo "=== Test Orchestrator Tests ==="
echo ""

# ==========================================
# Test Orchestrator Script Tests
# ==========================================

# Test 1: Detect command
echo "--- Orchestrator: Detect ---"
F=$(FIXTURE "t1-detect")
cat > "$F/package.json" << 'EOF'
{"name": "test-app", "dependencies": {"react": "^18.0.0", "express": "^4.0.0"}}
EOF
touch "$F/tsconfig.json" "$F/playwright.config.ts" "$F/jest.config.js" "$F/docker-compose.yml"
mkdir -p "$F/tests"
OUTPUT=$("$SCRIPT_DIR/test-orchestrator.sh" detect "$F" 2>&1)
EXIT_CODE=$?
assert_exit "detects node" 0 $EXIT_CODE
assert_output_contains "detects typescript" "typescript" "$OUTPUT"
assert_output_contains "detects playwright" "true" "$OUTPUT"
assert_output_contains "detects jest" "jest" "$OUTPUT"
assert_output_contains "detects docker" "true" "$OUTPUT"

# Test 2: Detect with no markers
echo ""
echo "--- Orchestrator: Empty Project ---"
F=$(FIXTURE "t2-empty")
OUTPUT=$("$SCRIPT_DIR/test-orchestrator.sh" detect "$F" 2>&1)
EXIT_CODE=$?
assert_exit "detect on empty project" 0 $EXIT_CODE
assert_output_contains "unknown language" "unknown" "$OUTPUT"

# Test 3: Invalid project path
echo ""
echo "--- Orchestrator: Invalid Path ---"
OUTPUT=$("$SCRIPT_DIR/test-orchestrator.sh" detect "/nonexistent" 2>&1)
EXIT_CODE=$?
assert_exit "invalid path fails" 1 $EXIT_CODE

# Test 4: No arguments
echo ""
echo "--- Orchestrator: No Arguments ---"
OUTPUT=$("$SCRIPT_DIR/test-orchestrator.sh" 2>&1)
EXIT_CODE=$?
assert_exit "no arguments shows usage" 1 $EXIT_CODE
assert_output_contains "shows usage" "Usage" "$OUTPUT"

# ==========================================
# Backend API Test Script Tests
# ==========================================

echo ""
echo "--- Backend API: OpenAPI Spec ---"
F=$(FIXTURE "t3-api-openapi")
cat > "$F/openapi.json" << 'EOF'
{"openapi": "3.0.0", "info": {"title": "Test API", "version": "1.0.0"}, "paths": {}}
EOF
mkdir -p "$F/src"
echo 'try { handleRequest() } catch (e) { handleError(e) }' > "$F/src/app.js"
OUTPUT=$("$SCRIPT_DIR/test-backend-api.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "valid OpenAPI spec passes" 0 $EXIT_CODE
assert_output_contains "detects OpenAPI" "OpenAPI" "$OUTPUT"

# Test 6: Invalid OpenAPI spec
echo ""
echo "--- Backend API: Invalid OpenAPI ---"
F=$(FIXTURE "t4-api-invalid")
echo '{bad json' > "$F/openapi.json"
OUTPUT=$("$SCRIPT_DIR/test-backend-api.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "invalid OpenAPI fails" 1 $EXIT_CODE

# Test 7: Error handling patterns
echo ""
echo "--- Backend API: Error Handling ---"
F=$(FIXTURE "t5-api-error-handling")
mkdir -p "$F/src"
echo 'try { doSomething() } catch (e) { handleError(e) }' > "$F/src/app.js"
OUTPUT=$("$SCRIPT_DIR/test-backend-api.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "error handling detected" 0 $EXIT_CODE

# ==========================================
# Backend Database Test Script Tests
# ==========================================

echo ""
echo "--- Backend DB: PostgreSQL Detection ---"
F=$(FIXTURE "t6-db-postgres")
mkdir -p "$F/src"
echo 'DATABASE_URL=postgresql://localhost:5432/mydb' > "$F/.env"
OUTPUT=$("$SCRIPT_DIR/test-backend-db.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "PostgreSQL detected" 0 $EXIT_CODE
assert_output_contains "detects postgresql" "postgresql" "$OUTPUT"

# Test 9: Redis detection
echo ""
echo "--- Backend DB: Redis Detection ---"
F=$(FIXTURE "t7-db-redis")
mkdir -p "$F/src"
echo 'REDIS_URL=redis://localhost:6379' > "$F/.env"
OUTPUT=$("$SCRIPT_DIR/test-backend-db.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "Redis detected" 0 $EXIT_CODE
assert_output_contains "detects redis" "redis" "$OUTPUT"

# Test 10: Connection pooling
echo ""
echo "--- Backend DB: Connection Pooling ---"
F=$(FIXTURE "t8-db-pooling")
mkdir -p "$F/src"
echo 'const pool = new Pool({ connectionString: process.env.DATABASE_URL });' > "$F/src/db.js"
OUTPUT=$("$SCRIPT_DIR/test-backend-db.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "connection pooling detected" 0 $EXIT_CODE

# ==========================================
# Backend Performance Test Script Tests
# ==========================================

echo ""
echo "--- Backend Perf: k6 Config ---"
F=$(FIXTURE "t9-perf-k6")
cat > "$F/k6-test.js" << 'EOF'
import http from 'k6/http';
export default function() { http.get('http://localhost:3000'); }
EOF
OUTPUT=$("$SCRIPT_DIR/test-backend-perf.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "k6 config detected" 0 $EXIT_CODE
assert_output_contains "detects k6 config" "k6" "$OUTPUT"

# Test 12: Caching detection
echo ""
echo "--- Backend Perf: Caching ---"
F=$(FIXTURE "t10-perf-cache")
mkdir -p "$F/src"
echo 'const cache = new Redis();' > "$F/src/cache.js"
OUTPUT=$("$SCRIPT_DIR/test-backend-perf.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "caching detected" 0 $EXIT_CODE

# Test 13: Rate limiting detection
echo ""
echo "--- Backend Perf: Rate Limiting ---"
F=$(FIXTURE "t11-perf-ratelimit")
mkdir -p "$F/src"
echo 'app.use(rateLimit({ windowMs: 15 * 60 * 1000, max: 100 }));' > "$F/src/middleware.js"
OUTPUT=$("$SCRIPT_DIR/test-backend-perf.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "rate limiting detected" 0 $EXIT_CODE

# ==========================================
# Backend Security Test Script Tests
# ==========================================

echo ""
echo "--- Backend Security: Auth Middleware ---"
F=$(FIXTURE "t12-sec-auth")
mkdir -p "$F/src"
cat > "$F/src/app.js" << 'EOF'
app.use(authMiddleware());
const jwt = require("jsonwebtoken");
const schema = z.object({ name: z.string() });
app.use(cors({ origin: "*" }));
EOF
OUTPUT=$("$SCRIPT_DIR/test-backend-security.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "auth middleware detected" 0 $EXIT_CODE
assert_output_contains "detects auth" "authentication" "$OUTPUT"

# Test 15: Input validation
echo ""
echo "--- Backend Security: Input Validation ---"
F=$(FIXTURE "t13-sec-validation")
mkdir -p "$F/src"
cat > "$F/src/validation.js" << 'EOF'
const schema = z.object({ name: z.string(), email: z.string().email() });
app.use(authMiddleware());
app.use(cors());
EOF
OUTPUT=$("$SCRIPT_DIR/test-backend-security.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "input validation detected" 0 $EXIT_CODE

# Test 16: CORS configuration
echo ""
echo "--- Backend Security: CORS ---"
F=$(FIXTURE "t14-sec-cors")
mkdir -p "$F/src"
cat > "$F/src/app.js" << 'EOF'
app.use(cors({ origin: "https://example.com" }));
app.use(authMiddleware());
const schema = z.object({ name: z.string() });
EOF
OUTPUT=$("$SCRIPT_DIR/test-backend-security.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "CORS detected" 0 $EXIT_CODE

# Test 17: No hardcoded credentials
echo ""
echo "--- Backend Security: No Hardcoded Creds ---"
F=$(FIXTURE "t15-sec-no-creds")
mkdir -p "$F/src"
cat > "$F/src/config.js" << 'EOF'
const apiKey = process.env.API_KEY;
app.use(authMiddleware());
const schema = z.object({ name: z.string() });
app.use(cors());
EOF
OUTPUT=$("$SCRIPT_DIR/test-backend-security.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "no hardcoded credentials" 0 $EXIT_CODE

# ==========================================
# Frontend Unit Test Script Tests
# ==========================================

echo ""
echo "--- Frontend Unit: Test Files ---"
F=$(FIXTURE "t16-fe-unit")
cat > "$F/package.json" << 'EOF'
{"name": "test-app", "dependencies": {"react": "^18.0.0"}}
EOF
mkdir -p "$F/src/__tests__"
echo 'test("adds 1+1=2", () => { expect(1+1).toBe(2); });' > "$F/src/__tests__/math.test.js"
OUTPUT=$("$SCRIPT_DIR/test-frontend-unit.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "unit test files found" 0 $EXIT_CODE
assert_output_contains "detects test files" "test file" "$OUTPUT"

# Test 19: Utility modules
echo ""
echo "--- Frontend Unit: Utils ---"
F=$(FIXTURE "t17-fe-utils")
mkdir -p "$F/src/utils"
echo 'export const add = (a, b) => a + b;' > "$F/src/utils/math.js"
OUTPUT=$("$SCRIPT_DIR/test-frontend-unit.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "utils detected" 0 $EXIT_CODE

# ==========================================
# Frontend Integration Test Script Tests
# ==========================================

echo ""
echo "--- Frontend Integration: Testing Library ---"
F=$(FIXTURE "t18-fe-integration")
cat > "$F/package.json" << 'EOF'
{"name": "test-app", "dependencies": {"react": "^18.0.0", "@testing-library/react": "^14.0.0"}}
EOF
mkdir -p "$F/src/__tests__/integration"
echo 'test("renders component", () => {});' > "$F/src/__tests__/integration/app.integration.test.tsx"
OUTPUT=$("$SCRIPT_DIR/test-frontend-integration.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "testing library detected" 0 $EXIT_CODE
assert_output_contains "detects testing library" "Testing Library" "$OUTPUT"

# Test 21: API mocking
echo ""
echo "--- Frontend Integration: API Mocking ---"
F=$(FIXTURE "t19-fe-mocking")
cat > "$F/package.json" << 'EOF'
{"name": "test-app", "devDependencies": {"msw": "^2.0.0"}}
EOF
OUTPUT=$("$SCRIPT_DIR/test-frontend-integration.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "API mocking detected" 0 $EXIT_CODE

# ==========================================
# Frontend Component Test Script Tests
# ==========================================

echo ""
echo "--- Frontend Component: Components ---"
F=$(FIXTURE "t20-fe-component")
cat > "$F/package.json" << 'EOF'
{"name": "test-app", "dependencies": {"react": "^18.0.0"}}
EOF
mkdir -p "$F/src/components"
echo 'export const Button = () => <button>Click</button>;' > "$F/src/components/Button.tsx"
OUTPUT=$("$SCRIPT_DIR/test-frontend-component.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "components detected" 0 $EXIT_CODE
assert_output_contains "detects components" "component" "$OUTPUT"

# Test 23: Storybook
echo ""
echo "--- Frontend Component: Storybook ---"
F=$(FIXTURE "t21-fe-storybook")
cat > "$F/package.json" << 'EOF'
{"name": "test-app", "devDependencies": {"storybook": "^7.0.0"}}
EOF
mkdir -p "$F/.storybook"
echo 'module.exports = {}' > "$F/.storybook/main.js"
OUTPUT=$("$SCRIPT_DIR/test-frontend-component.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "storybook detected" 0 $EXIT_CODE

# ==========================================
# Frontend E2E Test Script Tests
# ==========================================

echo ""
echo "--- Frontend E2E: Playwright Config ---"
F=$(FIXTURE "t22-fe-e2e")
echo 'export default { testDir: "./e2e" };' > "$F/playwright.config.ts"
OUTPUT=$("$SCRIPT_DIR/test-frontend-e2e.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "playwright config detected" 0 $EXIT_CODE
assert_output_contains "detects playwright" "Playwright" "$OUTPUT"

# Test 25: E2E test files
echo ""
echo "--- Frontend E2E: Test Files ---"
F=$(FIXTURE "t23-fe-e2e-files")
mkdir -p "$F/e2e"
echo 'test("checkout", () => {});' > "$F/e2e/checkout.e2e.test.ts"
echo 'test("registration", () => {});' > "$F/e2e/registration.e2e.test.ts"
OUTPUT=$("$SCRIPT_DIR/test-frontend-e2e.sh" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "e2e files found" 0 $EXIT_CODE
assert_output_contains "detects e2e files" "E2E test file" "$OUTPUT"

# ==========================================
# Summary
# ==========================================

echo ""
echo "=== Results ==="
echo -e "Total:  $TOTAL"
echo -e "${GREEN}Pass:   $PASS${NC}"
echo -e "${RED}Fail:   $FAIL${NC}"

if [ $FAIL -gt 0 ]; then
  exit 1
fi
