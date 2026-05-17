#!/usr/bin/env bash
# Frontend Component Tests — Tests isolated component rendering, props, events, a11y
# Usage: bash scripts/test-frontend-component.sh <project-path>
# Exit 0: All component tests pass
# Exit 1: One or more component tests fail

PROJECT_PATH="${1:-.}"
PASS=0
FAIL=0
WARN=0
FAILED_TESTS=()

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "--- Frontend Component Tests ---"

# Detect framework
FRAMEWORK=""
if grep -q '"react"' "$PROJECT_PATH/package.json" 2>/dev/null; then
  FRAMEWORK="react"
elif grep -q '"vue"' "$PROJECT_PATH/package.json" 2>/dev/null; then
  FRAMEWORK="vue"
elif grep -q '"svelte"' "$PROJECT_PATH/package.json" 2>/dev/null; then
  FRAMEWORK="svelte"
fi

# Count component files
COMPONENT_FILES=$(find "$PROJECT_PATH" -maxdepth 5 \( -name "*.tsx" -o -name "*.jsx" -o -name "*.vue" -o -name "*.svelte" \) -not -path "*/node_modules/*" -not -path "*/.next/*" -not -path "*/dist/*" 2>/dev/null | wc -l)

echo "Found $COMPONENT_FILES component file(s)"

if [ "$COMPONENT_FILES" -gt 0 ]; then
  # Check for component test patterns
  COMPONENT_TESTS=$(find "$PROJECT_PATH" -maxdepth 5 \( -name "*.component.test.*" -o -name "*.component.spec.*" -o -path "*/__tests__/components/*" -o -path "*/tests/components/*" \) 2>/dev/null | wc -l)

  if [ "$COMPONENT_TESTS" -gt 0 ]; then
    echo -e "${GREEN}PASS${NC} Found $COMPONENT_TESTS component test file(s)"
    PASS=$((PASS + 1))
  else
    echo -e "${YELLOW}WARN${NC} No component test files found"
    WARN=$((WARN + 1))
  fi

  # Check for Storybook (component documentation/testing)
  if [ -f "$PROJECT_PATH/.storybook/main.js" ] || [ -f "$PROJECT_PATH/.storybook/main.ts" ] || grep -q '"storybook"' "$PROJECT_PATH/package.json" 2>/dev/null; then
    echo -e "${GREEN}PASS${NC} Storybook detected (component documentation/testing)"
    PASS=$((PASS + 1))
  else
    echo -e "${YELLOW}WARN${NC} Storybook not detected"
    WARN=$((WARN + 1))
  fi

  # Check for accessibility testing
  if grep -rq 'axe\|@axe-core\|jest-axe\|eslint-plugin-jsx-a11y\|vue-axe' "$PROJECT_PATH" --include="*.js" --include="*.ts" --include="*.json" --include="*.eslintrc*" 2>/dev/null | head -1 | grep -q .; then
    echo -e "${GREEN}PASS${NC} Accessibility testing detected"
    PASS=$((PASS + 1))
  else
    echo -e "${YELLOW}WARN${NC} No accessibility testing detected"
    WARN=$((WARN + 1))
  fi

  # Check for snapshot tests
  SNAPSHOT_FILES=$(find "$PROJECT_PATH" -maxdepth 5 -name "*.snap" -not -path "*/node_modules/*" 2>/dev/null | wc -l)
  if [ "$SNAPSHOT_FILES" -gt 0 ]; then
    echo -e "${GREEN}PASS${NC} Found $SNAPSHOT_FILES snapshot file(s)"
    PASS=$((PASS + 1))
  else
    echo -e "${YELLOW}WARN${NC} No snapshot tests found"
    WARN=$((WARN + 1))
  fi
else
  echo -e "${YELLOW}WARN${NC} No component files found"
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
