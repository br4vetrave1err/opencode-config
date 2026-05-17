#!/usr/bin/env bash
# Test Orchestrator — Main entry point for unified testing
# Usage: bash scripts/test-orchestrator.sh <type> <project-path> [options]
# Types: detect, smoke, backend, frontend, full, api, db, perf, security, unit, integration, component, e2e
# Exit 0: All tests pass
# Exit 1: One or more tests fail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_TYPE="${1:-}"
PROJECT_PATH="${2:-.}"
VERBOSE=""
PARALLEL=""
COVERAGE=""
TARGET=""
ENV=""
REPORT="console"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TOTAL_PASS=0
TOTAL_FAIL=0
TOTAL_WARN=0
TOTAL_SKIP=0
START_TIME=$(date +%s)
FAILED_TESTS=()

# Parse options
shift 2 2>/dev/null || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --verbose) VERBOSE=1; shift ;;
    --parallel) PARALLEL=1; shift ;;
    --coverage) COVERAGE=1; shift ;;
    --target) TARGET="$2"; shift 2 ;;
    --env) ENV="$2"; shift 2 ;;
    --report) REPORT="$2"; shift 2 ;;
    *) shift ;;
  esac
done

if [ -z "$TEST_TYPE" ]; then
  echo "Usage: $0 <type> <project-path> [options]"
  echo "Types: detect, smoke, backend, frontend, full, api, db, perf, security, unit, integration, component, e2e"
  exit 1
fi

if [ ! -d "$PROJECT_PATH" ]; then
  echo -e "${RED}ERROR${NC} Project path not found: $PROJECT_PATH"
  exit 1
fi

RESULTS_DIR="$PROJECT_PATH/tests/results"
mkdir -p "$RESULTS_DIR"

run_test_script() {
  local name="$1"
  local script="$2"
  local args="${3:-}"

  echo -e "${BLUE}▶ $name${NC}"

  if [ ! -f "$script" ]; then
    echo -e "${YELLOW}SKIP${NC} Script not found: $script"
    TOTAL_SKIP=$((TOTAL_SKIP + 1))
    return 0
  fi

  OUTPUT=$(bash "$script" "$PROJECT_PATH" $args 2>&1)
  EXIT_CODE=$?

  # Parse results from output
  pass=$(echo "$OUTPUT" | grep -oP 'PASS\s+\K\d+' | head -1 || echo "0")
  fail=$(echo "$OUTPUT" | grep -oP 'FAIL\s+\K\d+' | head -1 || echo "0")
  warn=$(echo "$OUTPUT" | grep -oP 'WARN\s+\K\d+' | head -1 || echo "0")
  skip=$(echo "$OUTPUT" | grep -oP 'SKIP\s+\K\d+' | head -1 || echo "0")

  # Default to exit code if no structured output
  if [ -z "$pass" ] || [ "$pass" = "0" ] && [ -z "$fail" ] || [ "$fail" = "0" ]; then
    if [ $EXIT_CODE -eq 0 ]; then
      pass=1
    else
      fail=1
    fi
  fi

  TOTAL_PASS=$((TOTAL_PASS + ${pass:-0}))
  TOTAL_FAIL=$((TOTAL_FAIL + ${fail:-0}))
  TOTAL_WARN=$((TOTAL_WARN + ${warn:-0}))
  TOTAL_SKIP=$((TOTAL_SKIP + ${skip:-0}))

  # Capture failed test descriptions
  while IFS= read -r line; do
    if [ -n "$line" ]; then
      FAILED_TESTS+=("[$name] $line")
    fi
  done < <(echo "$OUTPUT" | grep -A100 "Failed tests:" | tail -n +2 | grep "^  -" | sed 's/^  - //')

  if [ $EXIT_CODE -eq 0 ]; then
    echo -e "  ${GREEN}✓ Passed${NC} (pass=${pass:-0}, fail=${fail:-0}, warn=${warn:-0})"
  else
    echo -e "  ${RED}✗ Failed${NC} (pass=${pass:-0}, fail=${fail:-0}, warn=${warn:-0})"
  fi

  if [ -n "$VERBOSE" ]; then
    echo "$OUTPUT" | sed 's/^/    /'
  fi

  echo ""
}

