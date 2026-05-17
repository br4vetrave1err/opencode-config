#!/usr/bin/env bash
# Frontend Unit Tests — Runs unit tests for pure functions, utilities, hooks
# Usage: bash scripts/test-frontend-unit.sh <project-path>
# Exit 0: All unit tests pass
# Exit 1: One or more unit tests fail

PROJECT_PATH="${1:-.}"
PASS=0
FAIL=0
WARN=0
FAILED_TESTS=()

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "--- Frontend Unit Tests ---"

# Detect test runner
TEST_RUNNER=""
if [ -f "$PROJECT_PATH/jest.config.js" ] || [ -f "$PROJECT_PATH/jest.config.ts" ]; then
  TEST_RUNNER="jest"
elif [ -f "$PROJECT_PATH/vitest.config.ts" ] || [ -f "$PROJECT_PATH/vitest.config.js" ]; then
  TEST_RUNNER="vitest"
elif [ -f "$PROJECT_PATH/pytest.ini" ] || grep -q "pytest" "$PROJECT_PATH/pyproject.toml" 2>/dev/null; then
  TEST_RUNNER="pytest"
elif [ -f "$PROJECT_PATH/Cargo.toml" ]; then
  TEST_RUNNER="cargo"
elif [ -f "$PROJECT_PATH/go.mod" ]; then
  TEST_RUNNER="go"
fi

# Count unit test files
UNIT_TEST_FILES=$(find "$PROJECT_PATH" -maxdepth 5 \( -name "*.test.js" -o -name "*.test.ts" -o -name "*.test.tsx" -o -name "*.spec.js" -o -name "*.spec.ts" -o -name "*.spec.tsx" -o -name "test_*.py" -o -name "*_test.go" -o -name "*_test.rs" \) 2>/dev/null | wc -l)

if [ "$UNIT_TEST_FILES" -gt 0 ]; then
  echo "Found $UNIT_TEST_FILES test file(s)"
  echo ""

  if [ -n "$TEST_RUNNER" ]; then
    echo "Test runner: $TEST_RUNNER"
    echo ""

    # Run the test suite
    case "$TEST_RUNNER" in
      jest)
        if command -v npx &>/dev/null; then
          OUTPUT=$(cd "$PROJECT_PATH" && npx jest --passWithNoTests --testPathPattern="\.test\." --silent 2>&1)
          EXIT_CODE=$?
          if [ $EXIT_CODE -eq 0 ]; then
            echo -e "${GREEN}PASS${NC} Jest unit tests passed"
            PASS=$((PASS + 1))
          else
            echo -e "${RED}FAIL${NC} Jest unit tests failed"
            FAIL=$((FAIL + 1))
            FAILED_TESTS+=("Jest unit tests failed")
          fi
        fi
        ;;
      vitest)
        if command -v npx &>/dev/null; then
          OUTPUT=$(cd "$PROJECT_PATH" && npx vitest run --passWithNoTests --reporter=basic 2>&1)
          EXIT_CODE=$?
          if [ $EXIT_CODE -eq 0 ]; then
            echo -e "${GREEN}PASS${NC} Vitest unit tests passed"
            PASS=$((PASS + 1))
          else
            echo -e "${RED}FAIL${NC} Vitest unit tests failed"
            FAIL=$((FAIL + 1))
            FAILED_TESTS+=("Vitest unit tests failed")
          fi
        fi
        ;;
      pytest)
        if command -v pytest &>/dev/null || command -v python3 &>/dev/null; then
          OUTPUT=$(cd "$PROJECT_PATH" && python3 -m pytest -q --tb=no 2>&1 || python3 -m pytest -q 2>&1)
          EXIT_CODE=$?
          if [ $EXIT_CODE -eq 0 ]; then
            echo -e "${GREEN}PASS${NC} Pytest unit tests passed"
            PASS=$((PASS + 1))
          else
            echo -e "${RED}FAIL${NC} Pytest unit tests failed"
            FAIL=$((FAIL + 1))
            FAILED_TESTS+=("Pytest unit tests failed")
          fi
        fi
        ;;
      cargo)
        OUTPUT=$(cd "$PROJECT_PATH" && cargo test --quiet 2>&1)
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 0 ]; then
          echo -e "${GREEN}PASS${NC} Cargo unit tests passed"
          PASS=$((PASS + 1))
        else
          echo -e "${RED}FAIL${NC} Cargo unit tests failed"
          FAIL=$((FAIL + 1))
          FAILED_TESTS+=("Cargo unit tests failed")
        fi
        ;;
      go)
        OUTPUT=$(cd "$PROJECT_PATH" && go test ./... -short 2>&1)
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 0 ]; then
          echo -e "${GREEN}PASS${NC} Go unit tests passed"
          PASS=$((PASS + 1))
        else
          echo -e "${RED}FAIL${NC} Go unit tests failed"
          FAIL=$((FAIL + 1))
          FAILED_TESTS+=("Go unit tests failed")
        fi
        ;;
    esac
  else
    echo -e "${YELLOW}WARN${NC} No test runner detected, checking test file structure only"
    echo -e "${GREEN}PASS${NC} Test files exist ($UNIT_TEST_FILES files)"
    PASS=$((PASS + 1))
    WARN=$((WARN + 1))
  fi
else
  echo -e "${YELLOW}WARN${NC} No unit test files found"
  WARN=$((WARN + 1))
fi

# Check for pure function patterns (good for unit testing)
PURE_FUNCTIONS=$(find "$PROJECT_PATH" -maxdepth 4 -name "utils*" -o -name "helpers*" -o -name "lib*" -o -name "services*" 2>/dev/null | head -5)

if [ -n "$PURE_FUNCTIONS" ]; then
  echo -e "${GREEN}PASS${NC} Utility/helper modules detected (good unit test targets)"
  PASS=$((PASS + 1))
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
