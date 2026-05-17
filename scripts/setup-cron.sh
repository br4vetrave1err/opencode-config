# Setup Cron Job for Obsidian Design Docs Sync
# This script sets up the daily sync cron job

SCRIPT_PATH="/home/br4vetrave1er/Desktop/projects/opencode-config/scripts/sync-obsidian.sh"
CRON_JOB="0 6 * * * /bin/bash $SCRIPT_PATH >> /home/br4vetrave1er/.obsidian-design-docs-sync.log 2>&1"

echo "Setting up daily Obsidian design docs sync cron job..."
echo "Schedule: Daily at 6:00 AM"
echo "Syncs: Obsidian 'agent config/' → repo docs/design/"

# Add to crontab
(crontab -l 2>/dev/null | grep -v "sync-obsidian.sh"; echo "$CRON_JOB") | crontab -

echo "Cron job installed. Current crontab:"
crontab -l | grep sync

echo ""
echo "To manually run: $SCRIPT_PATH"
echo "To remove: crontab -l | grep -v sync-obsidian.sh | crontab -"