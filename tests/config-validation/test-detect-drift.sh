#!/usr/bin/env bash
# Drift Detection — tests for scripts/detect-drift.sh
# Run: bash tests/config-validation/test-detect-drift.sh

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

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
DRIFT_SCRIPT="$PROJECT_DIR/scripts/detect-drift.sh"

echo "=== Drift Detection Tests ==="
echo ""

# Test 1: No drift (identical files)
echo "--- No Drift ---"
F=$(FIXTURE "t1-no-drift")
mkdir -p "$F/local" "$F/repo"
cat > "$F/local/opencode.json" << 'EOF'
{"mcp": {}, "permission": {}, "instructions": []}
EOF
cp "$F/local/opencode.json" "$F/repo/opencode.json"
OUTPUT=$("$DRIFT_SCRIPT" --local "$F/local" --repo "$F/repo" 2>&1)
EXIT_CODE=$?
assert_exit "no drift passes" 0 $EXIT_CODE
assert_output_contains "reports no drift" "no drift\|up to date\|synced" "$OUTPUT"

# Test 2: Drift detected (different content)
echo ""
echo "--- Drift Detected ---"
F=$(FIXTURE "t2-drift")
mkdir -p "$F/local" "$F/repo"
echo '{"mcp": {"a": 1}, "permission": {}, "instructions": []}' > "$F/local/opencode.json"
echo '{"mcp": {"b": 2}, "permission": {}, "instructions": []}' > "$F/repo/opencode.json"
OUTPUT=$("$DRIFT_SCRIPT" --local "$F/local" --repo "$F/repo" 2>&1)
EXIT_CODE=$?
assert_exit "drift detected fails" 1 $EXIT_CODE
assert_output_contains "reports drift" "drift\|differs\|changed\|modified" "$OUTPUT"

# Test 3: Missing local file
echo ""
echo "--- Missing Local File ---"
F=$(FIXTURE "t3-missing-local")
mkdir -p "$F/local" "$F/repo"
echo '{"mcp": {}, "permission": {}, "instructions": []}' > "$F/repo/opencode.json"
OUTPUT=$("$DRIFT_SCRIPT" --local "$F/local" --repo "$F/repo" 2>&1)
EXIT_CODE=$?
assert_exit "missing local file fails" 1 $EXIT_CODE

# Test 4: Missing repo file
echo ""
echo "--- Missing Repo File ---"
F=$(FIXTURE "t4-missing-repo")
mkdir -p "$F/local" "$F/repo"
echo '{"mcp": {}, "permission": {}, "instructions": []}' > "$F/local/opencode.json"
OUTPUT=$("$DRIFT_SCRIPT" --local "$F/local" --repo "$F/repo" 2>&1)
EXIT_CODE=$?
assert_exit "missing repo file fails" 1 $EXIT_CODE

# Test 5: New file in local (not in repo)
echo ""
echo "--- New File in Local ---"
F=$(FIXTURE "t5-new-local")
mkdir -p "$F/local" "$F/repo"
echo '{"mcp": {}, "permission": {}, "instructions": []}' > "$F/local/opencode.json"
cp "$F/local/opencode.json" "$F/repo/opencode.json"
mkdir -p "$F/local/skills/new-skill"
cat > "$F/local/skills/new-skill/SKILL.md" << 'EOF'
---
name: new-skill
description: A new skill
---
EOF
OUTPUT=$("$DRIFT_SCRIPT" --local "$F/local" --repo "$F/repo" 2>&1)
EXIT_CODE=$?
assert_exit "new local file detected" 1 $EXIT_CODE
assert_output_contains "reports new file" "new\|added\|missing from repo" "$OUTPUT"

