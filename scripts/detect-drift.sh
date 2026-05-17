#!/usr/bin/env bash
# Drift Detection — Compares local config against git repo mirror
# Usage: bash scripts/detect-drift.sh --local <dir> --repo <dir>
# Exit 0: No drift (synced)
# Exit 1: Drift detected

LOCAL_DIR=""
REPO_DIR=""
DRIFT_COUNT=0
DRIFT_FILES=()

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --local) LOCAL_DIR="$2"; shift 2 ;;
    --repo) REPO_DIR="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [ -z "$LOCAL_DIR" ] || [ -z "$REPO_DIR" ]; then
  echo "Usage: $0 --local <dir> --repo <dir>"
  exit 1
fi

echo "=== Drift Detection ==="
echo "Local: $LOCAL_DIR"
echo "Repo:  $REPO_DIR"
echo ""

# Check directories exist
if [ ! -d "$LOCAL_DIR" ]; then
  echo -e "${RED}ERROR${NC} Local directory not found: $LOCAL_DIR"
  exit 1
fi

if [ ! -d "$REPO_DIR" ]; then
  echo -e "${RED}ERROR${NC} Repo directory not found: $REPO_DIR"
  exit 1
fi

# --- 1. Check opencode.json ---
echo "--- opencode.json ---"

LOCAL_CONFIG="$LOCAL_DIR/opencode.json"
REPO_CONFIG="$REPO_DIR/opencode.json"

if [ ! -f "$LOCAL_CONFIG" ]; then
  echo -e "${RED}DRIFT${NC} opencode.json missing from local"
  DRIFT_COUNT=$((DRIFT_COUNT + 1))
  DRIFT_FILES+=("opencode.json (missing from local)")
elif [ ! -f "$REPO_CONFIG" ]; then
  echo -e "${RED}DRIFT${NC} opencode.json missing from repo"
  DRIFT_COUNT=$((DRIFT_COUNT + 1))
  DRIFT_FILES+=("opencode.json (missing from repo)")
else
  # Validate JSON
  if ! jq empty "$LOCAL_CONFIG" 2>/dev/null; then
    echo -e "${RED}DRIFT${NC} opencode.json has invalid JSON in local"
    DRIFT_COUNT=$((DRIFT_COUNT + 1))
    DRIFT_FILES+=("opencode.json (invalid JSON in local)")
  elif ! diff -q "$LOCAL_CONFIG" "$REPO_CONFIG" >/dev/null 2>&1; then
    echo -e "${RED}DRIFT${NC} opencode.json differs"
    DRIFT_COUNT=$((DRIFT_COUNT + 1))
    DRIFT_FILES+=("opencode.json")
    # Show diff summary
    diff "$LOCAL_CONFIG" "$REPO_CONFIG" | head -20 | while read -r line; do
      echo "  $line"
    done
  else
    echo -e "${GREEN}SYNCED${NC} opencode.json"
  fi
fi

# --- 2. Compare file inventory ---
echo ""
echo "--- File Inventory ---"

# Get relative file lists (excluding .git, node_modules, etc.)
get_files() {
  local dir="$1"
  (cd "$dir" && find . -type f \
    -not -path "./.git/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/.obsidian/*" \
    -not -path "*/__pycache__/*" \
    -not -name "*.lock" \
    -not -name "*.log" \
    -not -name ".DS_Store" \
    | sed 's|^\./||' | sort)
}

LOCAL_FILES=$(get_files "$LOCAL_DIR")
REPO_FILES=$(get_files "$REPO_DIR")

# Files in local but not in repo
ONLY_LOCAL=$(comm -23 <(echo "$LOCAL_FILES") <(echo "$REPO_FILES"))
if [ -n "$ONLY_LOCAL" ]; then
  echo -e "${YELLOW}NEW in local (not in repo):${NC}"
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    echo "  + $f"
    DRIFT_COUNT=$((DRIFT_COUNT + 1))
    DRIFT_FILES+=("$f (new in local)")
  done <<< "$ONLY_LOCAL"
fi

# Files in repo but not in local
ONLY_REPO=$(comm -13 <(echo "$LOCAL_FILES") <(echo "$REPO_FILES"))
if [ -n "$ONLY_REPO" ]; then
  echo -e "${YELLOW}MISSING from local (in repo):${NC}"
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    echo "  - $f"
    DRIFT_COUNT=$((DRIFT_COUNT + 1))
    DRIFT_FILES+=("$f (missing from local)")
  done <<< "$ONLY_REPO"
fi

# --- 3. Compare common files ---
echo ""
echo "--- Content Comparison ---"

COMMON_FILES=$(comm -12 <(echo "$LOCAL_FILES") <(echo "$REPO_FILES"))
if [ -n "$COMMON_FILES" ]; then
  while IFS= read -r file; do
    [ -z "$file" ] && continue
    if ! diff -q "$LOCAL_DIR/$file" "$REPO_DIR/$file" >/dev/null 2>&1; then
      echo -e "${RED}DRIFT${NC} $file"
      DRIFT_COUNT=$((DRIFT_COUNT + 1))
      DRIFT_FILES+=("$file (content differs)")
    else
      echo -e "${GREEN}SYNCED${NC} $file"
    fi
  done <<< "$COMMON_FILES"
fi

# --- Summary ---
echo ""
echo "=== Summary ==="
if [ $DRIFT_COUNT -eq 0 ]; then
  echo -e "${GREEN}No drift detected — local and repo are in sync${NC}"
  exit 0
else
  echo -e "${RED}Drift detected: $DRIFT_COUNT file(s) differ${NC}"
  echo ""
  echo "Drifted files:"
  for f in "${DRIFT_FILES[@]}"; do
    echo "  - $f"
  done
  echo ""
  echo "To sync, run: bash scripts/sync-to-repo.sh"
  exit 1
fi
