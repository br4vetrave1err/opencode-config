# Windows Task Scheduler Setup
# Run as Administrator in PowerShell

$TASK_NAME = "ObsidianVaultSync"
$SCRIPT_PATH = "$env:USERPROFILE\Desktop\projects\opencode-config\scripts\sync-obsidian.ps1"
$LOG_PATH = "$env:USERPROFILE\.obsidian-sync.log"

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Host "Running as Administrator - OK"
} else {
    Write-Host "NOTE: Run as Administrator to install system-wide task"
    Write-Host "Running as current user instead..."
}

# Create action
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$SCRIPT_PATH`""

# Create trigger (daily at 6 AM)
$Trigger = New-ScheduledTaskTrigger -Daily -At "6:00AM"

# Create settings
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Register task
try {
    Unregister-ScheduledTask -TaskName $TASK_NAME -Confirm:$false -ErrorAction SilentlyContinue
}

Register-ScheduledTask -TaskName $TASK_NAME -Action $Action -Trigger $Trigger -Settings $Settings -Description "Daily Obsidian vault sync to GitHub" -Force

Write-Host ""
Write-Host "Task '$TASK_NAME' created successfully!"
Write-Host "Schedule: Daily at 6:00 AM"
Write-Host ""
Write-Host "Other commands:"
Write-Host "  Get-ScheduledTask -TaskName $TASK_NAME"
Write-Host "  Unregister-ScheduledTask -TaskName $TASK_NAME"
Write-Host "  Start-ScheduledTask -TaskName $TASK_NAME"