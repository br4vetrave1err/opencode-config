#!/usr/bin/env bash
# Auto-Sync — Detects changes, syncs to repo, updates docs, commits & pushes
# Usage: bash scripts/auto-sync.sh [--local <dir>] [--repo <dir>] [--push] [--dry-run]
# Exit 0: Success
# Exit 1: Error

LOCAL_DIR="$HOME/.config/opencode"
REPO_DIR="$HOME/Desktop/projects/opencode-config"
PUSH=false
DRY_RUN=false

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --local) LOCAL_DIR="$2"; shift 2 ;;
    --repo) REPO_DIR="$2"; shift 2 ;;
    --push) PUSH=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Validate directories
if [ ! -d "$LOCAL_DIR" ]; then
  echo -e "${RED}ERROR${NC} Local directory not found: $LOCAL_DIR"
  exit 1
fi

if [ ! -d "$REPO_DIR" ]; then
  echo -e "${RED}ERROR${NC} Repo directory not found: $REPO_DIR"
  exit 1
fi

if [ ! -d "$REPO_DIR/.git" ]; then
  echo -e "${RED}ERROR${NC} Not a git repo: $REPO_DIR"
  exit 1
fi

echo "=== Auto-Sync ==="
echo "Local: $LOCAL_DIR"
echo "Repo:  $REPO_DIR"
echo "Push:  $PUSH"
echo "Dry:   $DRY_RUN"
echo ""

# --- Step 1: Detect Changes ---
echo "--- Detecting Changes ---"

CHANGES=()
CHANGE_SUMMARY=""

# Compare directories
for dir in agents commands skills scripts plugins; do
  if [ -d "$LOCAL_DIR/$dir" ]; then
    local_count=$(find "$LOCAL_DIR/$dir" -type f 2>/dev/null | wc -l | tr -d ' ')
    repo_count=0
    if [ -d "$REPO_DIR/$dir" ]; then
      repo_count=$(find "$REPO_DIR/$dir" -type f 2>/dev/null | wc -l | tr -d ' ')
    fi
    if [ "$local_count" != "$repo_count" ]; then
      CHANGES+=("$dir:$local_count:$repo_count")
      CHANGE_SUMMARY+="$dir: $repo_count → $local_count files; "
    fi
  fi
done

# Check opencode.json
if [ -f "$LOCAL_DIR/opencode.json" ] && [ -f "$REPO_DIR/opencode.json" ]; then
  local_json=$(jq -S '.' "$LOCAL_DIR/opencode.json" 2>/dev/null)
  repo_json=$(jq -S '.' "$REPO_DIR/opencode.json" 2>/dev/null)
  if [ "$local_json" != "$repo_json" ]; then
    CHANGES+=("opencode.json")
    CHANGE_SUMMARY+="opencode.json modified; "
  fi
elif [ -f "$LOCAL_DIR/opencode.json" ] && [ ! -f "$REPO_DIR/opencode.json" ]; then
  CHANGES+=("opencode.json")
  CHANGE_SUMMARY+="opencode.json added; "
fi

# Check tui.json
if [ -f "$LOCAL_DIR/tui.json" ] && [ -f "$REPO_DIR/tui.json" ]; then
  local_tui=$(jq -S '.' "$LOCAL_DIR/tui.json" 2>/dev/null)
  repo_tui=$(jq -S '.' "$REPO_DIR/tui.json" 2>/dev/null)
  if [ "$local_tui" != "$repo_tui" ]; then
    CHANGES+=("tui.json")
    CHANGE_SUMMARY+="tui.json modified; "
  fi
fi

# Check AGENTS.md
if [ -f "$LOCAL_DIR/AGENTS.md" ] && [ -f "$REPO_DIR/AGENTS.md" ]; then
  if ! diff -q "$LOCAL_DIR/AGENTS.md" "$REPO_DIR/AGENTS.md" > /dev/null 2>&1; then
    CHANGES+=("AGENTS.md")
    CHANGE_SUMMARY+="AGENTS.md modified; "
  fi
fi

# Check for new files in local that don't exist in repo
while IFS= read -r -d '' file; do
  rel_path="${file#$LOCAL_DIR/}"
  if [ ! -f "$REPO_DIR/$rel_path" ]; then
    CHANGES+=("new:$rel_path")
    CHANGE_SUMMARY+="new file: $rel_path; "
  fi
done < <(find "$LOCAL_DIR" -type f -not -path "*/.git/*" -not -path "*/node_modules/*" -not -path "*/.obsidian/*" -print0 2>/dev/null)

# Check for deleted files (in repo but not in local)
while IFS= read -r -d '' file; do
  rel_path="${file#$REPO_DIR/}"
  if [ ! -f "$LOCAL_DIR/$rel_path" ]; then
    CHANGES+=("deleted:$rel_path")
    CHANGE_SUMMARY+="deleted: $rel_path; "
  fi
done < <(find "$REPO_DIR" -type f -not -path "*/.git/*" -not -path "*/node_modules/*" -not -path "*/docs/*" -not -path "*/.github/*" -print0 2>/dev/null)

if [ ${#CHANGES[@]} -eq 0 ]; then
  echo -e "${GREEN}No changes detected${NC}"
  exit 0
fi

echo -e "${YELLOW}Changes detected:${NC}"
for change in "${CHANGES[@]}"; do
  echo "  - $change"
done
echo ""

if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}Dry run — stopping here${NC}"
  exit 0
fi

# --- Step 2: Sync to Repo ---
echo "--- Syncing to Repo ---"
bash "$REPO_DIR/scripts/sync-to-repo.sh" --local "$LOCAL_DIR" --repo "$REPO_DIR"
echo ""

# --- Step 3: Update Documentation ---
echo "--- Updating Documentation ---"
bash "$REPO_DIR/scripts/update-docs.sh" --repo "$REPO_DIR" --changes "$CHANGE_SUMMARY"
echo ""

# --- Step 4: Commit and Push ---
echo "--- Committing Changes ---"
cd "$REPO_DIR"

git add -A

if git diff --cached --quiet; then
  echo -e "${GREEN}Nothing to commit${NC}"
  exit 0
fi

# Generate commit message
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M UTC")
COMMIT_MSG="auto: sync and docs update — $TIMESTAMP"

if [ ${#CHANGES[@]} -le 5 ]; then
  CHANGE_LIST=""
  for change in "${CHANGES[@]}"; do
    CHANGE_LIST+="$change, "
  done
  COMMIT_MSG="auto: sync — ${CHANGE_LIST%, } — $TIMESTAMP"
fi

git commit -m "$COMMIT_MSG"
echo -e "${GREEN}Committed:${NC} $COMMIT_MSG"

if [ "$PUSH" = true ]; then
  echo "--- Pushing to Remote ---"
  git push
  echo -e "${GREEN}Pushed to remote${NC}"
else
  echo -e "${YELLOW}Push skipped (use --push to enable)${NC}"
fi

echo ""
echo -e "${GREEN}Auto-sync complete${NC}"
exit 0
