# Obsidian to GitHub Sync Script
# Runs every 24 hours via Windows Task Scheduler
# Save as sync-obsidian.ps1

param(
    [string]$VaultPath = "$env:USERPROFILE\Documents\br4vetrave1er notes",
    [string]$RepoPath = "$env:USERPROFILE\Desktop\projects\opencode-config\skills\obsidian-vault",
    [string]$GithubRepo = "https://github.com/br4vetrave1err/opencode-config.git"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Obsidian Vault Sync ==="
Write-Host "Started at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# Check if vault exists
if (-not (Test-Path $VaultPath)) {
    Write-Host "ERROR: Vault not found at $VaultPath"
    exit 1
}

# Create temp directory
$TempDir = [System.IO.Path]::GetTempPath() + "obsidian-sync-" + (Get-Random)
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

try {
    # Copy vault contents (exclude obsidian, git, trash folders)
    Write-Host "Copying vault contents..."
    Get-ChildItem -Path $VaultPath -Exclude '.obsidian', '.git', '.trash' -Recurse | ForEach-Object {
        $Destination = $_.FullName.Replace($VaultPath, $TempDir)
        if ($_.PSIsContainer) {
            if (-not (Test-Path $Destination)) {
                New-Item -ItemType Directory -Path $Destination -Force | Out-Null
            }
        } else {
            $DestinationDir = Split-Path $Destination -Parent
            if (-not (Test-Path $DestinationDir)) {
                New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null
            }
            Copy-Item $_.FullName -Destination $Destination -Force
        }
    }

    # Navigate to repo
    Set-Location $RepoPath

    # Check for changes
    $HasChanges = (git status --porcelain) -ne ""

    if (-not $HasChanges) {
        Write-Host "No changes to sync"
    } else {
        Write-Host "Syncing changes to GitHub..."

        # Add all files
        git add -A

        # Commit with timestamp
        $CommitMessage = "Sync Obsidian vault - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        git commit -m $CommitMessage 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Nothing to commit"
        }

        # Push
        git push origin main

        if ($LASTEXITCODE -eq 0) {
            Write-Host "Sync completed successfully"
        } else {
            Write-Host "ERROR: Push failed"
            exit 1
        }
    }
} finally {
    # Cleanup temp directory
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Finished at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "=== Sync Complete ==="