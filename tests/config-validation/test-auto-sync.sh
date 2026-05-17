#!/usr/bin/env bash
# Test Auto-Sync & Update-Docs Scripts
# Run: bash tests/config-validation/test-auto-sync.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$SCRIPT_DIR/../.."
AUTO_SYNC="$REPO_DIR/scripts/auto-sync.sh"
UPDATE_DOCS="$REPO_DIR/scripts/update-docs.sh"
SYNC_TO_REPO="$REPO_DIR/scripts/sync-to-repo.sh"

PASS=0
FAIL=0
TOTAL=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TMP_DIR=$(mktemp -d)
LOCAL_DIR="$TMP_DIR/local-config"
REPO_TEST_DIR="$TMP_DIR/repo-test"
OBSIDIAN_DIR="$TMP_DIR/obsidian"

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

assert_pass() {
  local desc="$1" exit_code="$2"
  TOTAL=$((TOTAL + 1))
  if [ "$exit_code" -eq 0 ]; then
    echo -e "  ${GREEN}PASS${NC} $desc"; PASS=$((PASS + 1))
  else
    echo -e "  ${RED}FAIL${NC} $desc (exit=$exit_code)"; FAIL=$((FAIL + 1))
  fi
}

assert_fail() {
  local desc="$1" exit_code="$2"
  TOTAL=$((TOTAL + 1))
  if [ "$exit_code" -ne 0 ]; then
    echo -e "  ${GREEN}PASS${NC} $desc"; PASS=$((PASS + 1))
  else
    echo -e "  ${RED}FAIL${NC} $desc (expected non-zero exit)"; FAIL=$((FAIL + 1))
  fi
}

assert_contains() {
  local desc="$1" input="$2" pattern="$3"
  TOTAL=$((TOTAL + 1))
  if echo "$input" | grep -q "$pattern" 2>/dev/null; then
    echo -e "  ${GREEN}PASS${NC} $desc"; PASS=$((PASS + 1))
  else
    echo -e "  ${RED}FAIL${NC} $desc (pattern: $pattern)"; FAIL=$((FAIL + 1))
  fi
}

assert_file_contains() {
  local desc="$1" file="$2" pattern="$3"
  TOTAL=$((TOTAL + 1))
  if grep -q "$pattern" "$file" 2>/dev/null; then
    echo -e "  ${GREEN}PASS${NC} $desc"; PASS=$((PASS + 1))
  else
    echo -e "  ${RED}FAIL${NC} $desc (pattern: $pattern)"; FAIL=$((FAIL + 1))
  fi
}

assert_file_not_contains() {
  local desc="$1" file="$2" pattern="$3"
  TOTAL=$((TOTAL + 1))
  if ! grep -q "$pattern" "$file" 2>/dev/null; then
    echo -e "  ${GREEN}PASS${NC} $desc"; PASS=$((PASS + 1))
  else
    echo -e "  ${RED}FAIL${NC} $desc (found: $pattern)"; FAIL=$((FAIL + 1))
  fi
}

echo "=== Test Auto-Sync & Update-Docs ==="
echo ""

setup_test_env() {
  rm -rf "$TMP_DIR"
  mkdir -p "$LOCAL_DIR/agents" "$LOCAL_DIR/commands" "$LOCAL_DIR/skills" "$LOCAL_DIR/scripts"
  mkdir -p "$REPO_TEST_DIR/agents" "$REPO_TEST_DIR/commands" "$REPO_TEST_DIR/skills" "$REPO_TEST_DIR/scripts"
  mkdir -p "$REPO_TEST_DIR/docs/design/03-Skills" "$REPO_TEST_DIR/docs/design/04-Updates"
  mkdir -p "$OBSIDIAN_DIR"

  # Copy required scripts to BOTH local and repo (so they match)
  if [ -f "$SYNC_TO_REPO" ]; then
    cp "$SYNC_TO_REPO" "$REPO_TEST_DIR/scripts/"
    cp "$SYNC_TO_REPO" "$LOCAL_DIR/scripts/"
  fi
  if [ -f "$UPDATE_DOCS" ]; then
    cp "$UPDATE_DOCS" "$REPO_TEST_DIR/scripts/"
    cp "$UPDATE_DOCS" "$LOCAL_DIR/scripts/"
  fi

  cd "$REPO_TEST_DIR" && git init -q && git config user.email "test@test.com" && git config user.name "Test"

  echo '{"mcp":{"postman":{"type":"remote"},"local":{"type":"local"}},"permission":{"*":"allow"}}' > "$LOCAL_DIR/opencode.json"
  cp "$LOCAL_DIR/opencode.json" "$REPO_TEST_DIR/opencode.json"

  cat > "$REPO_TEST_DIR/docs/design/00-Overview.md" << 'EOF'
# OpenCode Agent Config — Overview

**Last Updated:** 2026-01-01
**Status:** Initial

---

## Current State

| Component | Count | Status |
|-----------|-------|--------|
| MCP Servers | 2 (1 local + 1 remote) | ✅ Configured |
| Agents | 0 custom subagents | ✅ Complete |
| Skills | 0 (0 directories) | ✅ Complete |
| Commands | 0 | ✅ Complete |
| Tests | 0 | ✅ Complete |
| CI/CD | 0 workflows | ✅ Deployed |
| Scripts | 0 | ✅ Complete |
EOF

  cat > "$REPO_TEST_DIR/docs/design/04-Updates/Changelog.md" << 'EOF'
# Updates Changelog

All changes to the AI agent configuration, tracked by date.

---
EOF

  echo "Total Skills: 0" > "$REPO_TEST_DIR/docs/design/03-Skills/Skills-Index.md"
  echo "Last Updated: 2026-01-01" >> "$REPO_TEST_DIR/docs/design/03-Skills/Skills-Index.md"
  echo "Total Agents: 0" > "$REPO_TEST_DIR/docs/design/03-Skills/Agent-Catalog.md"
  echo "Last Updated: 2026-01-01" >> "$REPO_TEST_DIR/docs/design/03-Skills/Agent-Catalog.md"
  echo "Total Commands: 0" > "$REPO_TEST_DIR/docs/design/03-Skills/Command-Catalog.md"
  echo "Last Updated: 2026-01-01" >> "$REPO_TEST_DIR/docs/design/03-Skills/Command-Catalog.md"
  echo "Total MCP Servers: 2" > "$REPO_TEST_DIR/docs/design/03-Skills/MCP-Catalog.md"
  echo "Last Updated: 2026-01-01" >> "$REPO_TEST_DIR/docs/design/03-Skills/MCP-Catalog.md"

  cd "$REPO_TEST_DIR" && git add -A && git commit -q -m "initial"
}

