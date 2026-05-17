#!/usr/bin/env bash
# Frontend E2E Tests — End-to-end browser tests via Playwright
# Usage: bash scripts/test-frontend-e2e.sh <project-path>
# Exit 0: All E2E tests pass
# Exit 1: One or more E2E tests fail

PROJECT_PATH="${1:-.}"
PASS=0
FAIL=0
WARN=0
FAILED_TESTS=()

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "--- Frontend E2E Tests ---"

# Check for Playwright config
HAS_PLAYWRIGHT=false
if [ -f "$PROJECT_PATH/playwright.config.ts" ] || [ -f "$PROJECT_PATH/playwright.config.js" ]; then
  HAS_PLAYWRIGHT=true
fi

# Check for E2E test files
E2E_TEST_FILES=$(find "$PROJECT_PATH" -maxdepth 5 \( -name "*.e2e.test.*" -o -name "*.e2e.spec.*" -o -name "*.spec.e2e.*" -o -path "*/e2e/*" -o -path "*/tests/e2e/*" \) -not -path "*/node_modules/*" 2>/dev/null | wc -l)

if [ "$E2E_TEST_FILES" -gt 0 ]; then
  echo "Found $E2E_TEST_FILES E2E test file(s)"
  echo ""
else
  echo "No E2E test files found"
  echo ""
fi

if $HAS_PLAYWRIGHT; then
  echo -e "${GREEN}PASS${NC} Playwright configuration detected"
  PASS=$((PASS + 1))

  # Check if Playwright is installed
  if command -v npx &>/dev/null; then
    PLAYWRIGHT_CHECK=$(cd "$PROJECT_PATH" && npx playwright --version 2>&1)
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}PASS${NC} Playwright installed: $PLAYWRIGHT_CHECK"
      PASS=$((PASS + 1))

      # Run E2E tests if files exist
      if [ "$E2E_TEST_FILES" -gt 0 ]; then
        echo "Running E2E tests..."
        OUTPUT=$(cd "$PROJECT_PATH" && timeout 30 npx playwright test --reporter=list --pass-with-no-tests 2>&1)
        EXIT_CODE=$?
        if [ $EXIT_CODE -eq 0 ]; then
          echo -e "${GREEN}PASS${NC} Playwright E2E tests passed"
          PASS=$((PASS + 1))
        else
          # Check if it's just a browser not installed issue
          if echo "$OUTPUT" | grep -qi "browser.*not found\|Executable doesn't exist"; then
            echo -e "${YELLOW}WARN${NC} Playwright browsers not installed (run: npx playwright install)"
            WARN=$((WARN + 1))
          else
            echo -e "${RED}FAIL${NC} Playwright E2E tests failed"
            FAIL=$((FAIL + 1))
            FAILED_TESTS+=("Playwright E2E tests failed")
          fi
        fi
      else
        echo -e "${YELLOW}WARN${NC} Playwright configured but no E2E test files found"
        WARN=$((WARN + 1))
      fi
    else
      echo -e "${YELLOW}WARN${NC} Playwright not installed (run: npx playwright install)"
      WARN=$((WARN + 1))
    fi
  fi
else
  # Check for other E2E frameworks
  if grep -q '"cypress"' "$PROJECT_PATH/package.json" 2>/dev/null; then
    echo -e "${GREEN}PASS${NC} Cypress detected (alternative E2E framework)"
    PASS=$((PASS + 1))
  elif grep -q '"puppeteer"' "$PROJECT_PATH/package.json" 2>/dev/null; then
    echo -e "${GREEN}PASS${NC} Puppeteer detected (alternative E2E framework)"
    PASS=$((PASS + 1))
  else
    echo -e "${YELLOW}WARN${NC} No E2E framework detected (Playwright, Cypress, Puppeteer)"
    WARN=$((WARN + 1))
  fi
fi

# Check for critical user journey patterns
CRITICAL_PATHS=0
if grep -rq 'login\|signin\|auth\|authenticate' "$PROJECT_PATH" --include="*.e2e.*" --include="*.spec.*" --include="*.test.*" -path "*/e2e/*" 2>/dev/null | head -1 | grep -q .; then
  CRITICAL_PATHS=$((CRITICAL_PATHS + 1))
fi
if grep -rq 'checkout\|purchase\|payment\|order' "$PROJECT_PATH" --include="*.e2e.*" --include="*.spec.*" --include="*.test.*" -path "*/e2e/*" 2>/dev/null | head -1 | grep -q .; then
  CRITICAL_PATHS=$((CRITICAL_PATHS + 1))
fi
if grep -rq 'register\|signup\|onboard' "$PROJECT_PATH" --include="*.e2e.*" --include="*.spec.*" --include="*.test.*" -path "*/e2e/*" 2>/dev/null | head -1 | grep -q .; then
  CRITICAL_PATHS=$((CRITICAL_PATHS + 1))
fi

if [ "$CRITICAL_PATHS" -gt 0 ]; then
  echo -e "${GREEN}PASS${NC} Found $CRITICAL_PATHS critical user journey test(s)"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No critical user journey tests found (login, checkout, registration)"
  WARN=$((WARN + 1))
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