# Test 6: File deleted from local (still in repo)
echo ""
echo "--- File Deleted from Local ---"
F=$(FIXTURE "t6-deleted-local")
mkdir -p "$F/local" "$F/repo"
echo '{"mcp": {}, "permission": {}, "instructions": []}' > "$F/local/opencode.json"
cp "$F/local/opencode.json" "$F/repo/opencode.json"
mkdir -p "$F/repo/skills/old-skill"
cat > "$F/repo/skills/old-skill/SKILL.md" << 'EOF'
---
name: old-skill
description: An old skill
---
EOF
OUTPUT=$("$DRIFT_SCRIPT" --local "$F/local" --repo "$F/repo" 2>&1)
EXIT_CODE=$?
assert_exit "deleted local file detected" 1 $EXIT_CODE
assert_output_contains "reports deleted file" "deleted\|removed\|missing from local" "$OUTPUT"

# Test 7: Skill drift (different content)
echo ""
echo "--- Skill Content Drift ---"
F=$(FIXTURE "t7-skill-drift")
mkdir -p "$F/local/skills/test-skill" "$F/repo/skills/test-skill"
echo '{"mcp": {}, "permission": {}, "instructions": []}' > "$F/local/opencode.json"
cp "$F/local/opencode.json" "$F/repo/opencode.json"
cat > "$F/local/skills/test-skill/SKILL.md" << 'EOF'
---
name: test-skill
description: Updated description
---

# Test Skill

Updated content.
EOF
cat > "$F/repo/skills/test-skill/SKILL.md" << 'EOF'
---
name: test-skill
description: Old description
---

# Test Skill

Old content.
EOF
OUTPUT=$("$DRIFT_SCRIPT" --local "$F/local" --repo "$F/repo" 2>&1)
EXIT_CODE=$?
assert_exit "skill drift detected" 1 $EXIT_CODE

# Test 8: Summary output
echo ""
echo "--- Summary Output ---"
F=$(FIXTURE "t8-summary")
mkdir -p "$F/local" "$F/repo"
echo '{"mcp": {}, "permission": {}, "instructions": []}' > "$F/local/opencode.json"
cp "$F/local/opencode.json" "$F/repo/opencode.json"
OUTPUT=$("$DRIFT_SCRIPT" --local "$F/local" --repo "$F/repo" 2>&1)
EXIT_CODE=$?
assert_output_contains "has summary" "drift\|scan\|result" "$OUTPUT"

# Test 9: Invalid JSON in local
echo ""
echo "--- Invalid JSON in Local ---"
F=$(FIXTURE "t9-invalid-json")
mkdir -p "$F/local" "$F/repo"
echo '{bad json' > "$F/local/opencode.json"
echo '{"mcp": {}, "permission": {}, "instructions": []}' > "$F/repo/opencode.json"
OUTPUT=$("$DRIFT_SCRIPT" --local "$F/local" --repo "$F/repo" 2>&1)
EXIT_CODE=$?
assert_exit "invalid JSON fails" 1 $EXIT_CODE

# Test 10: Multiple files synced
echo ""
echo "--- Multiple Files Synced ---"
F=$(FIXTURE "t10-multi-synced")
mkdir -p "$F/local/skills/skill-a" "$F/local/skills/skill-b" "$F/repo/skills/skill-a" "$F/repo/skills/skill-b"
echo '{"mcp": {}, "permission": {}, "instructions": []}' > "$F/local/opencode.json"
cp "$F/local/opencode.json" "$F/repo/opencode.json"
cat > "$F/local/skills/skill-a/SKILL.md" << 'EOF'
---
name: skill-a
description: Skill A
---
EOF
cp "$F/local/skills/skill-a/SKILL.md" "$F/repo/skills/skill-a/SKILL.md"
cat > "$F/local/skills/skill-b/SKILL.md" << 'EOF'
---
name: skill-b
description: Skill B
---
EOF
cp "$F/local/skills/skill-b/SKILL.md" "$F/repo/skills/skill-b/SKILL.md"
OUTPUT=$("$DRIFT_SCRIPT" --local "$F/local" --repo "$F/repo" 2>&1)
EXIT_CODE=$?
assert_exit "multiple files synced" 0 $EXIT_CODE

# Summary
echo ""
echo "=== Results ==="
echo -e "Total:  $TOTAL"
echo -e "${GREEN}Pass:   $PASS${NC}"
echo -e "${RED}Fail:   $FAIL${NC}"

if [ $FAIL -gt 0 ]; then
  exit 1
fi
