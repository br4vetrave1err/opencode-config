#!/bin/bash
# Continuous Docker log monitor with Makefile control
# Usage: ./monitor.sh <path-to-makefile> [target]

MAKEFILE=${1:-"Makefile"}
TARGET=${2:-"up"}
PROJECT_NAME=$(basename $(dirname "$MAKEFILE"))

LOG_FILE="$HOME/.docker-monitor.log"
ERROR_FILE="$HOME/.docker-monitor-errors.log"

# Check if Makefile exists
if [ ! -f "$MAKEFILE" ]; then
    echo "ERROR: Makefile not found at $MAKEFILE"
    exit 1
fi

PROJECT_DIR=$(dirname "$MAKEFILE")
cd "$PROJECT_DIR"

echo "=== Docker Monitor Started at $(date) ==="
echo "Project: $PROJECT_NAME"
echo "Makefile: $MAKEFILE"
echo "Target: $TARGET" | tee -a "$LOG_FILE"

declare -A SEEN_ERRORS

# Function to check if containers are running
check_containers_running() {
    local count=$(docker ps --format '{{.Names}}' | grep -v "^$" | wc -l)
    echo $count
}

# Function to start project
start_project() {
    echo "[$(date '+%H:%M:%S')] Starting project with: make $TARGET" | tee -a "$LOG_FILE"
    
    # Try common make targets
    if make $TARGET 2>/dev/null; then
        echo "[$(date '+%H:%M:%S')] Started successfully" | tee -a "$LOG_FILE"
        sleep 5
    elif make dev 2>/dev/null; then
        echo "[$(date '+%H:%M:%S')] Started with 'make dev'" | tee -a "$LOG_FILE"
        sleep 5
    elif make start 2>/dev/null; then
        echo "[$(date '+%H:%M:%S')] Started with 'make start'" | tee -a "$LOG_FILE"
        sleep 5
    elif make run 2>/dev/null; then
        echo "[$(date '+%H:%M:%S')] Started with 'make run'" | tee -a "$LOG_FILE"
        sleep 5
    else
        echo "[$(date '+%H:%M:%S')] ERROR: Could not start project. Try 'make $TARGET' manually" | tee -a "$LOG_FILE"
        return 1
    fi
}

# Function to check available make targets
show_makefile_targets() {
    echo "Available targets in Makefile:"
    grep -E "^[a-zA-Z0-9_-]+:" "$MAKEFILE" | sed 's/:.*//' | head -20
}

# Function to monitor a container
monitor_container() {
    local container=$1
    
    local status=$(docker inspect "$container" --format='{{.State.Status}}' 2>/dev/null)
    
    if [ "$status" != "running" ]; then
        echo "[$(date '+%H:%M:%S')] WARNING: $container is not running (status: $status)" | tee -a "$LOG_FILE"
        return
    fi
    
    docker logs -t "$container" 2>&1 | \
        grep -iE "(error|exception|fatal|failed|panic|warning)" | \
        tail -20 | \
        while read -r line; do
            fingerprint=$(echo "$line" | cut -c1-50)
            
            if [ -z "${SEEN_ERRORS[$fingerprint]}" ]; then
                SEEN_ERRORS[$fingerprint]=1
                timestamp=$(echo "$line" | awk '{print $1}')
                echo "[$timestamp] $container: $line" | tee -a "$ERROR_FILE"
                echo "[$timestamp] $container: $line" | tee -a "$LOG_FILE"
            fi
        done
}

# Check initial state
echo ""
echo "Checking project state..."
RUNNING_COUNT=$(check_containers_running)
echo "Running containers: $RUNNING_COUNT"

if [ "$RUNNING_COUNT" -eq 0 ]; then
    echo "No containers running. Starting project..."
    start_project
else
    echo "Containers already running. Starting monitor..."
fi

# Main monitoring loop
while true; do
    # Check if we need to restart (containers stopped)
    RUNNING_COUNT=$(check_containers_running)
    
    if [ "$RUNNING_COUNT" -eq 0 ]; then
        echo "[$(date '+%H:%M:%S')] All containers stopped. Restarting..." | tee -a "$LOG_FILE"
        start_project
    fi
    
    # Get container names from docker compose if available
    if [ -f "$PROJECT_DIR/docker-compose.yml" ] || [ -f "$PROJECT_DIR/docker-compose.yaml" ]; then
        containers=$(docker compose ps --format '{{.Names}}' 2>/dev/null)
    else
        containers=$(docker ps --format '{{.Names}}' 2>/dev/null)
    fi
    
    for container in $containers; do
        # Filter to project containers
        if [[ "$container" == *"$PROJECT_NAME"* ]] || [ -z "$PROJECT_NAME" ]; then
            monitor_container "$container"
        fi
    done
    
    # Check for stopped containers
    docker ps -a --filter "status=exited" --filter "status=restarting" --format '{{.Names}}' | while read -r container; do
        if [[ "$container" == *"$PROJECT_NAME"* ]] || [ -z "$PROJECT_NAME" ]; then
            echo "[$(date '+%H:%M:%S')] ALERT: $container has stopped or is restarting" | tee -a "$LOG_FILE"
        fi
    done
    
    sleep 10
done