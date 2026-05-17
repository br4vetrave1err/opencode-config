#!/usr/bin/env bash
# Changelog Generator — Generates changelog from git commits
# Usage: bash scripts/generate-changelog.sh --repo <dir> [--output <file>] [--limit N] [--since DATE]
# Exit 0: Success
# Exit 1: Error

REPO_DIR=""
OUTPUT_FILE=""
LIMIT=50
SINCE=""

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO_DIR="$2"; shift 2 ;;
    --output) OUTPUT_FILE="$2"; shift 2 ;;
    --limit) LIMIT="$2"; shift 2 ;;
    --since) SINCE="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [ -z "$REPO_DIR" ]; then
  echo "Usage: $0 --repo <dir> [--output <file>] [--limit N] [--since DATE]"
  exit 1
fi

if [ ! -d "$REPO_DIR/.git" ]; then
  echo -e "${RED}ERROR${NC} Not a git repo: $REPO_DIR"
  exit 1
fi

# Build git log command
GIT_ARGS=("--format=%h|%ad|%s" "--date=short" "-n" "$LIMIT")
if [ -n "$SINCE" ]; then
  GIT_ARGS+=("--since=$SINCE")
fi

COMMITS=$(git -C "$REPO_DIR" log "${GIT_ARGS[@]}" 2>/dev/null)

if [ -z "$COMMITS" ]; then
  echo "No commits found."
  exit 0
fi

# Generate changelog
generate_changelog() {
  echo "# Changelog"
  echo ""
  echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
  echo "Repository: $REPO_DIR"
  echo ""

  # Group commits by type
  local feat_commits=()
  local fix_commits=()
  local chore_commits=()
  local other_commits=()

  while IFS='|' read -r hash date message; do
    [ -z "$hash" ] && continue
    if echo "$message" | grep -qi '^feat'; then
      feat_commits+=("$hash|$date|$message")
    elif echo "$message" | grep -qi '^fix'; then
      fix_commits+=("$hash|$date|$message")
    elif echo "$message" | grep -qi '^chore'; then
      chore_commits+=("$hash|$date|$message")
    else
      other_commits+=("$hash|$date|$message")
    fi
  done <<< "$COMMITS"

  # Features
  if [ ${#feat_commits[@]} -gt 0 ]; then
    echo "## Features"
    echo ""
    for entry in "${feat_commits[@]}"; do
      IFS='|' read -r hash date message <<< "$entry"
      echo "- \`$hash\` $date — $message"
    done
    echo ""
  fi

  # Fixes
  if [ ${#fix_commits[@]} -gt 0 ]; then
    echo "## Fixes"
    echo ""
    for entry in "${fix_commits[@]}"; do
      IFS='|' read -r hash date message <<< "$entry"
      echo "- \`$hash\` $date — $message"
    done
    echo ""
  fi

  # Chores
  if [ ${#chore_commits[@]} -gt 0 ]; then
    echo "## Chores"
    echo ""
    for entry in "${chore_commits[@]}"; do
      IFS='|' read -r hash date message <<< "$entry"
      echo "- \`$hash\` $date — $message"
    done
    echo ""
  fi

  # Other
  if [ ${#other_commits[@]} -gt 0 ]; then
    echo "## Other Changes"
    echo ""
    for entry in "${other_commits[@]}"; do
      IFS='|' read -r hash date message <<< "$entry"
      echo "- \`$hash\` $date — $message"
    done
    echo ""
  fi
}

# Output
if [ -n "$OUTPUT_FILE" ]; then
  generate_changelog > "$OUTPUT_FILE"
  echo "Changelog written to: $OUTPUT_FILE"
else
  generate_changelog
fi

exit 0
