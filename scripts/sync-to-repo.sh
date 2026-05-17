#!/usr/bin/env bash
# Sync to Repo — Copies local config to git repo mirror, excluding secrets
# Usage: bash scripts/sync-to-repo.sh --local <dir> --repo <dir>
# Exit 0: Success
# Exit 1: Error

LOCAL_DIR=""
REPO_DIR=""

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

if [ ! -d "$LOCAL_DIR" ]; then
  echo -e "${RED}ERROR${NC} Local directory not found: $LOCAL_DIR"
  exit 1
fi

if [ ! -d "$REPO_DIR" ]; then
  echo -e "${RED}ERROR${NC} Repo directory not found: $REPO_DIR"
  exit 1
fi

echo "=== Sync to Repo ==="
echo "Local: $LOCAL_DIR"
echo "Repo:  $REPO_DIR"
echo ""

# Files/dirs to exclude
EXCLUDES=(
  ".git"
  "node_modules"
  ".obsidian"
  "__pycache__"
  ".venv"
  "venv"
  ".DS_Store"
  "*.lock"
  "*.log"
)

# Build rsync exclude args
EXCLUDE_ARGS=()
for exc in "${EXCLUDES[@]}"; do
  EXCLUDE_ARGS+=("--exclude=$exc")
done

# Sanitize opencode.json before syncing (remove secrets)
if [ -f "$LOCAL_DIR/opencode.json" ]; then
  echo "--- Sanitizing opencode.json ---"
  # Create a sanitized copy
  SANITIZED=$(jq '
    walk(if type == "object" then
      with_entries(
        if (.value | type == "string") and
           (.value | test("ghp_|ATATT|sk-[a-zA-Z0-9]|AKIA[0-9]|AIza|eyJ")) then
          .value = "***REDACTED***"
        else . end
      )
    else . end)' "$LOCAL_DIR/opencode.json" 2>/dev/null)

  if [ $? -eq 0 ] && [ -n "$SANITIZED" ]; then
    echo "$SANITIZED" > "$REPO_DIR/opencode.json"
    echo -e "${GREEN}SYNCED${NC} opencode.json (sanitized)"
  else
    echo -e "${YELLOW}WARN${NC} Could not sanitize opencode.json, copying as-is"
    cp "$LOCAL_DIR/opencode.json" "$REPO_DIR/opencode.json"
  fi
  echo ""
fi

# Sync remaining files
echo "--- Syncing Files ---"
rsync -av --delete "${EXCLUDE_ARGS[@]}" \
  "$LOCAL_DIR/" "$REPO_DIR/" \
  --exclude="opencode.json" \
  2>&1 | grep -v "/$" | while read -r line; do
    echo "  $line"
  done

echo ""
echo -e "${GREEN}Sync complete${NC}"
echo "Review changes in: $REPO_DIR"
echo "Then commit and push."

exit 0
