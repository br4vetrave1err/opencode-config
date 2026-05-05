#!/bin/bash

# Autonomous Agent - Docker Sandbox Manager
# Creates, manages, and destroys sandboxed Docker environments for code execution

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXECUTION_DIR="$HOME/.autonomous-agent/executions"
WORK_DIR="$HOME/autonomous-work"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Create execution directory
ensure_dirs() {
    mkdir -p "$EXECUTION_DIR"
    mkdir -p "$WORK_DIR"
}

# Generate unique container name
generate_name() {
    local run_id="$1"
    echo "autonomous-sandbox-$run_id"
}

# Create docker-compose configuration
create_compose() {
    local run_id="$1"
    local language="$2"  # python, node, go, etc.
    local output_dir="$EXECUTION_DIR/$run_id"
    
    mkdir -p "$output_dir"
    
    case "$language" in
        python)
            cat > "$output_dir/docker-compose.yaml" << EOF
version: '3.8'
services:
  sandbox:
    image: python:3.11-slim
    working_dir: /app
    volumes:
      - ${WORK_DIR}/${run_id}:/app
    command: ["sleep", "infinity"]
    stdin_open: true
    tty: true
EOF
            ;;
        node)
            cat > "$output_dir/docker-compose.yaml" << EOF
version: '3.8'
services:
  sandbox:
    image: node:20-slim
    working_dir: /app
    volumes:
      - ${WORK_DIR}/${run_id}:/app
    command: ["sleep", "infinity"]
    stdin_open: true
    tty: true
EOF
            ;;
        go)
            cat > "$output_dir/docker-compose.yaml" << EOF
version: '3.8'
services:
  sandbox:
    image: golang:1.21-alpine
    working_dir: /app
    volumes:
      - ${WORK_DIR}/${run_id}:/app
    command: ["sleep", "infinity"]
    stdin_open: true
    tty: true
EOF
            ;;
        rust)
            cat > "$output_dir/docker-compose.yaml" << EOF
version: '3.8'
services:
  sandbox:
    image: rust:1.75-alpine
    working_dir: /app
    volumes:
      - ${WORK_DIR}/${run_id}:/app
    command: ["sleep", "infinity"]
    stdin_open: true
    tty: true
EOF
            ;;
        *)
            log_warn "Unknown language: $language, using python as default"
            cat > "$output_dir/docker-compose.yaml" << EOF
version: '3.8'
services:
  sandbox:
    image: python:3.11-slim
    working_dir: /app
    volumes:
      - ${WORK_DIR}/${run_id}:/app
    command: ["sleep", "infinity"]
    stdin_open: true
    tty: true
EOF
            ;;
    esac
    
    log_info "Created docker-compose in $output_dir"
    echo "$output_dir/docker-compose.yaml"
}

# Start sandbox container
start_sandbox() {
    local run_id="$1"
    local language="$2"
    local container_name=$(generate_name "$run_id")
    local compose_file=$(create_compose "$run_id" "$language")
    local compose_dir=$(dirname "$compose_file")
    
    log_info "Starting sandbox for run $run_id..."
    
    cd "$compose_dir"
    docker-compose up -d
    
    log_info "Sandbox started: $container_name"
    echo "$container_name"
}

# Execute command in sandbox
exec_in_sandbox() {
    local run_id="$1"
    local command="$2"
    local container_name=$(generate_name "$run_id")
    local output_file="$EXECUTION_DIR/${run_id}/output.log"
    local error_file="$EXECUTION_DIR/${run_id}/error.log"
    
    log_info "Executing in sandbox: $command"
    
    # Run command and capture output
    local stdout stderr exit_code
    stdout=$(docker exec "$container_name" bash -c "$command" 2>&1) || true
    exit_code=$?
    
    # Save outputs
    echo "$stdout" > "$output_file"
    echo "$stderr" > "$error_file"
    
    # Also echo to stdout
    echo "$stdout"
    
    if [ $exit_code -ne 0 ]; then
        log_error "Command failed with exit code $exit_code"
        echo "$stderr" >&2
    else
        log_info "Command completed successfully"
    fi
    
    echo "$exit_code"
}

# Stop and remove sandbox
destroy_sandbox() {
    local run_id="$1"
    local container_name=$(generate_name "$run_id")
    local output_dir="$EXECUTION_DIR/$run_id"
    
    log_info "Destroying sandbox for run $run_id..."
    
    # Stop container
    docker stop "$container_name" 2>/dev/null || true
    docker rm "$container_name" 2>/dev/null || true
    
    # Save docker-compose reference (already saved)
    log_info "Sandbox destroyed, artifacts preserved in $output_dir"
}

# Get sandbox status
sandbox_status() {
    local run_id="$1"
    local container_name=$(generate_name "$run_id")
    
    docker ps -a --filter "name=$container_name" --format "{{.Status}}"
}

# Main command handler
case "${1:-}" in
    start)
        ensure_dirs
        start_sandbox "$2" "$3"
        ;;
    exec)
        exec_in_sandbox "$2" "$3"
        ;;
    destroy)
        destroy_sandbox "$2"
        ;;
    status)
        sandbox_status "$2"
        ;;
    *)
        echo "Usage: $0 {start|exec|destroy|status} <run_id> [language]"
        echo ""
        echo "Commands:"
        echo "  start <run_id> <language>  - Create and start sandbox"
        echo "  exec  <run_id> <command>   - Execute command in sandbox"
        echo "  destroy <run_id>        - Destroy sandbox"
        echo "  status <run_id>         - Check sandbox status"
        exit 1
        ;;
esac