echo "--- Auto-Sync: Argument Validation ---"
bash "$AUTO_SYNC" --local /nonexistent --repo "$REPO_TEST_DIR" > /dev/null 2>&1; assert_fail "invalid local dir fails" $?
bash "$AUTO_SYNC" --local "$LOCAL_DIR" --repo /nonexistent > /dev/null 2>&1; assert_fail "invalid repo dir fails" $?
bash "$AUTO_SYNC" --local /nonexistent --repo /nonexistent > /dev/null 2>&1; assert_fail "both invalid dirs fails" $?

echo ""
echo "--- Auto-Sync: No Changes ---"
setup_test_env
output=$(bash "$AUTO_SYNC" --local "$LOCAL_DIR" --repo "$REPO_TEST_DIR" 2>&1)
assert_pass "no changes exits 0" $?
assert_contains "reports no changes" "$output" "No changes detected"

echo ""
echo "--- Auto-Sync: Detects New File ---"
setup_test_env
echo "# New Agent" > "$LOCAL_DIR/agents/test-agent.md"
output=$(bash "$AUTO_SYNC" --local "$LOCAL_DIR" --repo "$REPO_TEST_DIR" --dry-run 2>&1)
assert_pass "dry run exits 0" $?
assert_contains "detects new file" "$output" "agents:"

echo ""
echo "--- Auto-Sync: Detects Modified File ---"
setup_test_env
echo '{"mcp":{"new":{"type":"remote"}}}' > "$LOCAL_DIR/opencode.json"
output=$(bash "$AUTO_SYNC" --local "$LOCAL_DIR" --repo "$REPO_TEST_DIR" --dry-run 2>&1)
assert_pass "dry run exits 0" $?
assert_contains "detects modified opencode.json" "$output" "opencode.json"

echo ""
echo "--- Auto-Sync: Detects Deleted File ---"
setup_test_env
echo "test" > "$REPO_TEST_DIR/scripts/old-script.sh"
cd "$REPO_TEST_DIR" && git add -A && git commit -q -m "add script"
output=$(bash "$AUTO_SYNC" --local "$LOCAL_DIR" --repo "$REPO_TEST_DIR" --dry-run 2>&1)
assert_pass "dry run exits 0" $?
assert_contains "detects deleted file" "$output" "deleted:"

echo ""
echo "--- Auto-Sync: Syncs Files ---"
setup_test_env
mkdir -p "$LOCAL_DIR/skills/new-skill" && echo "# New Skill" > "$LOCAL_DIR/skills/new-skill/SKILL.md"
output=$(bash "$AUTO_SYNC" --local "$LOCAL_DIR" --repo "$REPO_TEST_DIR" 2>&1)
assert_pass "sync exits 0" $?
assert_contains "syncs files" "$output" "Sync complete"

echo ""
echo "--- Auto-Sync: Sanitizes Secrets ---"
setup_test_env
echo '{"mcp":{"github":{"environment":{"GITHUB_TOKEN":"ghp_abc123secret456"}}}}' > "$LOCAL_DIR/opencode.json"
bash "$AUTO_SYNC" --local "$LOCAL_DIR" --repo "$REPO_TEST_DIR" > /dev/null 2>&1
assert_pass "sync with secrets exits 0" $?
assert_file_not_contains "sanitizes GITHUB_TOKEN" "$REPO_TEST_DIR/opencode.json" "ghp_abc123secret456"
assert_file_contains "replaces with REDACTED" "$REPO_TEST_DIR/opencode.json" "REDACTED"

