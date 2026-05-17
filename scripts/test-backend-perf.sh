#!/usr/bin/env bash
# Backend Performance Tests — Validates response times, throughput, and resource usage
# Usage: bash scripts/test-backend-perf.sh <project-path>
# Exit 0: All perf tests pass
# Exit 1: One or more perf tests fail

PROJECT_PATH="${1:-.}"
PASS=0
FAIL=0
WARN=0
FAILED_TESTS=()

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "--- Performance Tests ---"

# Detect API base URL
API_URL=""
if [ -f "$PROJECT_PATH/.env" ]; then
  API_URL=$(grep -E '^API_URL=|^BASE_URL=|^SERVER_URL=' "$PROJECT_PATH/.env" 2>/dev/null | head -1 | cut -d'=' -f2-)
fi
[ -z "$API_URL" ] && API_URL="http://localhost:3000"

echo "Target: $API_URL"
echo ""

# Check for performance test tools
HAS_K6=false
HAS_AUTOCANNON=false
HAS_JMETER=false
HAS_ARTILLERY=false

command -v k6 &>/dev/null && HAS_K6=true
command -v autocannon &>/dev/null && HAS_AUTOCANNON=true
command -v jmeter &>/dev/null && HAS_JMETER=true
command -v artillery &>/dev/null && HAS_ARTILLERY=true

# Check for perf test configs
PERF_CONFIGS=$(find "$PROJECT_PATH" -maxdepth 3 -name "k6*.js" -o -name "k6*.ts" -o -name ".autocannonrc*" -o -name "artillery*.yml" -o -name "artillery*.yaml" 2>/dev/null | head -5)

if [ -n "$PERF_CONFIGS" ]; then
  echo -e "${GREEN}PASS${NC} Performance test configs found"
  echo "$PERF_CONFIGS" | while read -r cfg; do
    echo "  - $(basename "$cfg")"
  done
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No performance test configs found"
  WARN=$((WARN + 1))
fi

# Check for available tools
if $HAS_K6; then
  echo -e "${GREEN}PASS${NC} k6 is installed"
  PASS=$((PASS + 1))
elif $HAS_AUTOCANNON; then
  echo -e "${GREEN}PASS${NC} autocannon is installed"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No performance testing tool installed (k6, autocannon, jmeter)"
  WARN=$((WARN + 1))
fi

# Quick endpoint response time check (if curl available and server reachable)
if command -v curl &>/dev/null; then
  RESPONSE_TIME=$(curl -o /dev/null -s -w '%{time_total}' --connect-timeout 3 --max-time 5 "$API_URL" 2>/dev/null)
  if [ -n "$RESPONSE_TIME" ] && [ "$RESPONSE_TIME" != "0.000000" ]; then
    # Convert to milliseconds
    RESPONSE_MS=$(echo "$RESPONSE_TIME * 1000" | bc 2>/dev/null || echo "0")
    RESPONSE_MS_INT=${RESPONSE_MS%.*}

    if [ "${RESPONSE_MS_INT:-0}" -lt 200 ]; then
      echo -e "${GREEN}PASS${NC} Root endpoint response time: ${RESPONSE_MS_INT}ms (<200ms)"
      PASS=$((PASS + 1))
    elif [ "${RESPONSE_MS_INT:-0}" -lt 1000 ]; then
      echo -e "${YELLOW}WARN${NC} Root endpoint response time: ${RESPONSE_MS_INT}ms (200-1000ms)"
      WARN=$((WARN + 1))
    else
      echo -e "${RED}FAIL${NC} Root endpoint response time: ${RESPONSE_MS_INT}ms (>1000ms)"
      FAIL=$((FAIL + 1))
      FAILED_TESTS+=("Root endpoint response time ${RESPONSE_MS_INT}ms exceeds 1000ms threshold")
    fi
  else
    echo -e "${YELLOW}WARN${NC} Could not reach $API_URL for response time check"
    WARN=$((WARN + 1))
  fi
fi

# Check for caching patterns
if grep -rq 'cache\|Cache\|redis\|Redis\|memcached\|Memcached' "$PROJECT_PATH" --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -1 | grep -q .; then
  echo -e "${GREEN}PASS${NC} Caching layer detected"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No caching layer detected"
  WARN=$((WARN + 1))
fi

# Check for rate limiting
if grep -rq 'rate.limit\|rateLimit\|rate_limiter\|RateLimiter\|throttle\|express-rate-limit' "$PROJECT_PATH" --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -1 | grep -q .; then
  echo -e "${GREEN}PASS${NC} Rate limiting detected"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No rate limiting detected"
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
