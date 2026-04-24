---
name: continuous-monitor
description: Continuously monitor Docker containers and project logs for errors during development. Use when user wants to run a persistent monitor that watches for issues while they work with the agent.
---

# Continuous Monitor

Run a persistent background monitor that watches Docker containers and logs for errors during development.

## Setup

### 1. Create monitor script

Save as `scripts/monitor.sh`:

```bash
#!/bin/bash
# Continuous Docker log monitor
# Usage: ./monitor.sh [container_name]

CONTAINER=${1:-""}
LOG_FILE="$HOME/.docker-monitor.log"
ERROR_FILE="$HOME/.docker-monitor-errors.log"

echo "=== Docker Monitor Started at $(date) ===" | tee -a "$LOG_FILE"

if [ -z "$CONTAINER" ]; then
    echo "Monitoring ALL containers..."
    CONTAINER_PATTERN=".*"
else
    echo "Monitoring container: $CONTAINER"
    CONTAINER_PATTERN="$CONTAINER"
fi

# Track seen errors to avoid spam
declare -A SEEN_ERRORS

monitor_container() {
    local container=$1
    
    # Get container status
    local status=$(docker inspect "$container" --format='{{.State.Status}}' 2>/dev/null)
    
    if [ "$status" != "running" ]; then
        echo "[$(date '+%H:%M:%S')] WARNING: $container is not running (status: $status)" | tee -a "$LOG_FILE"
        return
    fi
    
    # Stream new logs and grep for errors
    docker logs -t "$container" 2>&1 | \
        grep -iE "(error|exception|fatal|failed|panic|warning)" | \
        tail -20 | \
        while read -r line; do
            # Create error fingerprint (first 50 chars)
            fingerprint=$(echo "$line" | cut -c1-50)
            
            if [ -z "${SEEN_ERRORS[$fingerprint]}" ]; then
                SEEN_ERRORS[$fingerprint]=1
                timestamp=$(echo "$line" | awk '{print $1}')
                echo "[$timestamp] $container: $line" | tee -a "$ERROR_FILE"
                echo "[$timestamp] $container: $line" | tee -a "$LOG_FILE"
            fi
        done
}

# Check containers every 10 seconds
while true; do
    containers=$(docker ps --format '{{.Names}}' 2>/dev/null)
    
    for container in $containers; do
        if [[ $container =~ $CONTAINER_PATTERN ]]; then
            monitor_container "$container"
        fi
    done
    
    # Also check for crashed/restarting containers
    docker ps -a --filter "status=exited" --filter "status=restarting" --format '{{.Names}}' | while read -r container; do
        if [[ $container =~ $CONTAINER_PATTERN ]]; then
            echo "[$(date '+%H:%M:%S')] ALERT: $container has stopped or is restarting" | tee -a "$LOG_FILE"
        fi
    done
    
    sleep 10
done
```

### 2. Make executable

```bash
chmod +x scripts/monitor.sh
```

### 3. Start monitoring

```bash
# Monitor all containers
./scripts/monitor.sh &

# Monitor specific container
./scripts/monitor.sh my-app &

# Monitor multiple (comma-separated patterns)
./scripts/monitor.sh "my-app|api|worker" &
```

## View Logs

```bash
# All logs
tail -f ~/.docker-monitor.log

# Errors only
cat ~/.docker-monitor-errors.log

# Recent errors
tail -20 ~/.docker-monitor-errors.log
```

## Stop Monitor

```bash
pkill -f "monitor.sh"
# or
ps aux | grep monitor.sh
kill <PID>
```

## Windows Alternative (PowerShell)

Save as `scripts/monitor.ps1`:

```powershell
param(
    [string]$Container = "",
    [string]$LogFile = "$env:USERPROFILE\.docker-monitor.log",
    [string]$ErrorFile = "$env:USERPROFILE\.docker-monitor-errors.log"
)

$ErrorActionPreference = "SilentlyContinue"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    "$timestamp $Message" | Tee-Object -FilePath $LogFile
}

Write-Log "=== Docker Monitor Started at $(Get-Date) ==="

$seenErrors = @{}

while ($true) {
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
                    "$c: $_" | Tee-Object -FilePath $ErrorFile
                    Write-Log "$c: $_"
                }
            }
        }
    }
    
    # Check for stopped containers
    $stopped = docker ps -a --filter "status=exited" --filter "status=restarting" --format '{{.Names}}'
    if ($stopped) {
        Write-Log "ALERT: Stopped containers: $stopped"
    }
    
    Start-Sleep -Seconds 10
}
```

Run with: `powershell -ExecutionPolicy Bypass -File .\scripts\monitor.ps1`

## Integration with Opencode Agent

When the monitor detects errors, the agent can:

1. **Read the error log**: Check `~/.docker-monitor-errors.log`
2. **Analyze the error**: Use docker-monitor skill to inspect
3. **Explain the issue**: Break down what the error means
4. **Suggest fixes**: Provide actionable solutions
5. **Help implement**: Assist with code changes

## Usage with Opencode

When you encounter an error in your development:

1. Tell the agent: "Check the Docker monitor logs"
2. Agent runs: `tail -50 ~/.docker-monitor-errors.log`
3. Agent analyzes the error using docker-monitor skill
4. Agent explains and helps debug

## Auto-start with Project

Add to your project's development workflow:

```bash
# In project Makefile
dev: 
    @echo "Starting Docker monitor in background..."
    @(cd ~/opencode-config && ./scripts/monitor.sh my-project &)
    docker compose up --build
```

## Notes

- Monitor runs in background with `&` (Linux) or as separate process (Windows)
- Logs stored in `~/.docker-monitor.log` and `~/.docker-monitor-errors.log`
- Deduplicates errors to avoid spam
- Checks every 10 seconds
- Also alerts on container crashes/restarts