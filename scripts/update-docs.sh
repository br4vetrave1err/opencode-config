#!/usr/bin/env bash
# Update Docs — Intelligently updates all documentation based on current config state
# Usage: bash scripts/update-docs.sh --repo <dir> [--changes <summary>] [--obsidian <dir>]
# Exit 0: Success
# Exit 1: Error

REPO_DIR=""
CHANGES_SUMMARY=""
OBSIDIAN_DIR="$HOME/Documents/br4vetrave1er notes/agent config"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO_DIR="$2"; shift 2 ;;
    --changes) CHANGES_SUMMARY="$2"; shift 2 ;;
    --obsidian) OBSIDIAN_DIR="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [ -z "$REPO_DIR" ]; then
  echo "Usage: $0 --repo <dir> [--changes <summary>] [--obsidian <dir>]"
  exit 1
fi

if [ ! -d "$REPO_DIR" ]; then
  echo -e "${RED}ERROR${NC} Repo directory not found: $REPO_DIR"
  exit 1
fi

DOCS_DIR="$REPO_DIR/docs/design"
OVERVIEW="$DOCS_DIR/00-Overview.md"
CHANGELOG="$DOCS_DIR/04-Updates/Changelog.md"
SKILLS_INDEX="$DOCS_DIR/03-Skills/Skills-Index.md"
AGENT_CATALOG="$DOCS_DIR/03-Skills/Agent-Catalog.md"
COMMAND_CATALOG="$DOCS_DIR/03-Skills/Command-Catalog.md"
MCP_CATALOG="$DOCS_DIR/03-Skills/MCP-Catalog.md"

echo "=== Update Documentation ==="
echo "Repo:     $REPO_DIR"
echo "Obsidian: $OBSIDIAN_DIR"
echo ""

count_files() {
  local dir="$1"
  if [ -d "$dir" ]; then find "$dir" -type f 2>/dev/null | wc -l | tr -d ' '
  else echo "0"; fi
}

count_dirs() {
  local dir="$1"
  if [ -d "$dir" ]; then find "$dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' '
  else echo "0"; fi
}

get_today() { date -u +"%Y-%m-%d"; }

echo "--- Gathering Config State ---"

SKILLS_DIR="$REPO_DIR/skills"
AGENTS_DIR="$REPO_DIR/agents"
COMMANDS_DIR="$REPO_DIR/commands"
SCRIPTS_DIR="$REPO_DIR/scripts"
TESTS_DIR="$REPO_DIR/tests"
WORKFLOWS_DIR="$REPO_DIR/.github/workflows"

SKILLS_COUNT=$(count_files "$SKILLS_DIR")
SKILL_DIRS_COUNT=$(count_dirs "$SKILLS_DIR")
AGENTS_COUNT=$(count_files "$AGENTS_DIR")
COMMANDS_COUNT=$(count_files "$COMMANDS_DIR")
SCRIPTS_COUNT=$(count_files "$SCRIPTS_DIR")
TESTS_COUNT=$(count_files "$TESTS_DIR")
WORKFLOWS_COUNT=$(count_files "$WORKFLOWS_DIR")

MCP_LOCAL=0
MCP_REMOTE=0
if [ -f "$REPO_DIR/opencode.json" ]; then
  MCP_LOCAL=$(jq '[.mcp[] | select(.type == "local")] | length' "$REPO_DIR/opencode.json" 2>/dev/null || echo "0")
  MCP_REMOTE=$(jq '[.mcp[] | select(.type == "remote")] | length' "$REPO_DIR/opencode.json" 2>/dev/null || echo "0")
fi
MCP_TOTAL=$((MCP_LOCAL + MCP_REMOTE))

