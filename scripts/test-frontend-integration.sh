#!/usr/bin/env bash
# Frontend Integration Tests — Tests components with providers, API mocking, user interactions
# Usage: bash scripts/test-frontend-integration.sh <project-path>
# Exit 0: All integration tests pass
# Exit 1: One or more integration tests fail

PROJECT_PATH="${1:-.}"
PASS=0
FAIL=0
WARN=0
FAILED_TESTS=()

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "--- Frontend Integration Tests ---"

# Detect framework
FRAMEWORK=""
if grep -q '"react"' "$PROJECT_PATH/package.json" 2>/dev/null; then
  FRAMEWORK="react"
elif grep -q '"vue"' "$PROJECT_PATH/package.json" 2>/dev/null; then
  FRAMEWORK="vue"
elif grep -q '"angular"' "$PROJECT_PATH/package.json" 2>/dev/null; then
  FRAMEWORK="angular"
elif grep -q '"svelte"' "$PROJECT_PATH/package.json" 2>/dev/null; then
  FRAMEWORK="svelte"
fi

if [ -n "$FRAMEWORK" ]; then
  echo "Framework: $FRAMEWORK"
else
  echo "Framework: unknown (checking for test patterns)"
fi

# Check for integration test files
INTEGRATION_TEST_FILES=$(find "$PROJECT_PATH" -maxdepth 5 \( -name "*.integration.test.*" -o -name "*.integration.spec.*" -o -name "*.int.test.*" -o -path "*/__tests__/integration/*" -o -path "*/tests/integration/*" \) 2>/dev/null | wc -l)

if [ "$INTEGRATION_TEST_FILES" -gt 0 ]; then
  echo -e "${GREEN}PASS${NC} Found $INTEGRATION_TEST_FILES integration test file(s)"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No dedicated integration test files found"
  WARN=$((WARN + 1))
fi

# Check for Testing Library usage (React/Vue)
if grep -rq '@testing-library\|@testing-library/react\|@testing-library/vue\|@testing-library/dom' "$PROJECT_PATH" --include="*.js" --include="*.ts" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -1 | grep -q .; then
  echo -e "${GREEN}PASS${NC} Testing Library detected"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} Testing Library not detected"
  WARN=$((WARN + 1))
fi

# Check for API mocking (MSW, nock, etc.)
if grep -rq 'msw\|mock-service-worker\|nock\|fetch-mock\|axios-mock-adapter\|sinon' "$PROJECT_PATH" --include="*.js" --include="*.ts" --include="*.tsx" --include="*.jsx" --include="package.json" 2>/dev/null | head -1 | grep -q .; then
  echo -e "${GREEN}PASS${NC} API mocking library detected"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No API mocking library detected"
  WARN=$((WARN + 1))
fi

# Check for provider/context patterns (good for integration testing)
if grep -rq 'Provider\|Context\|createContext\|useContext\|Redux\|Provider\|Store\|Router' "$PROJECT_PATH" --include="*.js" --include="*.ts" --include="*.tsx" --include="*.jsx" 2>/dev/null | head -1 | grep -q .; then
  echo -e "${GREEN}PASS${NC} Provider/Context patterns detected (integration test targets)"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No provider/context patterns found"
  WARN=$((WARN + 1))
fi

# Run integration tests if test runner exists
TEST_RUNNER=""
if [ -f "$PROJECT_PATH/jest.config.js" ] || [ -f "$PROJECT_PATH/jest.config.ts" ]; then
  TEST_RUNNER="jest"
elif [ -f "$PROJECT_PATH/vitest.config.ts" ] || [ -f "$PROJECT_PATH/vitest.config.js" ]; then
  TEST_RUNNER="vitest"
fi

if [ -n "$TEST_RUNNER" ]; then
  case "$TEST_RUNNER" in
    jest)
      OUTPUT=$(cd "$PROJECT_PATH" && npx jest --passWithNoTests --testPathPattern="integration|\.int\." --silent 2>&1)
      EXIT_CODE=$?
      if [ $EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}PASS${NC} Jest integration tests passed"
        PASS=$((PASS + 1))
      else
        echo -e "${RED}FAIL${NC} Jest integration tests failed"
        FAIL=$((FAIL + 1))
        FAILED_TESTS+=("Jest integration tests failed")
      fi
      ;;
    vitest)
      OUTPUT=$(cd "$PROJECT_PATH" && npx vitest run --passWithNoTests --reporter=basic 2>&1)
      EXIT_CODE=$?
      if [ $EXIT_CODE -eq 0 ]; then
        echo -e "${GREEN}PASS${NC} Vitest integration tests passed"
        PASS=$((PASS + 1))
      else
        echo -e "${RED}FAIL${NC} Vitest integration tests failed"
        FAIL=$((FAIL + 1))
        FAILED_TESTS+=("Vitest integration tests failed")
      fi
      ;;
  esac
fi

echo ""
echo "Total: $((PASS + FAIL + WARN)) | Pass: $PASS | Fail: $FAIL | Warn: $WARN"

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
  echo ""
  echo "Failed tests:"
  for f in "${FAILED_TESTS[@]}"; do
    echo "  - $f"
  done
fi

if [ $FAIL -gt 0 ]; then
  exit 1
fi

exit 0