# --- Detect Phase ---
if [ "$TEST_TYPE" = "detect" ]; then
  echo "=== Project Detection ==="
  echo "Scanning: $PROJECT_PATH"
  echo ""

  LANGUAGE=""
  FRAMEWORK=""
  TEST_TOOLS=""
  HAS_POSTMAN="false"
  HAS_DOCKER="false"
  HAS_PLAYWRIGHT="false"
  TEST_DIRS=""

  # Language detection
  [ -f "$PROJECT_PATH/package.json" ] && LANGUAGE="node"
  [ -f "$PROJECT_PATH/tsconfig.json" ] && FRAMEWORK="typescript"
  [ -f "$PROJECT_PATH/requirements.txt" ] || [ -f "$PROJECT_PATH/pyproject.toml" ] && LANGUAGE="python"
  [ -f "$PROJECT_PATH/pom.xml" ] && LANGUAGE="java"
  [ -f "$PROJECT_PATH/build.gradle" ] && LANGUAGE="java"
  [ -f "$PROJECT_PATH/go.mod" ] && LANGUAGE="go"
  [ -f "$PROJECT_PATH/Cargo.toml" ] && LANGUAGE="rust"

  # Framework detection
  if [ "$LANGUAGE" = "node" ]; then
    grep -q '"react"' "$PROJECT_PATH/package.json" 2>/dev/null && FRAMEWORK="${FRAMEWORK:+$FRAMEWORK, }react"
    grep -q '"vue"' "$PROJECT_PATH/package.json" 2>/dev/null && FRAMEWORK="${FRAMEWORK:+$FRAMEWORK, }vue"
    grep -q '"next"' "$PROJECT_PATH/package.json" 2>/dev/null && FRAMEWORK="${FRAMEWORK:+$FRAMEWORK, }nextjs"
    grep -q '"express"' "$PROJECT_PATH/package.json" 2>/dev/null && FRAMEWORK="${FRAMEWORK:+$FRAMEWORK, }express"
    grep -q '"fastify"' "$PROJECT_PATH/package.json" 2>/dev/null && FRAMEWORK="${FRAMEWORK:+$FRAMEWORK, }fastify"
  fi
  [ -f "$PROJECT_PATH/tsconfig.json" ] && FRAMEWORK="${FRAMEWORK:+$FRAMEWORK, }typescript"

  # Test tool detection
  [ -f "$PROJECT_PATH/jest.config.js" ] || [ -f "$PROJECT_PATH/jest.config.ts" ] && TEST_TOOLS="$TEST_TOOLS jest"
  [ -f "$PROJECT_PATH/vitest.config.ts" ] || [ -f "$PROJECT_PATH/vitest.config.js" ] && TEST_TOOLS="$TEST_TOOLS vitest"
  [ -f "$PROJECT_PATH/playwright.config.ts" ] || [ -f "$PROJECT_PATH/playwright.config.js" ] && { TEST_TOOLS="$TEST_TOOLS playwright"; HAS_PLAYWRIGHT="true"; }
  [ -f "$PROJECT_PATH/pytest.ini" ] || grep -q "pytest" "$PROJECT_PATH/pyproject.toml" 2>/dev/null && TEST_TOOLS="$TEST_TOOLS pytest"
  [ -d "$PROJECT_PATH/postman" ] || find "$PROJECT_PATH" -maxdepth 2 -name "*postman*" -type f 2>/dev/null | head -1 | grep -q . && HAS_POSTMAN="true"
  [ -f "$PROJECT_PATH/docker-compose.yml" ] && HAS_DOCKER="true"

  # Test directory detection
  [ -d "$PROJECT_PATH/tests" ] && TEST_DIRS="$TEST_DIRS tests/"
  [ -d "$PROJECT_PATH/__tests__" ] && TEST_DIRS="$TEST_DIRS __tests__/"
  [ -d "$PROJECT_PATH/test" ] && TEST_DIRS="$TEST_DIRS test/"
  [ -d "$PROJECT_PATH/spec" ] && TEST_DIRS="$TEST_DIRS spec/"

  echo "Language: ${LANGUAGE:-unknown}"
  echo "Framework: ${FRAMEWORK:-none}"
  echo "Test Tools: ${TEST_TOOLS:-none}"
  echo "Has Postman: $HAS_POSTMAN"
  echo "Has Docker: $HAS_DOCKER"
  echo "Has Playwright: $HAS_PLAYWRIGHT"
  echo "Test Dirs: ${TEST_DIRS:-none}"

  exit 0
fi

# --- Smoke Tests ---
if [ "$TEST_TYPE" = "smoke" ] || [ "$TEST_TYPE" = "full" ]; then
  echo "=== Smoke Tests ==="
  echo ""
  run_test_script "Config Validation" "$SCRIPT_DIR/validate-config.sh"
  run_test_script "Secrets Scan" "$SCRIPT_DIR/secrets-scan.sh"
  echo ""
