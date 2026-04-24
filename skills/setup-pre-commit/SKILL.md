---
name: setup-pre-commit
description: Set up pre-commit hooks with lint-staged, type checking, and tests. Supports JavaScript/TypeScript (npm/pnpm/yarn) and Python (uv/poetry). Use when user wants to add pre-commit hooks, set up Husky, configure lint-staged, or add commit-time formatting/typechecking/testing.
---

# Setup Pre-Commit Hooks

## What This Sets Up

- **Husky** pre-commit hook (or raw `.git/hooks/pre-commit` on non-GitHub CI)
- **lint-staged** running formatters on staged files
- **typecheck** and **test** scripts in the pre-commit hook

## Steps

### 1. Detect project type

**JavaScript/TypeScript**: Check for `package.json`, `package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `bun.lockb`

**Python**: Check for `pyproject.toml`, `uv.lock`, `poetry.lock`, `requirements.txt`

### 2. JavaScript/TypeScript Setup

#### Install dependencies

```bash
npm install -D husky lint-staged prettier
# or: pnpm add -D husky lint-staged prettier
# or: yarn add -D husky lint-staged prettier
```

#### Initialize Husky

```bash
npx husky init
```

#### Create `.husky/pre-commit`

```
npx lint-staged
npm run typecheck
npm run test
```

**Adapt**: Replace `npm` with detected package manager. If no `typecheck` or `test` script in package.json, omit those lines.

#### Create `.lintstagedrc`

```json
{
  "*": "prettier --ignore-unknown --write"
}
```

### 3. Python Setup (uv)

#### Install dependencies

```bash
uv add --dev husky lint-staged ruff
```

#### Create `.husky/pre-commit`

```
uv run ruff check .
uv run ruff format .
uv run mypy .
uv run pytest
```

#### Create `.ruff.toml` (if missing)

```toml
target-version = "py311"
line-length = 100

[lint]
select = ["E", "F", "I", "N", "W", "UP"]
ignore = ["E501"]

[lint.isort]
known-first-party = ["app"]
```

#### Create `mypy.ini` or configure in pyproject.toml

```toml
[tool.mypy]
python_version = "3.11"
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = false
```

### 4. Python Setup (Poetry)

```bash
poetry add --dev husky ruff mypy pytest
```

### 5. Verify

- [ ] `.husky/pre-commit` exists and is executable
- [ ] `lint-staged` config exists (`.lintstagedrc` or in package.json)
- [ ] Prettier/Ruff config exists
- [ ] Run lint-staged to verify: `npx lint-staged` or `uvx lint-staged`

### 6. Commit

Stage all changed/created files and commit with message: `Add pre-commit hooks`

## Notes

- Python projects can use [pre-commit](https://pre-commit.com/) instead of Husky for broader CI support
- For TypeScript, add `npm run typecheck` if using tsc (or `tsc --noEmit`)
- For React + Vite + Vitest: `npm run test:run` or `vitest run`
- `prettier --ignore-unknown` skips files Prettier can't parse (images, etc.)