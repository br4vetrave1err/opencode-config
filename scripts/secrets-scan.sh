#!/usr/bin/env bash
# Secrets Scanner — Detects leaked secrets in tracked files
# Usage: bash scripts/secrets-scan.sh [directory]
# Exit 0: No secrets found
# Exit 1: Secrets detected

set -e

SCAN_DIR="${1:-.}"
FOUND=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Patterns: name, regex, description
declare -a PATTERNS=(
  "GitHub:ghp_[a-zA-Z0-9]{36}:GitHub Personal Access Token"
  "Atlassian:ATATT[A-Za-z0-9_-]{50,}:Atlassian API Token"
  "OpenAI:sk-[a-zA-Z0-9_-]{20,}:OpenAI API Key"
  "Google:AIza[A-Za-z0-9_-]{35}:Google API Key"
  "AWS:AKIA[0-9A-Z]{16}:AWS Access Key"
  "JWT:eyJ[A-Za-z0-9_-]+\.eyJ:JWT Token"
)

# Directories and files to skip are handled in find command below

echo "=== Secrets Scan ==="
echo "Scanning: $SCAN_DIR"
echo ""

# Find all files, excluding skipped dirs and files
while IFS= read -r -d '' file; do
  # Get relative path for display
  rel_path="${file#$SCAN_DIR/}"

  for pattern_entry in "${PATTERNS[@]}"; do
    IFS=':' read -r name regex description <<< "$pattern_entry"

    if grep -qP "$regex" "$file" 2>/dev/null; then
      echo -e "${RED}FOUND${NC} $description"
      echo "  File: $rel_path"
      echo "  Pattern: $name"
      FOUND=1
    fi
  done
done < <(find "$SCAN_DIR" -type f \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/.obsidian/*" \
  -not -path "*/__pycache__/*" \
  -not -path "*/.venv/*" \
  -not -path "*/venv/*" \
  -not -path "*/tests/config-validation/test-secrets-scan.sh" \
  -not -name "*.lock" \
  -not -name "*.log" \
  -not -name ".env.example" \
  -not -name ".gitkeep" \
  -not -name "package-lock.json" \
  -not -name "yarn.lock" \
  -print0 2>/dev/null)

echo ""
if [ $FOUND -eq 1 ]; then
  echo -e "${RED}SECRETS DETECTED${NC}"
  echo "Remove secrets before committing. Use environment variables instead."
  exit 1
else
  echo -e "${GREEN}No secrets found${NC}"
  exit 0
fi
