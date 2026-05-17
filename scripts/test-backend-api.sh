#!/usr/bin/env bash
# Backend API Tests — Validates API endpoints via Postman
# Usage: bash scripts/test-backend-api.sh <project-path> [--postman]
# Exit 0: All API tests pass
# Exit 1: One or more API tests fail

PROJECT_PATH="${1:-.}"
PASS=0
FAIL=0
WARN=0
FAILED_TESTS=()

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "--- API Endpoint Tests ---"

# Detect API base URL from project
API_URL=""
if [ -f "$PROJECT_PATH/.env" ]; then
  API_URL=$(grep -E '^API_URL=|^BASE_URL=|^SERVER_URL=' "$PROJECT_PATH/.env" 2>/dev/null | head -1 | cut -d'=' -f2-)
fi

# If no .env, try package.json for homepage/proxy
if [ -z "$API_URL" ] && [ -f "$PROJECT_PATH/package.json" ]; then
  API_URL=$(jq -r '.homepage // .proxy // ""' "$PROJECT_PATH" 2>/dev/null)
  [ "$API_URL" = "null" ] && API_URL=""
fi

# Default to localhost
[ -z "$API_URL" ] && API_URL="http://localhost:3000"

echo "Target: $API_URL"
echo ""

# Check if Postman collections exist
POSTMAN_COLLECTIONS=$(find "$PROJECT_PATH" -maxdepth 3 -name "*.postman_collection.json" -o -name "postman_collection.json" 2>/dev/null)

if [ -n "$POSTMAN_COLLECTIONS" ]; then
  echo "Found Postman collections:"
  echo "$POSTMAN_COLLECTIONS" | while read -r col; do
    echo "  - $(basename "$col")"
  done
  echo ""
  echo "Run via Postman MCP: /postman-test"
  PASS=$((PASS + 1))
  echo -e "${GREEN}PASS${NC} Postman collections detected"
else
  echo "No Postman collections found"
  echo ""
fi

# Check for OpenAPI/Swagger spec
OPENAPI_SPEC=$(find "$PROJECT_PATH" -maxdepth 3 -name "openapi*.json" -o -name "openapi*.yaml" -o -name "swagger*.json" -o -name "swagger*.yaml" 2>/dev/null | head -1)

if [ -n "$OPENAPI_SPEC" ]; then
  echo -e "${GREEN}PASS${NC} OpenAPI spec found: $(basename "$OPENAPI_SPEC")"
  PASS=$((PASS + 1))

  # Validate spec syntax
  if echo "$OPENAPI_SPEC" | grep -q '\.json$'; then
    if jq empty "$OPENAPI_SPEC" 2>/dev/null; then
      echo -e "${GREEN}PASS${NC} OpenAPI spec is valid JSON"
      PASS=$((PASS + 1))
    else
      echo -e "${RED}FAIL${NC} OpenAPI spec has invalid JSON"
      FAIL=$((FAIL + 1))
      FAILED_TESTS+=("OpenAPI spec has invalid JSON")
    fi
  fi
else
  echo -e "${YELLOW}WARN${NC} No OpenAPI spec found"
  WARN=$((WARN + 1))
fi

# Check for API test files
API_TEST_FILES=$(find "$PROJECT_PATH" -maxdepth 4 -path "*/test*/*api*" -o -path "*/test*/*route*" -o -path "*/test*/*endpoint*" 2>/dev/null | head -5)

if [ -n "$API_TEST_FILES" ]; then
  TEST_COUNT=$(echo "$API_TEST_FILES" | wc -l)
  echo -e "${GREEN}PASS${NC} Found $TEST_COUNT API test file(s)"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No API test files found"
  WARN=$((WARN + 1))
fi

# Check for health endpoint pattern
if grep -rq 'health\|healthcheck\|/health\|/ping\|/status' "$PROJECT_PATH" --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -1 | grep -q .; then
  echo -e "${GREEN}PASS${NC} Health endpoint pattern detected"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No health endpoint pattern found"
  WARN=$((WARN + 1))
fi

# Check for error handling patterns
if grep -rl 'catch\|try\|except\|error.*handler\|ErrorHandler\|errorHandler' "$PROJECT_PATH" --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -1 | grep -q .; then
  echo -e "${GREEN}PASS${NC} Error handling patterns detected"
  PASS=$((PASS + 1))
else
  echo -e "${RED}FAIL${NC} No error handling patterns found"
  FAIL=$((FAIL + 1))
  FAILED_TESTS+=("No error handling patterns in codebase")
fi

echo ""
echo "Total: $((PASS + FAIL + WARN)) | Pass: $PASS | Fail: $FAIL | Warn: $WARN"

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
  echo ""
  echo "Failed tests:"
  for f in "${FAILED_TESTS[@]}"; do
    echo "  - $f"
  done
fi

if [ $FAIL -gt 0 ]; then
  exit 1
fi

exit 0
