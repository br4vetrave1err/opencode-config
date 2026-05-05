# Coding Domain Validation Rules

## Validation Criteria

Output is validated against these coding-specific checks:

### 1. Test Execution
- [ ] All tests pass (pytest, jest, vitest, etc.)
- [ ] No test is skipped unless explicitly allowed
- [ ] Test coverage meets threshold (if specified)

### 2. Code Quality
- [ ] No syntax errors
- [ ] No linting errors (flake8, eslint, etc.)
- [ ] Code follows language conventions

### 3. Logic Correctness
- [ ] Implementation matches problem requirements
- [ ] Edge cases handled (empty input, large input, etc.)
- [ ] No hardcoded values unless required

### 4. TDD Compliance (if required)
- [ ] Tests written before implementation
- [ ] Tests fail before implementation
- [ ] Tests pass after implementation

## Validation Commands

Run these commands to validate:

```bash
# Python
pytest tests/ -v --tb=short
flake8 .
python -m py_compile *.py

# JavaScript/TypeScript
npm test
npm run lint
npx tsc --noEmit

# Go
go test ./...
go fmt ./...
go vet ./...

# Rust
cargo test
cargo fmt --check
cargo clippy
```

## Scoring

| Check | Weight |
|-------|--------|
| Tests pass | 30 |
| No syntax errors | 20 |
| No lint errors | 20 |
| Edge cases handled | 15 |
| TDD compliance | 15 |

**Pass threshold**: Score >= 80

## Common Issues

- Test fails: Check test assertions match expected behavior
- Lint error: Fix formatting or style
- Syntax error: Check parentheses, brackets, import statements
- Logic error: Review problem requirements again