CUSTOM_AGENTS=0
if [ -d "$AGENTS_DIR" ]; then
  CUSTOM_AGENTS=$(find "$AGENTS_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
fi

STATUS="Active — $SKILLS_COUNT skills, $CUSTOM_AGENTS agents, $COMMANDS_COUNT commands"

echo "Skills:      $SKILLS_COUNT ($SKILL_DIRS_COUNT directories)"
echo "Agents:      $CUSTOM_AGENTS custom"
echo "Commands:    $COMMANDS_COUNT"
echo "Scripts:     $SCRIPTS_COUNT"
echo "Tests:       $TESTS_COUNT total"
echo "MCP:         $MCP_TOTAL ($MCP_LOCAL local + $MCP_REMOTE remote)"
echo "Workflows:   $WORKFLOWS_COUNT"
echo ""

echo "--- Updating Overview.md ---"
TODAY=$(get_today)

if [ -f "$OVERVIEW" ]; then
  sed -i "s|\*\*Last Updated:\*\*.*|**Last Updated:** $TODAY|" "$OVERVIEW"
  sed -i "s|\*\*Status:\*\*.*|**Status:** $STATUS|" "$OVERVIEW"
  sed -i "s| Skills |.*| Skills | $SKILLS_COUNT ($SKILL_DIRS_COUNT directories) | ✅ Complete |" "$OVERVIEW"
  sed -i "s| Agents |.*| Agents | $CUSTOM_AGENTS custom subagents | ✅ Complete |" "$OVERVIEW"
  sed -i "s| Commands |.*| Commands | $COMMANDS_COUNT | ✅ Complete |" "$OVERVIEW"
  sed -i "s| Tests |.*| Tests | $TESTS_COUNT | ✅ Complete |" "$OVERVIEW"
  sed -i "s| CI/CD |.*| CI/CD | $WORKFLOWS_COUNT workflows | ✅ Deployed |" "$OVERVIEW"
  sed -i "s| Scripts |.*| Scripts | $SCRIPTS_COUNT | ✅ Complete |" "$OVERVIEW"
  sed -i "s| MCP Servers |.*| MCP Servers | $MCP_TOTAL ($MCP_LOCAL local + $MCP_REMOTE remote) | ✅ Configured |" "$OVERVIEW"
  echo -e "${GREEN}Updated${NC} Overview.md"
else
  echo -e "${YELLOW}WARN${NC} Overview.md not found, creating..."
  mkdir -p "$DOCS_DIR"
  cat > "$OVERVIEW" << EOF
# OpenCode Agent Config — Overview

**Last Updated:** $TODAY
**Status:** $STATUS

---

## Current State

| Component | Count | Status |
|-----------|-------|--------|
| MCP Servers | $MCP_TOTAL ($MCP_LOCAL local + $MCP_REMOTE remote) | ✅ Configured |
| Agents | $CUSTOM_AGENTS custom subagents | ✅ Complete |
| Skills | $SKILLS_COUNT ($SKILL_DIRS_COUNT directories) | ✅ Complete |
| Commands | $COMMANDS_COUNT | ✅ Complete |
| Tests | $TESTS_COUNT | ✅ Complete |
| CI/CD | $WORKFLOWS_COUNT workflows | ✅ Deployed |
| Scripts | $SCRIPTS_COUNT | ✅ Complete |
EOF
  echo -e "${GREEN}Created${NC} Overview.md"
fi

if [ -f "$SKILLS_INDEX" ]; then
  echo "--- Updating Skills Index ---"
  sed -i "s|Total Skills:.*|Total Skills: $SKILLS_COUNT|" "$SKILLS_INDEX"
  sed -i "s|Last Updated:.*|Last Updated: $TODAY|" "$SKILLS_INDEX"
  echo -e "${GREEN}Updated${NC} Skills Index"
fi

if [ -f "$AGENT_CATALOG" ]; then
  echo "--- Updating Agent Catalog ---"
  sed -i "s|Total Agents:.*|Total Agents: $CUSTOM_AGENTS|" "$AGENT_CATALOG"
  sed -i "s|Last Updated:.*|Last Updated: $TODAY|" "$AGENT_CATALOG"
  echo -e "${GREEN}Updated${NC} Agent Catalog"
fi

if [ -f "$COMMAND_CATALOG" ]; then
  echo "--- Updating Command Catalog ---"
  sed -i "s|Total Commands:.*|Total Commands: $COMMANDS_COUNT|" "$COMMAND_CATALOG"
  sed -i "s|Last Updated:.*|Last Updated: $TODAY|" "$COMMAND_CATALOG"
  echo -e "${GREEN}Updated${NC} Command Catalog"
fi

if [ -f "$MCP_CATALOG" ]; then
  echo "--- Updating MCP Catalog ---"
  sed -i "s|Total MCP Servers:.*|Total MCP Servers: $MCP_TOTAL|" "$MCP_CATALOG"
  sed -i "s|Last Updated:.*|Last Updated: $TODAY|" "$MCP_CATALOG"
  echo -e "${GREEN}Updated${NC} MCP Catalog"
fi

echo "--- Updating Changelog.md ---"
if [ -n "$CHANGES_SUMMARY" ]; then
  TODAY=$(get_today)
  CHANGELOG_TMP=$(mktemp)

  if grep -q "## $TODAY:" "$CHANGELOG" 2>/dev/null; then
    echo -e "${YELLOW}Today's entry exists, appending changes${NC}"
    while IFS= read -r line; do
      echo "$line"
      if [[ "$line" == "## $TODAY:"* ]]; then
        echo ""
        echo "### Additional Changes"
        echo "- $CHANGES_SUMMARY"
      fi
    done < "$CHANGELOG" > "$CHANGELOG_TMP"
  else
    echo "# Updates Changelog" > "$CHANGELOG_TMP"
    echo "" >> "$CHANGELOG_TMP"
    echo "All changes to the AI agent configuration, tracked by date." >> "$CHANGELOG_TMP"
    echo "" >> "$CHANGELOG_TMP"
    echo "---" >> "$CHANGELOG_TMP"
    echo "" >> "$CHANGELOG_TMP"
    echo "## $TODAY: Auto-Sync Update" >> "$CHANGELOG_TMP"
    echo "" >> "$CHANGELOG_TMP"
    echo "### What Changed" >> "$CHANGELOG_TMP"
    echo "- $CHANGES_SUMMARY" >> "$CHANGELOG_TMP"
    echo "" >> "$CHANGELOG_TMP"
    echo "### Current State" >> "$CHANGELOG_TMP"
    echo "- **Skills:** $SKILLS_COUNT ($SKILL_DIRS_COUNT directories)" >> "$CHANGELOG_TMP"
    echo "- **Agents:** $CUSTOM_AGENTS custom" >> "$CHANGELOG_TMP"
    echo "- **Commands:** $COMMANDS_COUNT" >> "$CHANGELOG_TMP"
    echo "- **Scripts:** $SCRIPTS_COUNT" >> "$CHANGELOG_TMP"
    echo "- **Tests:** $TESTS_COUNT total" >> "$CHANGELOG_TMP"
    echo "- **MCP:** $MCP_TOTAL ($MCP_LOCAL local + $MCP_REMOTE remote)" >> "$CHANGELOG_TMP"
    echo "- **Workflows:** $WORKFLOWS_COUNT" >> "$CHANGELOG_TMP"
    echo "" >> "$CHANGELOG_TMP"
    echo "---" >> "$CHANGELOG_TMP"
  fi

  mv "$CHANGELOG_TMP" "$CHANGELOG"
  echo -e "${GREEN}Updated${NC} Changelog.md"
else
  echo -e "${YELLOW}No changes summary provided, skipping changelog update${NC}"
fi

echo "--- Syncing to Obsidian ---"
if [ -d "$OBSIDIAN_DIR" ]; then
  rsync -av --delete "$DOCS_DIR/" "$OBSIDIAN_DIR/" 2>&1 | grep -v "/$" | while read -r line; do
    echo "  $line"
  done
  echo -e "${GREEN}Synced${NC} docs/design/ → Obsidian"
else
  echo -e "${YELLOW}WARN${NC} Obsidian directory not found: $OBSIDIAN_DIR"
fi

echo ""
echo -e "${GREEN}Documentation update complete${NC}"
exit 0
