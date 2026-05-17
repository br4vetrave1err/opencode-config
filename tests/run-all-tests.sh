#!/usr/bin/env bash
# Test Runner — Runs all config validation tests
# Run: bash tests/run-all-tests.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_DIR="$SCRIPT_DIR"

PASS=0
FAIL=0
TOTAL=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "========================================="
echo "  OpenCode Config — Test Suite"
echo "========================================="
echo ""

TESTS=(
  "config-validation/test-secrets-scan.sh:Secrets Scanner"
  "config-validation/test-validate-config.sh:Config Validation"
  "config-validation/test-detect-drift.sh:Drift Detection"
  "config-validation/test-generate-changelog.sh:Changelog Generator"
  "test-orchestrator/run-all-test-scripts.sh:Test Orchestrator"
)

for test_entry in "${TESTS[@]}"; do
  IFS=':' read -r file name <<< "$test_entry"
  test_file="$TEST_DIR/$file"

  echo -e "${BLUE}▶ $name${NC}"

  if [ ! -f "$test_file" ]; then
    echo -e "${YELLOW}SKIP${NC} $file not found"
    echo ""
    continue
  fi

  # Capture output and exit code
  OUTPUT=$(bash "$test_file" 2>&1)
  EXIT_CODE=$?

  # Extract pass/fail counts from test output
  test_pass=$(echo "$OUTPUT" | grep -oP 'Pass:\s+\K\d+' || echo "0")
  test_fail=$(echo "$OUTPUT" | grep -oP 'Fail:\s+\K\d+' || echo "0")
  test_total=$(echo "$OUTPUT" | grep -oP 'Total:\s+\K\d+' || echo "0")

  PASS=$((PASS + test_pass))
  FAIL=$((FAIL + test_fail))
  TOTAL=$((TOTAL + test_total))

  if [ $EXIT_CODE -eq 0 ]; then
    echo -e "  ${GREEN}✓ $test_pass/$test_total passed${NC}"
  else
    echo -e "  ${RED}✗ $test_fail/$test_total failed${NC}"
  fi
  echo ""
done

echo "========================================="
echo "  Results"
echo "========================================="
echo -e "Total:  $TOTAL"
echo -e "${GREEN}Pass:   $PASS${NC}"
echo -e "${RED}Fail:   $FAIL${NC}"
echo ""

if [ $FAIL -gt 0 ]; then
  echo -e "${RED}Some tests failed${NC}"
  exit 1
else
  echo -e "${GREEN}All tests passed${NC}"
  exit 0
fi
