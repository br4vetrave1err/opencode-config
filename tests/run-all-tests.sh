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
  "config-validation/test-auto-sync.sh:Auto-Sync & Docs"
  "test-orchestrator/run-all-test-scripts.sh:Test Orchestrator"
)

for test_entry in "${TESTS[@]}"; do
  IFS=':' read -r test_file test_name <<< "$test_entry"
  test_path="$TEST_DIR/$test_file"

  if [ ! -f "$test_path" ]; then
    echo -e "${YELLOW}SKIP${NC} $test_file not found"
    continue
  fi

  echo -e "${BLUE}▶ $test_name${NC}"

  # Capture output
  output=$(bash "$test_path" 2>&1)
  exit_code=$?

  # Extract pass/fail counts from test output
  test_pass=$(echo "$output" | grep -oP 'Pass:\s+\K\d+' | tail -1)
  test_fail=$(echo "$output" | grep -oP 'Fail:\s+\K\d+' | tail -1)
  test_total=$(echo "$output" | grep -oP 'Total:\s+\K\d+' | tail -1)

  if [ -z "$test_pass" ]; then
    # Fallback: count PASS/FAIL lines
    test_pass=$(echo "$output" | grep -c "PASS" || echo "0")
    test_fail=$(echo "$output" | grep -c "FAIL" || echo "0")
    test_total=$((test_pass + test_fail))
  fi

  TOTAL=$((TOTAL + test_total))
  PASS=$((PASS + test_pass))
  FAIL=$((FAIL + test_fail))

  if [ $test_fail -eq 0 ]; then
    echo -e "  ${GREEN}✓ $test_pass/$test_total passed${NC}"
  else
    echo -e "  ${RED}✗ $test_fail/$test_total failed${NC}"
  fi
  echo ""
done

echo "========================================="
echo "  Results"
echo "========================================="
echo "Total:  $TOTAL"
echo -e "${GREEN}Pass:   $PASS${NC}"
echo -e "${RED}Fail:   $FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
  echo -e "${GREEN}All tests passed${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed${NC}"
  exit 1
fi
