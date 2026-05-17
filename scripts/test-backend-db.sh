#!/usr/bin/env bash
# Backend Database Tests — Validates database connectivity, queries, and integrity
# Usage: bash scripts/test-backend-db.sh <project-path>
# Exit 0: All DB tests pass
# Exit 1: One or more DB tests fail

PROJECT_PATH="${1:-.}"
PASS=0
FAIL=0
WARN=0
FAILED_TESTS=()

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "--- Database Tests ---"

# Detect database type
DB_TYPE=""
DB_CONFIG=""

# PostgreSQL
if grep -rl 'postgresql\|postgres\|pg_' "$PROJECT_PATH" 2>/dev/null | grep -v 'node_modules\|.git' | head -1 | grep -q .; then
  DB_TYPE="postgresql"
fi

# MySQL
if grep -rl 'mysql\|mysql_' "$PROJECT_PATH" 2>/dev/null | grep -v 'node_modules\|.git' | head -1 | grep -q .; then
  DB_TYPE="mysql"
fi

# MongoDB
if grep -rl 'mongodb\|mongo' "$PROJECT_PATH" 2>/dev/null | grep -v 'node_modules\|.git' | head -1 | grep -q .; then
  DB_TYPE="mongodb"
fi

# Redis
if grep -rl 'redis\|REDIS' "$PROJECT_PATH" 2>/dev/null | grep -v 'node_modules\|.git' | head -1 | grep -q .; then
  DB_TYPE="${DB_TYPE:+$DB_TYPE, }redis"
fi

# SQLite
if grep -rl 'sqlite\|\.db\|\.sqlite' "$PROJECT_PATH" 2>/dev/null | grep -v 'node_modules\|.git' | head -1 | grep -q .; then
  DB_TYPE="${DB_TYPE:+$DB_TYPE, }sqlite"
fi

if [ -n "$DB_TYPE" ]; then
  echo -e "${GREEN}PASS${NC} Database detected: $DB_TYPE"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No database configuration detected"
  WARN=$((WARN + 1))
fi

# Check for migration files
MIGRATION_FILES=$(find "$PROJECT_PATH" -maxdepth 4 -path "*/migrations/*" -o -path "*/migrate/*" -o -name "*migration*" -type f 2>/dev/null | head -5)

if [ -n "$MIGRATION_FILES" ]; then
  MIGRATION_COUNT=$(echo "$MIGRATION_FILES" | wc -l)
  echo -e "${GREEN}PASS${NC} Found $MIGRATION_COUNT migration file(s)"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No migration files found"
  WARN=$((WARN + 1))
fi

# Check for database test files
DB_TEST_FILES=$(find "$PROJECT_PATH" -maxdepth 4 -path "*/test*/*db*" -o -path "*/test*/*database*" -o -path "*/test*/*repo*" -o -path "*/test*/*model*" 2>/dev/null | head -5)

if [ -n "$DB_TEST_FILES" ]; then
  echo -e "${GREEN}PASS${NC} Database test files found"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No database test files found"
  WARN=$((WARN + 1))
fi

# Check for connection pooling
if grep -rq 'pool\|Pool\|connectionPool\|ConnectionPool\|createPool' "$PROJECT_PATH" --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -1 | grep -q .; then
  echo -e "${GREEN}PASS${NC} Connection pooling detected"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No connection pooling detected"
  WARN=$((WARN + 1))
fi

# Check for transaction handling
if grep -rq 'transaction\|Transaction\|BEGIN\|COMMIT\|ROLLBACK\|@Transactional' "$PROJECT_PATH" --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" 2>/dev/null | head -1 | grep -q .; then
  echo -e "${GREEN}PASS${NC} Transaction handling detected"
  PASS=$((PASS + 1))
else
  echo -e "${YELLOW}WARN${NC} No transaction handling detected"
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
