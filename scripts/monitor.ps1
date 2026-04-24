# Continuous Docker Log Monitor for Windows with Makefile Control
# Usage: .\monitor.ps1 -Makefile "C:\path\to\Makefile" -Target "up"

param(
    [Parameter(Mandatory=$false)]
    [string]$Makefile = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Target = "up",
    
    [string]$LogFile = "$env:USERPROFILE\.docker-monitor.log",
    [string]$ErrorFile = "$env:USERPROFILE\.docker-monitor-errors.log",
    [int]$IntervalSeconds = 10
)

$ErrorActionPreference = "SilentlyContinue"

# If no Makefile provided, prompt for it
if (-not $Makefile) {
    Write-Host "Enter path to Makefile (or drag and drop):" -ForegroundColor Yellow
    $Makefile = Read-Host "Makefile path"
}

# Resolve full path
$Makefile = (Resolve-Path $Makefile -ErrorAction SilentlyContinue).Path
if (-not $Makefile -or -not (Test-Path $Makefile)) {
    Write-Host "ERROR: Makefile not found at $Makefile" -ForegroundColor Red
    exit 1
}

$ProjectDir = Split-Path $Makefile -Parent
$ProjectName = Split-Path $ProjectDir -Leaf
$OriginalDir = Get-Location

try {
    Set-Location $ProjectDir
} catch {
    Write-Host "ERROR: Could not access project directory: $ProjectDir" -ForegroundColor Red
    exit 1
}

function Write-Log {
    param([string]$Message, [switch]$Error)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $line = "$timestamp $Message"
    $line | Tee-Object -FilePath $LogFile -Append
    if ($Error) {
        $line | Tee-Object -FilePath $ErrorFile -Append
    }
}

function Show-MakefileTargets {
    if (Test-Path $Makefile) {
        Write-Host "Available targets in Makefile:" -ForegroundColor Cyan
        Get-Content $Makefile | Select-String -Pattern "^[a-zA-Z0-9_-]+:" | ForEach-Object {
            $_.Line -replace ":.*", ""
        } | Select-Object -First 15
    }
}

function Start-Project {
    Write-Log "Starting project with: make $Target"
    
    # Try the specified target first
    $output = make $Target 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Started successfully with 'make $Target'"
        Start-Sleep -Seconds 5
        return $true
    }
    
    # Try common alternatives
    $alternatives = @("dev", "start", "run", "build")
    foreach ($alt in $alternatives) {
        if ($alt -ne $Target) {
            $output = make $alt 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Started with 'make $alt'"
                Start-Sleep -Seconds 5
                return $true
            }
        }
    }
    
    Write-Log "ERROR: Could not start project. Showing available targets:"
    Show-MakefileTargets
    return $false
}

function Get-ContainerCount {
    return (docker ps --format '{{.Names}}').Count
}

# Main
Write-Log "=== Docker Monitor Started at $(Get-Date) ==="
Write-Log "Project: $ProjectName"
Write-Log "Makefile: $Makefile"
Write-Log "Target: $Target"

Write-Host ""
Write-Host "Project: $ProjectName" -ForegroundColor Green
Write-Host "Makefile: $Makefile" -ForegroundColor Green
Write-Host ""

# Check initial state
$runningCount = Get-ContainerCount
Write-Host "Running containers: $runningCount" -ForegroundColor Cyan

if ($runningCount -eq 0) {
    Write-Host "No containers running. Starting project..." -ForegroundColor Yellow
    $started = Start-Project
    if (-not $started) {
        Write-Host "Failed to start. Showing available Makefile targets:" -ForegroundColor Red
        Show-MakefileTargets
        Write-Host ""
        Write-Host "Usage: .\monitor.ps1 -Makefile '.\path\to\Makefile' -Target <target>" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "Containers already running. Starting monitor..." -ForegroundColor Green
}

$seenErrors = @{}

Write-Host "Monitoring started. Press Ctrl+C to stop." -ForegroundColor Green
Write-Host ""

try {
    while ($true) {
        # Check if containers stopped
        $runningCount = Get-ContainerCount
        
        if ($runningCount -eq 0) {
            Write-Log "All containers stopped. Restarting..."
            Write-Host "Containers stopped. Restarting..." -ForegroundColor Yellow
            Start-Project
        }
        
        # Get container names
        $containers = @()
        
        # Check docker-compose first
        if ((Test-Path "docker-compose.yml") -or (Test-Path "docker-compose.yaml")) {
            $containers = docker compose ps --format '{{.Names}}' 2>$null
        } else {
            $containers = docker ps --format '{{.Names}}'
        }
        
        foreach ($c in $containers) {
            # Filter to project containers
            if ($c -match $ProjectName -or $ProjectName -eq "") {
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
        }
        
        # Check for stopped containers
        $stopped = docker ps -a --filter "status=exited" --filter "status=restarting" --format '{{.Names}}'
        if ($stopped) {
            $stopped | ForEach-Object {
                if ($_ -match $ProjectName) {
                    Write-Log "ALERT: $_ has stopped or is restarting"
                }
            }
        }
        
        Start-Sleep -Seconds $IntervalSeconds
    }
} finally {
    Set-Location $OriginalDir
}