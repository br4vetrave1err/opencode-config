#!/bin/bash
# Obsidian Design Docs to GitHub Sync Script
# Syncs Obsidian "agent config/" folder to repo's docs/design/
# Runs every 24 hours via cron
# Usage: ./sync-obsidian.sh

VAULT_DOCS="/home/br4vetrave1er/Documents/br4vetrave1er notes/agent config"
REPO_PATH="/home/br4vetrave1er/Desktop/projects/opencode-config"
REPO_DOCS="$REPO_PATH/docs/design"
GITHUB_REPO="https://github.com/br4vetrave1er/opencode-config.git"

echo "=== Obsidian Design Docs Sync ==="
echo "Started at: $(date)"

# Check if vault docs exist
if [ ! -d "$VAULT_DOCS" ]; then
    echo "ERROR: Obsidian docs not found at $VAULT_DOCS"
    exit 1
fi

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Copy Obsidian docs to temp
echo "Copying Obsidian docs..."
rsync -av --exclude='.obsidian' --exclude='.git' --exclude='.trash' "$VAULT_DOCS/" "$TEMP_DIR/"

# Navigate to repo
cd "$REPO_PATH" || exit 1

# Copy to docs/design/
rm -rf "$REPO_DOCS"
mkdir -p "$REPO_DOCS"
cp -r "$TEMP_DIR/"* "$REPO_DOCS/"

# Check for changes
if git diff --quiet && git diff --cached --quiet; then
    echo "No changes to sync"
else
    echo "Syncing changes to GitHub..."

    # Add all files
    git add -A

    # Commit with timestamp
    git commit -m "Sync Obsidian design docs - $(date '+%Y-%m-%d %H:%M')" 2>/dev/null || echo "Nothing to commit"

    # Push
    git push origin main

    echo "Sync completed successfully"
fi

echo "Finished at: $(date)"
echo "=== Sync Complete ==="
