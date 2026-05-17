#!/usr/bin/env bash
# Changelog Generator — tests for scripts/generate-changelog.sh
# Run: bash tests/config-validation/test-generate-changelog.sh

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

CHANGELOG_SCRIPT="/home/br4vetrave1er/Desktop/projects/opencode-config/scripts/generate-changelog.sh"
REPO_DIR="/home/br4vetrave1er/Desktop/projects/opencode-config"

echo "=== Changelog Generator Tests ==="
echo ""

# Test 1: Generates changelog from repo
echo "--- Generates Changelog ---"
OUTPUT=$("$CHANGELOG_SCRIPT" --repo "$REPO_DIR" 2>&1)
EXIT_CODE=$?
assert_exit "generates changelog" 0 $EXIT_CODE
assert_output_contains "has changelog header" "changelog\|changes\|history" "$OUTPUT"

# Test 2: Includes commit messages
echo ""
echo "--- Includes Commits ---"
OUTPUT=$("$CHANGELOG_SCRIPT" --repo "$REPO_DIR" 2>&1)
EXIT_CODE=$?
assert_output_contains "includes commit messages" "feat\|fix\|chore\|commit" "$OUTPUT"

# Test 3: Output to file
echo ""
echo "--- Output to File ---"
OUTPUT_FILE="$FIXTURE_DIR/changelog.md"
OUTPUT=$("$CHANGELOG_SCRIPT" --repo "$REPO_DIR" --output "$OUTPUT_FILE" 2>&1)
EXIT_CODE=$?
assert_exit "writes to file" 0 $EXIT_CODE
assert_exit "output file exists" 0 $([ -f "$OUTPUT_FILE" ] && echo 0 || echo 1)
assert_output_contains "file has content" "changelog\|changes\|history" "$(cat "$OUTPUT_FILE" 2>/dev/null)"

# Test 4: Invalid repo path
echo ""
echo "--- Invalid Repo Path ---"
OUTPUT=$("$CHANGELOG_SCRIPT" --repo "/nonexistent/path" 2>&1)
EXIT_CODE=$?
assert_exit "invalid repo fails" 1 $EXIT_CODE

# Test 5: Limited commits
echo ""
echo "--- Limited Commits ---"
OUTPUT=$("$CHANGELOG_SCRIPT" --repo "$REPO_DIR" --limit 3 2>&1)
EXIT_CODE=$?
assert_exit "limited commits works" 0 $EXIT_CODE

# Test 6: Date range
echo ""
echo "--- Date Range ---"
OUTPUT=$("$CHANGELOG_SCRIPT" --repo "$REPO_DIR" --since "2020-01-01" 2>&1)
EXIT_CODE=$?
assert_exit "date range works" 0 $EXIT_CODE

# Test 7: Markdown format
echo ""
echo "--- Markdown Format ---"
OUTPUT=$("$CHANGELOG_SCRIPT" --repo "$REPO_DIR" 2>&1)
EXIT_CODE=$?
assert_output_contains "uses markdown headings" "^#\|^##" "$OUTPUT"

# Test 8: Grouped by type
echo ""
echo "--- Grouped by Type ---"
OUTPUT=$("$CHANGELOG_SCRIPT" --repo "$REPO_DIR" 2>&1)
EXIT_CODE=$?
assert_output_contains "has feat section" "feat\|feature" "$OUTPUT"

# Summary
echo ""
echo "=== Results ==="
echo -e "Total:  $TOTAL"
echo -e "${GREEN}Pass:   $PASS${NC}"
echo -e "${RED}Fail:   $FAIL${NC}"

if [ $FAIL -gt 0 ]; then
  exit 1
fi
