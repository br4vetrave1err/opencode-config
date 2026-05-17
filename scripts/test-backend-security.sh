#!/usr/bin/env bash
# Backend Security Tests — OWASP API Top 10 + secret scanning + auth checks
# Usage: bash scripts/test-backend-security.sh <project-path>
# Exit 0: All security tests pass
# Exit 1: One or more security tests fail

PROJECT_PATH="${1:-.}"
PASS=0
FAIL=0
WARN=0
FAILED_TESTS=()

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "--- Security Tests ---"

# 1. Secret scanning (reuse secrets-scan.sh)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/secrets-scan.sh" ]; then
  SECRET_OUTPUT=$(bash "$SCRIPT_DIR/secrets-scan.sh" "$PROJECT_PATH" 2>&1)
  SECRET_EXIT=$?
  if [ $SECRET_EXIT -eq 0 ]; then
    echo -e "${GREEN}PASS${NC} No secrets detected in codebase"
    PASS=$((PASS + 1))
  else
    echo -e "${RED}FAIL${NC} Secrets detected in codebase"
    FAIL=$((FAIL + 1))
    FAILED_TESTS+=("Secrets found in codebase")
  fi
else
  echo -e "${YELLOW}WARN${NC} secrets-scan.sh not found, skipping"
  WARN=$((WARN + 1))
fi

# 2. Check for authentication middleware
if grep -rl 'auth\|Auth\|middleware\|Middleware\|guard\|Guard\|authenticate\|passport\|jwt\|JWT\|session' "$PROJECT_PATH" 2>/dev/null | grep -v 'node_modules\|.git\|test\|spec' | head -1 | grep -q .; then
  echo -e "${GREEN}PASS${NC} Authentication middleware detected"
  PASS=$((PASS + 1))
else
  echo -e "${RED}FAIL${NC} No authentication middleware found"
  FAIL=$((FAIL + 1))
  FAILED_TESTS+=("No authentication middleware in codebase")
fi

# 3. Check for input validation
if grep -rl 'validate\|Validate\|validation\|Validation\|zod\|z\.object\|joi\|yup\|validator\|pydantic\|class-validator\|schema\.' "$PROJECT_PATH" 2>/dev/null | grep -v 'node_modules\|.git\|test\|spec' | head -1 | grep -q .; then
  echo -e "${GREEN}PASS${NC} Input validation detected"
  PASS=$((PASS + 1))
else
  echo -e "${RED}FAIL${NC} No input validation found"
  FAIL=$((FAIL + 1))
  FAILED_TESTS+=("No input validation in codebase")
fi

# 4. Check for SQL injection prevention (parameterized queries)
if grep -rl '\?\|:name\|\$\d\|parameterized\|PreparedStatement\|sql\.Parameter' "$PROJECT_PATH" 2>/dev/null | grep -v 'node_modules\|.git' | head -1 | grep -q .; then
  echo -e "${GREEN}PASS${NC} Parameterized query patterns detected"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No parameterized query patterns found"
  WARN=$((WARN + 1))
fi

# 5. Check for CORS configuration
if grep -rl 'cors\|CORS\|Access-Control\|access-control' "$PROJECT_PATH" 2>/dev/null | grep -v 'node_modules\|.git' | head -1 | grep -q .; then
  echo -e "${GREEN}PASS${NC} CORS configuration detected"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No CORS configuration found"
  WARN=$((WARN + 1))
fi

# 6. Check for HTTPS/TLS enforcement
if grep -rl 'https\|tls\|TLS\|ssl\|SSL\|secure.*true\|forceSsl\|forceHttps' "$PROJECT_PATH" 2>/dev/null | grep -v 'node_modules\|.git' | head -1 | grep -q .; then
  echo -e "${GREEN}PASS${NC} HTTPS/TLS configuration detected"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No HTTPS/TLS configuration found"
  WARN=$((WARN + 1))
fi

# 7. Check for hardcoded credentials
HARDCODED_CREDS=$(grep -rn 'password.*=.*["\x27][^$].*["\x27]\|secret.*=.*["\x27][^$].*["\x27]\|api_key.*=.*["\x27][^$].*["\x27]\|token.*=.*["\x27][^$].*["\x27]' "$PROJECT_PATH" --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | grep -v 'node_modules\|.git\|test\|spec\|\.env\|example\|placeholder\|dummy\|TODO\|FIXME\|\*\*\*\|REDACTED\|process\.env' | head -5)

if [ -z "$HARDCODED_CREDS" ]; then
  echo -e "${GREEN}PASS${NC} No hardcoded credentials detected"
  PASS=$((PASS + 1))
else
  echo -e "${RED}FAIL${NC} Possible hardcoded credentials found"
  FAIL=$((FAIL + 1))
  FAILED_TESTS+=("Hardcoded credentials detected")
fi

# 8. Check for dependency vulnerability scanning
if [ -f "$PROJECT_PATH/package-lock.json" ] || [ -f "$PROJECT_PATH/yarn.lock" ]; then
  if command -v npm &>/dev/null; then
    VULN_OUTPUT=$(npm audit --production 2>/dev/null | grep -c "found 0 vulnerabilities" || true)
    if [ "$VULN_OUTPUT" -gt 0 ]; then
      echo -e "${GREEN}PASS${NC} No known npm vulnerabilities"
      PASS=$((PASS + 1))
    else
      VULN_COUNT=$(npm audit --production 2>/dev/null | grep -oP 'found \d+ vulnerabilities' | head -1)
      echo -e "${YELLOW}WARN${NC} npm audit: $VULN_COUNT"
      WARN=$((WARN + 1))
    fi
  fi
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