echo ""
echo "--- Update-Docs: Argument Validation ---"
bash "$UPDATE_DOCS" > /dev/null 2>&1; assert_fail "no arguments fails" $?
bash "$UPDATE_DOCS" --repo /nonexistent > /dev/null 2>&1; assert_fail "invalid repo dir fails" $?

echo ""
echo "--- Update-Docs: Updates Overview ---"
setup_test_env
mkdir -p "$LOCAL_DIR/skills/test-skill" && echo "test" > "$LOCAL_DIR/skills/test-skill/SKILL.md"
echo "test" > "$LOCAL_DIR/agents/my-agent.md"
echo "test" > "$LOCAL_DIR/commands/my-cmd.md"
echo "test" > "$LOCAL_DIR/scripts/my-script.sh"
mkdir -p "$REPO_TEST_DIR/.github/workflows" && echo "test" > "$REPO_TEST_DIR/.github/workflows/test.yml"
mkdir -p "$REPO_TEST_DIR/tests/config-validation" && echo "test" > "$REPO_TEST_DIR/tests/config-validation/test.sh"
bash "$UPDATE_DOCS" --repo "$REPO_TEST_DIR" --changes "new skill added" > /dev/null 2>&1
assert_pass "update-docs exits 0" $?
TODAY=$(date -u +"%Y-%m-%d")
assert_file_contains "updates date" "$REPO_TEST_DIR/docs/design/00-Overview.md" "$TODAY"
assert_file_contains "updates skills count" "$REPO_TEST_DIR/docs/design/00-Overview.md" "Skills"

echo ""
echo "--- Update-Docs: Updates Changelog ---"
setup_test_env
bash "$UPDATE_DOCS" --repo "$REPO_TEST_DIR" --changes "test change" > /dev/null 2>&1
TODAY=$(date -u +"%Y-%m-%d")
assert_file_contains "adds today entry" "$REPO_TEST_DIR/docs/design/04-Updates/Changelog.md" "$TODAY"
assert_file_contains "includes change summary" "$REPO_TEST_DIR/docs/design/04-Updates/Changelog.md" "test change"

echo ""
echo "--- Update-Docs: Updates Catalogs ---"
setup_test_env
mkdir -p "$LOCAL_DIR/skills/skill-a" "$LOCAL_DIR/skills/skill-b"
echo "a" > "$LOCAL_DIR/skills/skill-a/SKILL.md"
echo "b" > "$LOCAL_DIR/skills/skill-b/SKILL.md"
bash "$UPDATE_DOCS" --repo "$REPO_TEST_DIR" > /dev/null 2>&1
assert_file_contains "updates skills index" "$REPO_TEST_DIR/docs/design/03-Skills/Skills-Index.md" "Total Skills:"
assert_file_contains "updates agent catalog" "$REPO_TEST_DIR/docs/design/03-Skills/Agent-Catalog.md" "Total Agents:"
assert_file_contains "updates command catalog" "$REPO_TEST_DIR/docs/design/03-Skills/Command-Catalog.md" "Total Commands:"
assert_file_contains "updates mcp catalog" "$REPO_TEST_DIR/docs/design/03-Skills/MCP-Catalog.md" "Total MCP Servers:"

echo ""
echo "--- Update-Docs: Syncs to Obsidian ---"
setup_test_env
bash "$UPDATE_DOCS" --repo "$REPO_TEST_DIR" --obsidian "$OBSIDIAN_DIR" > /dev/null 2>&1
if [ -f "$OBSIDIAN_DIR/00-Overview.md" ]; then
  TOTAL=$((TOTAL + 1)); echo -e "  ${GREEN}PASS${NC} overview synced to obsidian"; PASS=$((PASS + 1))
else
  TOTAL=$((TOTAL + 1)); echo -e "  ${RED}FAIL${NC} overview not synced to obsidian"; FAIL=$((FAIL + 1))
fi

echo ""
echo "--- Update-Docs: Handles Missing Catalogs ---"
setup_test_env
rm -f "$REPO_TEST_DIR/docs/design/03-Skills/Skills-Index.md"
output=$(bash "$UPDATE_DOCS" --repo "$REPO_TEST_DIR" 2>&1)
assert_pass "handles missing catalogs gracefully" $?

echo ""
echo "=== Results ==="
echo "Total:  $TOTAL"
echo -e "${GREEN}Pass:   $PASS${NC}"
echo -e "${RED}Fail:   $FAIL${NC}"
if [ $FAIL -eq 0 ]; then echo -e "\n${GREEN}All tests passed${NC}"; exit 0
else echo -e "\n${RED}Some tests failed${NC}"; exit 1; fi
