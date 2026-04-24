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

declare -A SEEN_ERRORS

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

while true; do
    containers=$(docker ps --format '{{.Names}}' 2>/dev/null)
    
    for container in $containers; do
        if [[ $container =~ $CONTAINER_PATTERN ]]; then
            monitor_container "$container"
        fi
    done
    
    docker ps -a --filter "status=exited" --filter "status=restarting" --format '{{.Names}}' | while read -r container; do
        if [[ $container =~ $CONTAINER_PATTERN ]]; then
            echo "[$(date '+%H:%M:%S')] ALERT: $container has stopped or is restarting" | tee -a "$LOG_FILE"
        fi
    done
    
    sleep 10
done