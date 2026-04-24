# Continuous Docker Log Monitor for Windows
# Usage: .\monitor.ps1 -Container "my-app"

param(
    [string]$Container = "",
    [string]$LogFile = "$env:USERPROFILE\.docker-monitor.log",
    [string]$ErrorFile = "$env:USERPROFILE\.docker-monitor-errors.log",
    [int]$IntervalSeconds = 10
)

$ErrorActionPreference = "SilentlyContinue"

function Write-Log {
    param([string]$Message, [switch]$Error)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $line = "$timestamp $Message"
    $line | Tee-Object -FilePath $LogFile -Append
    if ($Error) {
        $line | Tee-Object -FilePath $ErrorFile -Append
    }
}

Write-Log "=== Docker Monitor Started at $(Get-Date) ==="

$seenErrors = @{}

while ($true) {
    try {
        $containers = if ($Container) { 
            docker ps --format '{{.Names}}' | Where-Object { $_ -match $Container } 
        } else { 
            docker ps --format '{{.Names}}' 
        }
        
        foreach ($c in $containers) {
            $status = docker inspect $c --format='{{.State.Status}}'
            
            if ($status -ne "running") {
                Write-Log "WARNING: $c is not running (status: $status)"
                continue
            }
            
            $logs = docker logs $c 2>&1 | Select-Object -Last 30
            
            $logs | ForEach-Object {
                if ($_ -match "(error|exception|fatal|failed|panic)") {
                    $fingerprint = $_.Substring(0, [Math]::Min(50, $_.Length))
                    if (-not $seenErrors.ContainsKey($fingerprint)) {
                        $seenErrors[$fingerprint] = $true
                        "$c : $_" | Tee-Object -FilePath $ErrorFile -Append
                        Write-Log "$c : $_" -Error
                    }
                }
            }
        }
        
        # Check for stopped containers
        $stopped = docker ps -a --filter "status=exited" --filter "status=restarting" --format '{{.Names}}'
        if ($stopped) {
            Write-Log "ALERT: Stopped containers: $stopped"
        }
        
    } catch {
        Write-Log "ERROR: $($_.Exception.Message)"
    }
    
    Start-Sleep -Seconds $IntervalSeconds
}