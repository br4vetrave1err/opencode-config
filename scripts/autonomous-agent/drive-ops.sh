#!/bin/bash

# Autonomous Agent - Drive Operations Helper
# Manages Drive file operations for the autonomous agent

set -e

CREDENTIALS_FILE="$HOME/.autonomous-agent/credentials.json"
WORK_DIR="$HOME/autonomous-work"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Ensure directories exist
ensure_dirs() {
    mkdir -p "$WORK_DIR"
    mkdir -p "$(dirname "$CREDENTIALS_FILE")"
}

# Extract folder ID from various Drive URL formats
extract_folder_id() {
    local input="$1"
    
    # Handle various URL formats
    # https://drive.google.com/drive/folders/ABC123...
    # https://drive.google.com/open?id=ABC123...
    # ABC123... (direct ID)
    
    echo "$input" | grep -oE '[a-zA-Z0-9_-]{20,}' | head -1
}

# List files in Drive folder
list_files() {
    local folder_id="$1"
    
    log_info "Listing files in folder: $folder_id"
    
    # Use Drive MCP if available
    # This is a placeholder - the actual implementation uses the MCP server
    echo "Files listing requires Drive MCP to be enabled"
}

# Download file from Drive
download_file() {
    local file_id="$1"
    local output_path="$2"
    
    log_info "Downloading file $file_id to $output_path"
    
    # Placeholder - Drive MCP handles this
    echo "Download requires Drive MCP"
}

# Upload file to Drive
upload_file() {
    local file_path="$1"
    local folder_id="$2"
    local filename="$3"
    
    log_info "Uploading $file_path to folder $folder_id as $filename"
    
    # Placeholder - Drive MCP handles this
    echo "Upload requires Drive MCP"
}

# Check if credentials exist
check_credentials() {
    if [ -f "$CREDENTIALS_FILE" ]; then
        log_info "Credentials found at $CREDENTIALS_FILE"
        return 0
    else
        log_warn "No credentials found. Run oauth setup first."
        return 1
    fi
}

# OAuth setup instructions
oauth_setup() {
    log_info "Google Drive OAuth Setup Instructions:"
    echo ""
    echo "1. Go to Google Cloud Console: https://console.cloud.google.com/"
    echo "2. Create a new project or select existing"
    echo "3. Enable Google Drive API"
    echo "4. Go to Credentials > OAuth consent screen"
    echo "5. Configure consent screen (External user type)"
    echo "6. Create OAuth client ID credentials"
    echo "7. Download client configuration (JSON)"
    echo "8. Save as $CREDENTIALS_FILE"
    echo ""
    echo "Required scopes:"
    echo "  - https://www.googleapis.com/auth/drive.file"
    echo "  - https://www.googleapis.com/auth/drive.metadata.readonly"
}

# Main command handler
case "${1:-}" in
    list)
        list_files "$2"
        ;;
    download)
        download_file "$2" "$3"
        ;;
    upload)
        upload_file "$2" "$3" "$4"
        ;;
    check-creds)
        check_credentials
        ;;
    oauth-setup)
        oauth_setup
        ;;
    *)
        echo "Usage: $0 {list|download|upload|check-creds|oauth-setup} <args...>"
        echo ""
        echo "Commands:"
        echo "  list <folder_id>              - List files in Drive folder"
        echo "  download <file_id> <path>     - Download file from Drive"
        echo "  upload <path> <folder_id> <name> - Upload file to Drive"
        echo "  check-creds                - Check if OAuth credentials exist"
        echo "  oauth-setup                - Show OAuth setup instructions"
        exit 1
        ;;
esac