#!/bin/bash

# Autonomous Agent - Observability Logger
# Logs structured events to trace files for full observability

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACE_DIR="$HOME/.autonomous-agent/traces"

# Ensure trace directory exists
ensure_dirs() {
    mkdir -p "$TRACE_DIR"
}

# Generate timestamp in ISO8601 format
timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Generate run_id if not provided
generate_run_id() {
    if [ -z "$1" ]; then
        date -u +"autonomous_%Y%m%d_%H%M%S"
    else
        echo "$1"
    fi
}

# Log event to trace file
log_event() {
    local run_id="$1"
    local event_type="$2"
    local phase="$3"
    local status="$4"
    local metadata="$5"
    
    local trace_file="$TRACE_DIR/${run_id}.jsonl"
    local timestamp_value=$(timestamp)
    
    # Build JSON object
    local json="{\"timestamp\":\"$timestamp_value\",\"run_id\":\"$run_id\",\"event\":\"$event_type\",\"phase\":\"$phase\",\"status\":\"$status\""
    
    # Add metadata if provided
    if [ -n "$metadata" ]; then
        json="$json,$metadata"
    fi
    
    json="$json}"
    
    # Write to trace file
    echo "$json" >> "$trace_file"
    
    # Also output to stdout for real-time monitoring
    echo "$json"
}

# Convenience functions for common events
log_phase_start() {
    log_event "$1" "phase_started" "$2" "running" "$3"
}

log_phase_complete() {
    log_event "$1" "phase_completed" "$2" "success" "$3"
}

log_phase_failed() {
    log_event "$1" "phase_failed" "$2" "failed" "$3"
}

log_tool_call() {
    local run_id="$1"
    local step="$2"
    local tool="$3"
    local command="$4"
    local input_tokens="$5"
    local duration="$6"
    
    local metadata="\"step\":$step,\"tool\":\"$tool\",\"command\":\"$command\",\"input_tokens\":$input_tokens,\"duration_ms\":$duration"
    
    log_event "$run_id" "tool_call" "implement" "running" "$metadata"
}

log_tool_response() {
    local run_id="$1"
    local step="$2"
    local tool="$3"
    local status="$4"
    local output_tokens="$5"
    local duration="$6"
    
    local metadata="\"step\":$step,\"tool\":\"$tool\",\"status\":\"$status\",\"output_tokens\":$output_tokens,\"duration_ms\":$duration"
    
    log_event "$run_id" "tool_response" "implement" "$status" "$metadata"
}

log_approval() {
    local run_id="$1"
    local phase="$2"
    local response="$3"
    
    local metadata="\"phase\":\"$phase\",\"response\":\"$response\""
    
    log_event "$run_id" "user_approval" "$phase" "$response" "$metadata"
}

log_error() {
    local run_id="$1"
    local phase="$2"
    local error="$3"
    
    local metadata="\"error\":\"$error\""
    
    log_event "$run_id" "error" "$phase" "failed" "$metadata"
}

# Get trace file for run_id
get_trace_file() {
    local run_id="$1"
    echo "$TRACE_DIR/${run_id}.jsonl"
}

# Read trace file
read_trace() {
    local run_id="$1"
    local trace_file="$TRACE_DIR/${run_id}.jsonl"
    
    if [ -f "$trace_file" ]; then
        cat "$trace_file"
    else
        echo "No trace found for run_id: $run_id"
        return 1
    fi
}

# List all traces
list_traces() {
    ls -lt "$TRACE_DIR"/*.jsonl 2>/dev/null | head -20
}

# Main command handler
case "${1:-}" in
    log)
        ensure_dirs
        log_event "$2" "$3" "$4" "$5" "$6"
        ;;
    phase-start)
        ensure_dirs
        log_phase_start "$2" "$3" "$4"
        ;;
    phase-complete)
        ensure_dirs
        log_phase_complete "$2" "$3" "$4"
        ;;
    phase-failed)
        ensure_dirs
        log_phase_failed "$2" "$3" "$4"
        ;;
    tool-call)
        ensure_dirs
        log_tool_call "$2" "$3" "$4" "$5" "$6" "$7"
        ;;
    tool-response)
        ensure_dirs
        log_tool_response "$2" "$3" "$4" "$5" "$6" "$7"
        ;;
    approval)
        ensure_dirs
        log_approval "$2" "$3" "$4"
        ;;
    error)
        ensure_dirs
        log_error "$2" "$3" "$4"
        ;;
    read)
        read_trace "$2"
        ;;
    list)
        list_traces
        ;;
    *)
        echo "Usage: $0 {log|phase-start|phase-complete|phase-failed|tool-call|tool-response|approval|error|read|list} <args...>"
        echo ""
        echo "Commands:"
        echo "  log <run_id> <event_type> <phase> <status> [metadata]"
        echo "  phase-start <run_id> <phase> [metadata]"
        echo "  phase-complete <run_id> <phase> [metadata]"
        echo "  phase-failed <run_id> <phase> [metadata]"
        echo "  tool-call <run_id> <step> <tool> <command> <input_tokens> <duration_ms>"
        echo "  tool-response <run_id> <step> <tool> <status> <output_tokens> <duration_ms>"
        echo "  approval <run_id> <phase> <response>"
        echo "  error <run_id> <phase> <error_message>"
        echo "  read <run_id>           - Read trace file"
        echo "  list                  - List recent traces"
        exit 1
        ;;
esac