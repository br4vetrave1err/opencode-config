# Obsidian Design Docs to GitHub Sync Script
# Runs every 24 hours via Windows Task Scheduler
# Syncs Obsidian "agent config/" folder to repo's docs/design/
# Save as sync-obsidian.ps1

param(
    [string]$VaultDocs = "$env:USERPROFILE\Documents\br4vetrave1er notes\agent config",
    [string]$RepoPath = "$env:USERPROFILE\Desktop\projects\opencode-config",
    [string]$RepoDocs = "$env:USERPROFILE\Desktop\projects\opencode-config\docs\design",
    [string]$GithubRepo = "https://github.com/br4vetrave1er/opencode-config.git"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Obsidian Design Docs Sync ==="
Write-Host "Started at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# Check if vault docs exist
if (-not (Test-Path $VaultDocs)) {
    Write-Host "ERROR: Obsidian docs not found at $VaultDocs"
    exit 1
}

# Create temp directory
$TempDir = [System.IO.Path]::GetTempPath() + "obsidian-sync-" + (Get-Random)
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

try {
    # Copy Obsidian docs to temp (exclude obsidian, git, trash folders)
    Write-Host "Copying Obsidian docs..."
    Get-ChildItem -Path $VaultDocs -Exclude '.obsidian', '.git', '.trash' -Recurse | ForEach-Object {
        $Destination = $_.FullName.Replace($VaultDocs, $TempDir)
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

    # Copy to docs/design/
    if (Test-Path $RepoDocs) {
        Remove-Item -Path $RepoDocs -Recurse -Force
    }
    New-Item -ItemType Directory -Path $RepoDocs -Force | Out-Null
    Copy-Item -Path "$TempDir\*" -Destination $RepoDocs -Recurse -Force

    # Check for changes
    $HasChanges = (git status --porcelain) -ne ""

    if (-not $HasChanges) {
        Write-Host "No changes to sync"
    } else {
        Write-Host "Syncing changes to GitHub..."

        # Add all files
        git add -A

        # Commit with timestamp
        $CommitMessage = "Sync Obsidian design docs - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
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
