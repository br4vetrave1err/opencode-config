#!/usr/bin/env bash
# Config Validation — tests for scripts/validate-config.sh
# Run: bash tests/config-validation/test-validate-config.sh

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
  # Create a clean sub-fixture for each test
  local name="$1"
  local dir="$FIXTURE_DIR/$name"
  rm -rf "$dir"
  mkdir -p "$dir"
  echo "$dir"
}

VALIDATE_SCRIPT="/home/br4vetrave1er/Desktop/projects/opencode-config/scripts/validate-config.sh"

echo "=== Config Validation Tests ==="
echo ""

# Test 1: Valid opencode.json
echo "--- Valid opencode.json ---"
F=$(FIXTURE "t1-valid-opencode")
cat > "$F/opencode.json" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {"test": {"type": "local", "command": ["echo"], "enabled": true}},
  "agent": {},
  "permission": {"*": "allow"},
  "instructions": []
}
EOF
OUTPUT=$("$VALIDATE_SCRIPT" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "valid opencode.json passes" 0 $EXIT_CODE

# Test 2: Invalid JSON
echo ""
echo "--- Invalid JSON ---"
F=$(FIXTURE "t2-invalid-json")
echo '{bad json' > "$F/opencode.json"
OUTPUT=$("$VALIDATE_SCRIPT" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "invalid JSON fails" 1 $EXIT_CODE
assert_output_contains "reports JSON error" "JSON\|json\|invalid" "$OUTPUT"

# Test 3: Missing required fields
echo ""
echo "--- Missing Required Fields ---"
F=$(FIXTURE "t3-missing-fields")
echo '{"mcp": {}}' > "$F/opencode.json"
OUTPUT=$("$VALIDATE_SCRIPT" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "missing required fields fails" 1 $EXIT_CODE

# Test 4: Valid skill with frontmatter
echo ""
echo "--- Valid Skill ---"
F=$(FIXTURE "t4-valid-skill")
cat > "$F/opencode.json" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {"test": {"type": "local", "command": ["echo"], "enabled": true}},
  "agent": {},
  "permission": {"*": "allow"},
  "instructions": []
}
EOF
mkdir -p "$F/skills/test-skill"
cat > "$F/skills/test-skill/SKILL.md" << 'EOF'
---
name: test-skill
description: A test skill for validation
---

# Test Skill

Content here.
EOF
OUTPUT=$("$VALIDATE_SCRIPT" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "valid skill passes" 0 $EXIT_CODE

# Test 5: Skill missing frontmatter
echo ""
echo "--- Skill Missing Frontmatter ---"
F=$(FIXTURE "t5-skill-no-frontmatter")
cat > "$F/opencode.json" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {"test": {"type": "local", "command": ["echo"], "enabled": true}},
  "agent": {},
  "permission": {"*": "allow"},
  "instructions": []
}
EOF
mkdir -p "$F/skills/test-skill"
echo '# No frontmatter' > "$F/skills/test-skill/SKILL.md"
OUTPUT=$("$VALIDATE_SCRIPT" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "skill missing frontmatter fails" 1 $EXIT_CODE

# Test 6: Skill name mismatch
echo ""
echo "--- Skill Name Mismatch ---"
F=$(FIXTURE "t6-skill-name-mismatch")
cat > "$F/opencode.json" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {"test": {"type": "local", "command": ["echo"], "enabled": true}},
  "agent": {},
  "permission": {"*": "allow"},
  "instructions": []
}
EOF
mkdir -p "$F/skills/test-skill"
cat > "$F/skills/test-skill/SKILL.md" << 'EOF'
---
name: wrong-name
description: A test skill
---

# Test Skill
EOF
OUTPUT=$("$VALIDATE_SCRIPT" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "skill name mismatch fails" 1 $EXIT_CODE

# Test 7: Valid agent file
echo ""
echo "--- Valid Agent ---"
F=$(FIXTURE "t7-valid-agent")
cat > "$F/opencode.json" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {"test": {"type": "local", "command": ["echo"], "enabled": true}},
  "agent": {},
  "permission": {"*": "allow"},
  "instructions": []
}
EOF
mkdir -p "$F/skills/test-skill"
cat > "$F/skills/test-skill/SKILL.md" << 'EOF'
---
name: test-skill
description: A test skill
---

# Test Skill
EOF
mkdir -p "$F/agents"
cat > "$F/agents/test-agent.md" << 'EOF'
---
description: A test agent
---

# Test Agent

Instructions here.
EOF
OUTPUT=$("$VALIDATE_SCRIPT" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "valid agent passes" 0 $EXIT_CODE

# Test 8: Valid command file
echo ""
echo "--- Valid Command ---"
F=$(FIXTURE "t8-valid-command")
cat > "$F/opencode.json" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {"test": {"type": "local", "command": ["echo"], "enabled": true}},
  "agent": {},
  "permission": {"*": "allow"},
  "instructions": []
}
EOF
mkdir -p "$F/commands"
cat > "$F/commands/test-command.md" << 'EOF'
---
description: A test command
template: Run the test
---

# Test Command
EOF
OUTPUT=$("$VALIDATE_SCRIPT" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "valid command passes" 0 $EXIT_CODE

# Test 9: Command missing template and description
echo ""
echo "--- Command Missing Template/Description ---"
F=$(FIXTURE "t9-command-no-frontmatter")
cat > "$F/opencode.json" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {"test": {"type": "local", "command": ["echo"], "enabled": true}},
  "agent": {},
  "permission": {"*": "allow"},
  "instructions": []
}
EOF
mkdir -p "$F/commands"
echo '# No frontmatter' > "$F/commands/test-command.md"
OUTPUT=$("$VALIDATE_SCRIPT" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "command missing template/description fails" 1 $EXIT_CODE

# Test 10: Instructions glob resolution
echo ""
echo "--- Instructions Glob Resolution ---"
F=$(FIXTURE "t10-glob-resolves")
cat > "$F/opencode.json" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {"test": {"type": "local", "command": ["echo"], "enabled": true}},
  "agent": {},
  "permission": {"*": "allow"},
  "instructions": ["skills/*/SKILL.md"]
}
EOF
mkdir -p "$F/skills/real-skill"
cat > "$F/skills/real-skill/SKILL.md" << 'EOF'
---
name: real-skill
description: A real skill
---

# Real Skill
EOF
OUTPUT=$("$VALIDATE_SCRIPT" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "valid glob resolves" 0 $EXIT_CODE

# Test 11: Instructions glob doesn't resolve
echo ""
echo "--- Instructions Glob Not Resolving ---"
F=$(FIXTURE "t11-glob-no-match")
cat > "$F/opencode.json" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {"test": {"type": "local", "command": ["echo"], "enabled": true}},
  "agent": {},
  "permission": {"*": "allow"},
  "instructions": ["nonexistent/*.md"]
}
EOF
OUTPUT=$("$VALIDATE_SCRIPT" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "unresolved glob fails" 1 $EXIT_CODE

# Test 12: Duplicate skill names
echo ""
echo "--- Duplicate Skill Names ---"
F=$(FIXTURE "t12-duplicate-skills")
cat > "$F/opencode.json" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {"test": {"type": "local", "command": ["echo"], "enabled": true}},
  "agent": {},
  "permission": {"*": "allow"},
  "instructions": []
}
EOF
mkdir -p "$F/skills/skill-a" "$F/skills/skill-b"
cat > "$F/skills/skill-a/SKILL.md" << 'EOF'
---
name: duplicate-name
description: Skill A
---
EOF
cat > "$F/skills/skill-b/SKILL.md" << 'EOF'
---
name: duplicate-name
description: Skill B
---
EOF
OUTPUT=$("$VALIDATE_SCRIPT" "$F" 2>&1)
EXIT_CODE=$?
assert_exit "duplicate skill names fails" 1 $EXIT_CODE

# Summary
echo ""
echo "=== Results ==="
echo -e "Total:  $TOTAL"
echo -e "${GREEN}Pass:   $PASS${NC}"
echo -e "${RED}Fail:   $FAIL${NC}"

if [ $FAIL -gt 0 ]; then
  exit 1
fi
