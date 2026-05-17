#!/usr/bin/env bash
# playwright-cli skill validation tests
# Run: bash tests/run-tests.sh

set -e

PASS=0
FAIL=0
TOTAL=0
SKIPPED=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

assert() {
  local name="$1"
  local result="$2"
  local expected="$3"
  TOTAL=$((TOTAL + 1))
  if echo "$result" | grep -qi "$expected"; then
    echo -e "${GREEN}PASS${NC} $name"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}FAIL${NC} $name"
    echo "  Expected: $expected"
    echo "  Got: $(echo "$result" | head -5)"
    FAIL=$((FAIL + 1))
  fi
}

cleanup() {
  playwright-cli close-all 2>/dev/null || true
  playwright-cli kill-all 2>/dev/null || true
}

trap cleanup EXIT

ALLOWED_DIR=".playwright-cli"
mkdir -p "$ALLOWED_DIR"

echo "=== playwright-cli Skill Tests ==="
echo ""

# --- Core Commands ---
echo "--- Core Commands ---"

cleanup

OUTPUT=$(playwright-cli open https://example.com 2>&1)
assert "open URL" "$OUTPUT" "opened\|Browser"

OUTPUT=$(playwright-cli goto https://httpbin.org/html 2>&1)
assert "goto URL" "$OUTPUT" "Page URL"

OUTPUT=$(playwright-cli snapshot 2>&1)
assert "snapshot" "$OUTPUT" "Snapshot"

OUTPUT=$(playwright-cli eval "document.title" 2>&1)
assert "eval document.title" "$OUTPUT" "result\|Herman\|Page Title"

OUTPUT=$(playwright-cli reload 2>&1)
assert "reload" "$OUTPUT" "Page URL"

OUTPUT=$(playwright-cli go-back 2>&1)
assert "go-back" "$OUTPUT" "Page URL"

# --- Element Interaction ---
echo ""
echo "--- Element Interaction ---"

OUTPUT=$(playwright-cli snapshot 2>&1)
REF=$(echo "$OUTPUT" | grep -oP 'ref=e\d+' | head -1 | grep -oP 'e\d+')
if [ -n "$REF" ]; then
  OUTPUT=$(playwright-cli eval "el => el.textContent" "$REF" 2>&1)
  assert "eval element textContent" "$OUTPUT" "result\|textContent"
else
  TOTAL=$((TOTAL + 1))
  SKIPPED=$((SKIPPED + 1))
  echo -e "${YELLOW}SKIP${NC} eval element (no ref found)"
fi

# --- Keyboard ---
echo ""
echo "--- Keyboard ---"

OUTPUT=$(playwright-cli press Escape 2>&1)
assert "press Escape" "$OUTPUT" "result\|pressed\|Playwright\|Page"

# --- Mouse ---
echo ""
echo "--- Mouse ---"

OUTPUT=$(playwright-cli mousemove 100 100 2>&1)
assert "mousemove" "$OUTPUT" "result\|moved\|Page"

# --- Tabs ---
echo ""
echo "--- Tabs ---"

OUTPUT=$(playwright-cli tab-new https://example.org 2>&1)
assert "tab-new" "$OUTPUT" "tab\|Page URL"

OUTPUT=$(playwright-cli tab-list 2>&1)
assert "tab-list" "$OUTPUT" "tab\|0\|1"

OUTPUT=$(playwright-cli tab-select 0 2>&1)
assert "tab-select" "$OUTPUT" "result\|selected\|Page"

OUTPUT=$(playwright-cli tab-close 2>&1)
assert "tab-close" "$OUTPUT" "result\|closed\|Page"

# --- Storage ---
echo ""
echo "--- Storage ---"

OUTPUT=$(playwright-cli localstorage-set test_key "test_value" 2>&1)
assert "localstorage-set" "$OUTPUT" "result\|set\|local"

OUTPUT=$(playwright-cli localstorage-get test_key 2>&1)
assert "localstorage-get" "$OUTPUT" "test_value\|result"

OUTPUT=$(playwright-cli localstorage-delete test_key 2>&1)
assert "localstorage-delete" "$OUTPUT" "result\|deleted\|local"

OUTPUT=$(playwright-cli cookie-set test_cookie "abc123" --domain=example.com 2>&1)
assert "cookie-set" "$OUTPUT" "result\|set\|cookie"

OUTPUT=$(playwright-cli cookie-get test_cookie 2>&1)
assert "cookie-get" "$OUTPUT" "abc123\|result"

OUTPUT=$(playwright-cli cookie-delete test_cookie 2>&1)
assert "cookie-delete" "$OUTPUT" "result\|deleted\|cookie"

# --- Network ---
echo ""
echo "--- Network ---"

OUTPUT=$(playwright-cli route "**/*.png" --status=404 2>&1)
assert "route" "$OUTPUT" "result\|route\|set"

OUTPUT=$(playwright-cli route-list 2>&1)
assert "route-list" "$OUTPUT" "route\|png\|list"

OUTPUT=$(playwright-cli unroute "**/*.png" 2>&1)
assert "unroute" "$OUTPUT" "result\|unroute\|removed"

# --- Screenshot ---
echo ""
echo "--- Screenshot ---"

OUTPUT=$(playwright-cli screenshot --filename="$ALLOWED_DIR/test-screenshot.png" 2>&1)
assert "screenshot" "$OUTPUT" "screenshot\|saved\|png"

# --- Resize ---
echo ""
echo "--- Resize ---"

OUTPUT=$(playwright-cli resize 800 600 2>&1)
assert "resize" "$OUTPUT" "result\|resize\|800"

# --- DevTools ---
echo ""
echo "--- DevTools ---"

OUTPUT=$(playwright-cli console 2>&1)
assert "console" "$OUTPUT" "console\|result"

OUTPUT=$(playwright-cli network 2>&1)
assert "network" "$OUTPUT" "network\|result"

# --- Named Session ---
echo ""
echo "--- Named Session ---"

playwright-cli close-all 2>/dev/null || true

OUTPUT=$(playwright-cli -s=testsession open https://example.com 2>&1)
assert "named session open" "$OUTPUT" "testsession\|opened\|Browser"

OUTPUT=$(playwright-cli -s=testsession snapshot 2>&1)
assert "named session snapshot" "$OUTPUT" "Snapshot"

OUTPUT=$(playwright-cli -s=testsession close 2>&1)
assert "named session close" "$OUTPUT" "testsession\|closed"

# --- State Save/Load ---
echo ""
echo "--- State Save/Load ---"

playwright-cli close-all 2>/dev/null || true
playwright-cli open https://example.com 2>&1 >/dev/null

STATE_FILE="$ALLOWED_DIR/test-auth.json"
OUTPUT=$(playwright-cli state-save "$STATE_FILE" 2>&1)
assert "state-save" "$OUTPUT" "saved\|state\|result"

OUTPUT=$(playwright-cli state-load "$STATE_FILE" 2>&1)
assert "state-load" "$OUTPUT" "loaded\|state\|result"

playwright-cli close 2>&1 >/dev/null

# --- Raw Output ---
echo ""
echo "--- Raw Output ---"

playwright-cli open https://example.com 2>&1 >/dev/null

OUTPUT=$(playwright-cli --raw eval "document.title" 2>&1)
assert "raw eval" "$OUTPUT" "Example Domain"

OUTPUT=$(playwright-cli --raw localstorage-set raw_test "value" 2>&1)
assert "raw localstorage-set" "$OUTPUT" "value\|result\|^$"

playwright-cli close 2>&1 >/dev/null

# --- PDF ---
echo ""
echo "--- PDF ---"

playwright-cli open https://example.com 2>&1 >/dev/null

OUTPUT=$(playwright-cli pdf --filename="$ALLOWED_DIR/test-page.pdf" 2>&1)
assert "pdf" "$OUTPUT" "pdf\|saved\|result"

playwright-cli close 2>&1 >/dev/null

# --- Dialog Handling ---
echo ""
echo "--- Dialog Handling ---"

playwright-cli open https://example.com 2>&1 >/dev/null

OUTPUT=$(playwright-cli dialog-accept 2>&1)
assert "dialog-accept" "$OUTPUT" "result\|dialog\|accept"

OUTPUT=$(playwright-cli dialog-dismiss 2>&1)
assert "dialog-dismiss" "$OUTPUT" "result\|dialog\|dismiss"

playwright-cli close 2>&1 >/dev/null

# --- Summary ---
echo ""
echo "=== Results ==="
echo -e "Total:    $TOTAL"
echo -e "${GREEN}Pass:     $PASS${NC}"
echo -e "${RED}Fail:     $FAIL${NC}"
if [ $SKIPPED -gt 0 ]; then
  echo -e "${YELLOW}Skipped:  $SKIPPED${NC}"
fi

if [ $FAIL -gt 0 ]; then
  exit 1
fi
