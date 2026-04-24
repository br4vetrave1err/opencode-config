#!/bin/bash
# Obsidian to GitHub Sync Script
# Runs every 24 hours via cron
# Usage: ./sync-obsidian.sh

VAULT_PATH="/home/br4vetrave1er/Documents/br4vetrave1er notes"
REPO_PATH="/home/br4vetrave1er/Desktop/projects/opencode-config/skills/obsidian-vault"
GITHUB_REPO="https://github.com/br4vetrave1err/opencode-config.git"

echo "=== Obsidian Vault Sync ==="
echo "Started at: $(date)"

# Check if vault exists
if [ ! -d "$VAULT_PATH" ]; then
    echo "ERROR: Vault not found at $VAULT_PATH"
    exit 1
fi

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Copy vault contents
echo "Copying vault contents..."
rsync -av --exclude='.obsidian' --exclude='.git' --exclude='.trash' "$VAULT_PATH/" "$TEMP_DIR/"

# Navigate to repo
cd "$REPO_PATH" || exit 1

# Check for changes
if git diff --quiet && git diff --cached --quiet; then
    echo "No changes to sync"
else
    echo "Syncing changes to GitHub..."

    # Add all files
    git add -A

    # Commit with timestamp
    git commit -m "Sync Obsidian vault - $(date '+%Y-%m-%d %H:%M')" 2>/dev/null || echo "Nothing to commit"

    # Push
    git push origin main

    echo "Sync completed successfully"
fi

echo "Finished at: $(date)"
echo "=== Sync Complete ==="