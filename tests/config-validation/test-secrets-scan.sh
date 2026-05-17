#!/usr/bin/env bash
# Secrets Scanner — tests for scripts/secrets-scan.sh
# Run: bash tests/config-validation/test-secrets-scan.sh

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

# Setup test fixtures
FIXTURE_DIR=$(mktemp -d)
trap "rm -rf $FIXTURE_DIR" EXIT

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCAN_SCRIPT="$PROJECT_DIR/scripts/secrets-scan.sh"

echo "=== Secrets Scanner Tests ==="
echo ""

# Test 1: Clean directory — no secrets
echo "--- Clean Files ---"
echo '{"key": "value"}' > "$FIXTURE_DIR/clean.json"
echo 'normal text file' > "$FIXTURE_DIR/clean.txt"
OUTPUT=$("$SCAN_SCRIPT" "$FIXTURE_DIR" 2>&1)
EXIT_CODE=$?
assert_exit "clean directory passes" 0 $EXIT_CODE

# Test 2: GitHub token detection
echo ""
echo "--- GitHub Token ---"
echo '{"token": "ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghij"}' > "$FIXTURE_DIR/secret.json"
OUTPUT=$("$SCAN_SCRIPT" "$FIXTURE_DIR" 2>&1)
EXIT_CODE=$?
assert_exit "GitHub token detected" 1 $EXIT_CODE
assert_output_contains "reports GitHub token" "GitHub" "$OUTPUT"

# Test 3: Atlassian token detection
echo ""
echo "--- Atlassian Token ---"
rm -f "$FIXTURE_DIR/secret.json"
echo '{"pat": "ATATTxFfGF0w7JG8CwCC0R4y1Kg04wcQbB8ZKhbCLx3C89X-HakiLr6CtVMLxZvyZAdUvOVyucAFP57i_sHc2bfKlXxuqrHinImA4SryamGoEboE2AhcDU9Rwe5M1lNdF01VaEs5OU19WtlXL4LJR-mdX31FCY-vq2dBfUI2k4DbKZhLuWEoCg=FAKE000"}' > "$FIXTURE_DIR/secret.json"
OUTPUT=$("$SCAN_SCRIPT" "$FIXTURE_DIR" 2>&1)
EXIT_CODE=$?
assert_exit "Atlassian token detected" 1 $EXIT_CODE
assert_output_contains "reports Atlassian token" "Atlassian" "$OUTPUT"

# Test 4: OpenAI key detection
echo ""
echo "--- OpenAI Key ---"
rm -f "$FIXTURE_DIR/secret.json"
echo '{"key": "sk-proj-ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnop"}' > "$FIXTURE_DIR/secret.json"
OUTPUT=$("$SCAN_SCRIPT" "$FIXTURE_DIR" 2>&1)
EXIT_CODE=$?
assert_exit "OpenAI key detected" 1 $EXIT_CODE
assert_output_contains "reports OpenAI key" "OpenAI" "$OUTPUT"

# Test 5: AWS key detection
echo ""
echo "--- AWS Key ---"
rm -f "$FIXTURE_DIR/secret.json"
echo '{"key": "AKIAIOSFODNN7EXAMPLE"}' > "$FIXTURE_DIR/secret.json"
OUTPUT=$("$SCAN_SCRIPT" "$FIXTURE_DIR" 2>&1)
EXIT_CODE=$?
assert_exit "AWS key detected" 1 $EXIT_CODE
assert_output_contains "reports AWS key" "AWS" "$OUTPUT"

# Test 6: JWT token detection
echo ""
echo "--- JWT Token ---"
rm -f "$FIXTURE_DIR/secret.json"
echo '{"token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.abc123"}' > "$FIXTURE_DIR/secret.json"
OUTPUT=$("$SCAN_SCRIPT" "$FIXTURE_DIR" 2>&1)
EXIT_CODE=$?
assert_exit "JWT token detected" 1 $EXIT_CODE
assert_output_contains "reports JWT token" "JWT" "$OUTPUT"

# Test 7: Google key detection
echo ""
echo "--- Google Key ---"
rm -f "$FIXTURE_DIR/secret.json"
echo '{"key": "AIzaSyABCDEFGHIJKLMNOPQRSTUVWXYZabcdefg"}' > "$FIXTURE_DIR/secret.json"
OUTPUT=$("$SCAN_SCRIPT" "$FIXTURE_DIR" 2>&1)
EXIT_CODE=$?
assert_exit "Google key detected" 1 $EXIT_CODE
assert_output_contains "reports Google key" "Google" "$OUTPUT"

# Test 8: Multiple secrets in one file
echo ""
echo "--- Multiple Secrets ---"
rm -f "$FIXTURE_DIR/secret.json"
cat > "$FIXTURE_DIR/multi.json" << 'EOF'
{
  "github": "ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghij",
  "openai": "sk-proj-ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnop"
}
EOF
OUTPUT=$("$SCAN_SCRIPT" "$FIXTURE_DIR" 2>&1)
EXIT_CODE=$?
assert_exit "multiple secrets detected" 1 $EXIT_CODE

# Test 9: .env.example is skipped
echo ""
echo "--- .env.example Skipped ---"
rm -f "$FIXTURE_DIR/secret.json" "$FIXTURE_DIR/multi.json"
echo 'GITHUB_TOKEN=ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghij' > "$FIXTURE_DIR/.env.example"
OUTPUT=$("$SCAN_SCRIPT" "$FIXTURE_DIR" 2>&1)
EXIT_CODE=$?
assert_exit ".env.example is skipped" 0 $EXIT_CODE

# Test 10: node_modules is skipped
echo ""
echo "--- node_modules Skipped ---"
rm -f "$FIXTURE_DIR/.env.example"
mkdir -p "$FIXTURE_DIR/node_modules/some-package"
echo 'token=ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghij' > "$FIXTURE_DIR/node_modules/some-package/config.js"
OUTPUT=$("$SCAN_SCRIPT" "$FIXTURE_DIR" 2>&1)
EXIT_CODE=$?
assert_exit "node_modules is skipped" 0 $EXIT_CODE

# Test 11: .git directory is skipped
echo ""
echo "--- .git Skipped ---"
rm -rf "$FIXTURE_DIR/node_modules"
mkdir -p "$FIXTURE_DIR/.git/objects"
echo 'ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghij' > "$FIXTURE_DIR/.git/config"
OUTPUT=$("$SCAN_SCRIPT" "$FIXTURE_DIR" 2>&1)
EXIT_CODE=$?
assert_exit ".git is skipped" 0 $EXIT_CODE

# Test 12: Clean file with similar pattern but not a secret
echo ""
echo "--- False Positive Check ---"
rm -rf "$FIXTURE_DIR/.git"
echo 'This is not a token: ghp_short' > "$FIXTURE_DIR/clean.txt"
echo 'Regular text with sk-short key' >> "$FIXTURE_DIR/clean.txt"
OUTPUT=$("$SCAN_SCRIPT" "$FIXTURE_DIR" 2>&1)
EXIT_CODE=$?
assert_exit "short patterns not flagged" 0 $EXIT_CODE

# Summary
echo ""
echo "=== Results ==="
echo -e "Total:  $TOTAL"
echo -e "${GREEN}Pass:   $PASS${NC}"
echo -e "${RED}Fail:   $FAIL${NC}"

if [ $FAIL -gt 0 ]; then
  exit 1
fi
