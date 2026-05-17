#!/usr/bin/env bash
# Config Validation — Validates OpenCode configuration structure
# Usage: bash scripts/validate-config.sh [directory]
# Exit 0: All checks pass
# Exit 1: One or more checks fail

SCAN_DIR="${1:-.}"
FAILURES=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check() {
  local name="$1"
  local result="$2"
  if [ "$result" -eq 0 ]; then
    echo -e "${GREEN}PASS${NC} $name"
  else
    echo -e "${RED}FAIL${NC} $name"
    FAILURES=$((FAILURES + 1))
  fi
}

echo "=== Config Validation ==="
echo "Validating: $SCAN_DIR"
echo ""

# --- 1. Validate opencode.json ---
echo "--- opencode.json ---"

CONFIG_FILE="$SCAN_DIR/opencode.json"
if [ ! -f "$CONFIG_FILE" ]; then
  check "opencode.json exists" 1
else
  check "opencode.json exists" 0

  # Valid JSON
  if jq empty "$CONFIG_FILE" 2>/dev/null; then
    check "valid JSON" 0
  else
    check "valid JSON" 1
    echo "  Error: Invalid JSON syntax"
    exit 1
  fi

  # Required fields
  for field in mcp permission instructions; do
    if jq -e ".$field" "$CONFIG_FILE" >/dev/null 2>&1; then
      check "has '$field' field" 0
    else
      check "has '$field' field" 1
    fi
  done

  # Instructions globs resolve
  echo ""
  echo "--- Instructions Globs ---"
  GLOB_COUNT=$(jq -r '.instructions[]' "$CONFIG_FILE" 2>/dev/null)
  if [ -n "$GLOB_COUNT" ]; then
    while IFS= read -r glob; do
      # Handle ~/.config/opencode/ paths - resolve relative to SCAN_DIR
      if [[ "$glob" == "~/.config/opencode/"* ]]; then
        expanded_glob="${glob#"~/.config/opencode/"}"
      else
        # Remove leading ~ and expand
        expanded_glob="${glob/#\~/$HOME}"
      fi
      # Handle glob patterns - check if path contains glob chars
      if [[ "$expanded_glob" == *"*"* || "$expanded_glob" == *"?"* || "$expanded_glob" == *"["* ]]; then
        matching_files=$(eval echo "$SCAN_DIR/$expanded_glob" 2>/dev/null | head -1)
        if [ -n "$matching_files" ] && [ "$matching_files" != "$SCAN_DIR/$expanded_glob" ]; then
          check "glob resolves: $glob" 0
        else
          check "glob resolves: $glob" 1
        fi
      else
        # Direct file path - check if file exists
        if [ -f "$SCAN_DIR/$expanded_glob" ]; then
          check "file exists: $glob" 0
        else
          check "file exists: $glob" 1
        fi
      fi
    done <<< "$GLOB_COUNT"
  fi
fi

# --- 2. Validate Skills ---
echo ""
echo "--- Skills ---"

SKILLS_DIR="$SCAN_DIR/skills"
if [ -d "$SKILLS_DIR" ]; then
  SKILL_COUNT=0
  declare -A SKILL_NAMES

  for skill_dir in "$SKILLS_DIR"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    skill_file="$skill_dir/SKILL.md"
    SKILL_COUNT=$((SKILL_COUNT + 1))

    if [ ! -f "$skill_file" ]; then
      check "skill '$skill_name' has SKILL.md" 1
      continue
    fi
    check "skill '$skill_name' has SKILL.md" 0

    # Check frontmatter
    if grep -q '^---' "$skill_file" 2>/dev/null; then
      check "skill '$skill_name' has frontmatter" 0

      # Extract name from frontmatter (first block only)
      fm_name=$(awk '/^---$/{if(++n==2)exit; if(n==1)next} n==1 && /^name:/{print; exit}' "$skill_file" | sed 's/^name: *//')
      if [ -n "$fm_name" ]; then
        if [ "$fm_name" = "$skill_name" ]; then
          check "skill '$skill_name' name matches directory" 0
        else
          check "skill '$skill_name' name matches directory (got: $fm_name)" 1
        fi

        # Check for duplicates
        if [ -n "${SKILL_NAMES[$fm_name]}" ]; then
          check "skill name '$fm_name' is unique" 1
        else
          SKILL_NAMES[$fm_name]=1
          check "skill name '$fm_name' is unique" 0
        fi
      else
        check "skill '$skill_name' has name in frontmatter" 1
      fi

      # Check description
      fm_desc=$(sed -n '/^---$/,/^---$/p' "$skill_file" | grep '^description:' | sed 's/^description: *//')
      if [ -n "$fm_desc" ]; then
        check "skill '$skill_name' has description" 0
      else
        check "skill '$skill_name' has description" 1
      fi
    else
      check "skill '$skill_name' has frontmatter" 1
    fi
  done

  echo "  Total skills: $SKILL_COUNT"
else
  echo "  WARNING: skills/ directory not found"
fi

# --- 3. Validate Agents ---
echo ""
echo "--- Agents ---"

AGENTS_DIR="$SCAN_DIR/agents"
if [ -d "$AGENTS_DIR" ]; then
  for agent_file in "$AGENTS_DIR"/*.md; do
    [ -f "$agent_file" ] || continue
    agent_name=$(basename "$agent_file" .md)

    # Check for description in frontmatter or content
    if grep -qi 'description' "$agent_file" 2>/dev/null; then
      check "agent '$agent_name' has description" 0
    else
      check "agent '$agent_name' has description" 1
    fi
  done
else
  echo "  INFO: agents/ directory not found (optional)"
fi

# --- 4. Validate Commands ---
echo ""
echo "--- Commands ---"

COMMANDS_DIR="$SCAN_DIR/commands"
if [ -d "$COMMANDS_DIR" ]; then
  for cmd_file in "$COMMANDS_DIR"/*.md; do
    [ -f "$cmd_file" ] || continue
    cmd_name=$(basename "$cmd_file" .md)

    # Check for template or description in frontmatter
    has_template=$(grep -c '^template:' "$cmd_file" 2>/dev/null || true)
    has_description=$(grep -c '^description:' "$cmd_file" 2>/dev/null || true)

    if [ "$has_template" -gt 0 ] || [ "$has_description" -gt 0 ]; then
      check "command '$cmd_name' has template or description" 0
    else
      check "command '$cmd_name' has template or description" 1
    fi
  done
else
  echo "  INFO: commands/ directory not found (optional)"
fi

# --- 5. Check for broken symlinks ---
echo ""
echo "--- Symlinks ---"

BROKEN_LINKS=$(find "$SCAN_DIR" -type l ! -exec test -e {} \; -print 2>/dev/null)
if [ -z "$BROKEN_LINKS" ]; then
  check "no broken symlinks" 0
else
  check "no broken symlinks" 1
  echo "$BROKEN_LINKS" | while read -r link; do
    echo "  Broken: $link"
  done
fi

# --- Summary ---
echo ""
echo "=== Results ==="
if [ $FAILURES -eq 0 ]; then
  echo -e "${GREEN}All checks passed${NC}"
  exit 0
else
  echo -e "${RED}$FAILURES check(s) failed${NC}"
  exit 1
fi