fi

# --- Backend Tests ---
if [ "$TEST_TYPE" = "backend" ] || [ "$TEST_TYPE" = "full" ] || [ "$TEST_TYPE" = "api" ]; then
  echo "=== Backend Tests ==="
  echo ""
  run_test_script "API Tests" "$SCRIPT_DIR/test-backend-api.sh" "--postman"
  echo ""
fi

if [ "$TEST_TYPE" = "backend" ] || [ "$TEST_TYPE" = "full" ] || [ "$TEST_TYPE" = "db" ]; then
  run_test_script "Database Tests" "$SCRIPT_DIR/test-backend-db.sh"
  echo ""
fi

if [ "$TEST_TYPE" = "backend" ] || [ "$TEST_TYPE" = "full" ] || [ "$TEST_TYPE" = "perf" ]; then
  run_test_script "Performance Tests" "$SCRIPT_DIR/test-backend-perf.sh"
  echo ""
fi

if [ "$TEST_TYPE" = "backend" ] || [ "$TEST_TYPE" = "full" ] || [ "$TEST_TYPE" = "security" ]; then
  run_test_script "Security Tests" "$SCRIPT_DIR/test-backend-security.sh"
  echo ""
fi

# --- Frontend Tests ---
if [ "$TEST_TYPE" = "frontend" ] || [ "$TEST_TYPE" = "full" ] || [ "$TEST_TYPE" = "unit" ]; then
  echo "=== Frontend Tests ==="
  echo ""
  run_test_script "Unit Tests" "$SCRIPT_DIR/test-frontend-unit.sh"
  echo ""
fi

if [ "$TEST_TYPE" = "frontend" ] || [ "$TEST_TYPE" = "full" ] || [ "$TEST_TYPE" = "integration" ]; then
  run_test_script "Integration Tests" "$SCRIPT_DIR/test-frontend-integration.sh"
  echo ""
fi

if [ "$TEST_TYPE" = "frontend" ] || [ "$TEST_TYPE" = "full" ] || [ "$TEST_TYPE" = "component" ]; then
  run_test_script "Component Tests" "$SCRIPT_DIR/test-frontend-component.sh"
  echo ""
fi

if [ "$TEST_TYPE" = "frontend" ] || [ "$TEST_TYPE" = "full" ] || [ "$TEST_TYPE" = "e2e" ]; then
  run_test_script "E2E Tests" "$SCRIPT_DIR/test-frontend-e2e.sh"
  echo ""
fi

# --- Summary ---
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "=== Test Results Summary ==="
echo "Type: $TEST_TYPE"
echo "Project: $PROJECT_PATH"
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo -e "Total:  $((TOTAL_PASS + TOTAL_FAIL + TOTAL_WARN + TOTAL_SKIP))"
echo -e "${GREEN}Pass:   $TOTAL_PASS${NC}"
echo -e "${RED}Fail:   $TOTAL_FAIL${NC}"
echo -e "${YELLOW}Warn:   $TOTAL_WARN${NC}"
echo -e "Skip:   $TOTAL_SKIP"
echo "Duration: ${DURATION}s"

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
  echo ""
  echo "Failed tests:"
  for f in "${FAILED_TESTS[@]}"; do
    echo "  - $f"
  done
fi

# Save results
TIMESTAMP=$(date '+%Y-%m-%d_%H%M%S')
RESULT_FILE="$RESULTS_DIR/${TEST_TYPE}-${TIMESTAMP}.md"
{
  echo "# Test Results: $TEST_TYPE"
  echo ""
  echo "- **Project:** $PROJECT_PATH"
  echo "- **Date:** $(date '+%Y-%m-%d %H:%M:%S')"
  echo "- **Duration:** ${DURATION}s"
  echo ""
  echo "| Metric | Count |"
  echo "|--------|-------|"
  echo "| Total | $((TOTAL_PASS + TOTAL_FAIL + TOTAL_WARN + TOTAL_SKIP)) |"
  echo "| Pass | $TOTAL_PASS |"
  echo "| Fail | $TOTAL_FAIL |"
  echo "| Warn | $TOTAL_WARN |"
  echo "| Skip | $TOTAL_SKIP |"
  echo ""
  if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    echo "## Failed Tests"
    echo ""
    for f in "${FAILED_TESTS[@]}"; do
      echo "- $f"
    done
  fi
} > "$RESULT_FILE"

echo ""
echo "Results saved to: $RESULT_FILE"

if [ $TOTAL_FAIL -gt 0 ]; then
  exit 1
fi

exit 0
