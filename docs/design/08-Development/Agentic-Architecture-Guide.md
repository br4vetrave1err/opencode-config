# OpenCode Agentic Architecture — Complete Guide

**Last Updated:** 2026-05-17
**Version:** 2.0
**Status:** Production — 126 tests passing, 3 workflows deployed

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Directory Structure](#2-directory-structure)
3. [MCP Server Layer](#3-mcp-server-layer)
4. [Agent System](#4-agent-system)
5. [Skill System](#5-skill-system)
6. [Command System](#6-command-system)
7. [Automation Pipeline](#7-automation-pipeline)
8. [Testing Framework](#8-testing-framework)
9. [CI/CD Workflows](#9-cicd-workflows)
10. [Development Workflow](#10-development-workflow)
11. [Decision Logic](#11-decision-logic)
12. [Security Model](#12-security-model)
13. [Troubleshooting](#13-troubleshooting)

---

## 1. Architecture Overview

The OpenCode agentic architecture is a **4-layer system** that transforms a code editor into an AI-powered development environment:

```
┌─────────────────────────────────────────────────────────────┐
│                    OpenCode TUI (User Interface)             │
├─────────────────────────────────────────────────────────────┤
│  Layer 1: MCP Servers  │  Layer 2: Agents  │  Layer 3: Skills│
│  - Postman (remote)    │  - readiness-analyzer│  - 38 skills  │
│  - Atlassian (remote)  │  - pr-babysitter    │  - Redis rules │
│  - Confluence (local)  │  - split-to-prs     │  - Playwright  │
│  - Obsidian (local)    │  - test-agent       │  - Postman     │
│  - GitHub (local)      │                     │  - Atlassian   │
├─────────────────────────────────────────────────────────────┤
│  Layer 4: Commands & Automation                              │
│  - 10 commands (8 Postman + /test + /sync)                   │
│  - Auto-sync pipeline (detect → sync → docs → commit → push) │
│  - Test orchestrator (backend + frontend + full)             │
├─────────────────────────────────────────────────────────────┤
│  CI/CD Layer: GitHub Actions                                 │
│  - validate-config.yml (on push)                             │
│  - sync-and-log.yml (daily cron)                             │
│  - agent-evals.yml (manual trigger)                          │
└─────────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Source of Truth**: `~/.config/opencode/` is the live config; git repo is the sanitized mirror
2. **4-Way Sync**: Local config ↔ Git repo ↔ Obsidian vault ↔ GitHub remote
3. **Secret Safety**: All secrets are redacted before syncing to git
4. **TDD First**: Every script has tests; 126 tests total, all passing
5. **Agent Autonomy**: Agents make decisions based on detected changes, not fixed rules

---

## 2. Directory Structure

### Live Config (`~/.config/opencode/`)

```
~/.config/opencode/
├── opencode.json              # MCP servers, agents, permissions, instructions
├── tui.json                   # TUI theme, keybinds, scroll settings
├── AGENTS.md                  # Global rules + Redis rules glob
├── agents/                    # Custom subagents (4 files)
│   ├── readiness-analyzer.md
│   ├── pr-babysitter.md
│   ├── split-to-prs.md
│   └── test-agent.md
├── commands/                  # Slash commands (10 files)
│   ├── postman-codegen.md
│   ├── postman-docs.md
│   ├── postman-mock.md
│   ├── postman-search.md
│   ├── postman-security.md
│   ├── postman-setup.md
│   ├── postman-sync.md
│   ├── postman-test.md
│   ├── sync.md                # Auto-sync pipeline trigger
│   └── test.md                # Test orchestrator trigger
├── skills/                    # AI skills (38 directories, 122+ files)
│   ├── redis-development/     # 37 rules across 11 categories
│   ├── playwright-cli/        # Browser automation + 36 tests
│   ├── postman-knowledge/     # Postman MCP concepts
│   ├── postman-routing/       # API request routing
│   ├── agent-ready-apis/      # API compatibility analysis
│   ├── tdd/                   # Test-driven development
│   ├── test-orchestrator/     # Unified test routing
│   ├── qa/                    # Bug reporting & issue filing
│   ├── triage-issue/          # Issue investigation
│   ├── github-triage/         # GitHub issue management
│   ├── jira-triage-issue/     # Jira issue management
│   ├── capture-tasks-from-meeting-notes/
│   ├── generate-status-report/
│   ├── spec-to-backlog/
│   ├── to-issues/
│   ├── to-prd/
│   ├── domain-model/
│   ├── ubiquitous-language/
│   ├── grill-me/
│   ├── design-an-interface/
│   ├── improve-codebase-architecture/
│   ├── request-refactor-plan/
│   ├── edit-article/
│   ├── write-a-skill/
│   ├── create-skill/
│   ├── create-rule/
│   ├── create-subagent/
│   ├── find-skills/
│   ├── setup-pre-commit/
│   ├── opencode-sdk/
│   ├── zoom-out/
│   ├── caveman/
│   ├── search-company-knowledge/
│   ├── obsidian-vault/
│   ├── git-guardrails-claude-code/
│   └── update-opencode-*/     # Config & settings updaters
├── scripts/                   # Automation scripts (12 files)
│   ├── auto-sync.sh           # Main sync orchestrator
│   ├── sync-to-repo.sh        # File sync with secret sanitization
│   ├── update-docs.sh         # Documentation updater
│   ├── test-orchestrator.sh   # Test routing & execution
│   ├── test-backend-api.sh    # API testing
│   ├── test-backend-db.sh     # Database testing
│   ├── test-backend-perf.sh   # Performance testing
│   ├── test-backend-security.sh # Security testing
│   ├── test-frontend-unit.sh  # Unit testing
│   ├── test-frontend-integration.sh
│   ├── test-frontend-component.sh
│   ├── test-frontend-e2e.sh   # E2E testing
│   ├── secrets-scan.sh        # Secret detection
│   ├── validate-config.sh     # Config validation
│   ├── detect-drift.sh        # Drift detection
│   ├── generate-changelog.sh  # Changelog generation
│   ├── setup-cron.sh          # Cron job setup
│   ├── sync-obsidian.sh       # Obsidian sync
│   └── [PowerShell variants]
├── tests/                     # Test suites (126 tests)
│   ├── run-all-tests.sh       # Unified test runner
│   ├── config-validation/     # 56 config tests
│   │   ├── test-secrets-scan.sh       (18 tests)
│   │   ├── test-validate-config.sh    (13 tests)
│   │   ├── test-detect-drift.sh       (14 tests)
│   │   ├── test-generate-changelog.sh (11 tests)
│   │   └── test-auto-sync.sh          (29 tests)
│   └── test-orchestrator/     # 41 orchestrator tests
│       └── run-all-test-scripts.sh
└── plugins/                   # OpenCode plugin hooks
```

### Git Repo Mirror (`~/Desktop/projects/opencode-config/`)

Same structure as above, plus:
```
├── docs/design/               # Documentation backup (22 files)
│   ├── 00-Overview.md
│   ├── 01-Architecture/       (8 files)
│   ├── 02-Migration/          (4 files)
│   ├── 03-Skills/             (5 files)
│   ├── 04-Updates/            (1 file)
│   ├── 05-Reference/          (3 files)
│   ├── 06-Testing/            (4 files)
│   └── 07-Observability/      (3 files)
├── .github/workflows/         # CI/CD (3 workflows)
│   ├── validate-config.yml
│   ├── sync-and-log.yml
│   └── agent-evals.yml
├── README.md
├── .env.example
└── .gitignore
```

---

## 3. MCP Server Layer

### Configured Servers (5 total)

| Server | Type | URL/Command | Purpose |
|--------|------|-------------|---------|
| **Postman** | Remote | `https://mcp.postman.com/mcp` | API collection management, mock servers, monitors |
| **Atlassian** | Remote | `https://mcp.atlassian.com/v1/mcp` | Jira issues, Confluence pages, project management |
| **Confluence** | Local | `npx atlassian-confluence-mcp-server@latest` | Direct Confluence API access |
| **Obsidian** | Local | `npx @bitbonsai/mcpvault@latest <vault-path>` | Note management, search, wikilinks |
| **GitHub** | Local | `npx @modelcontextprotocol/server-github` | Repo management, issues, PRs, code search |

### Connection Status

```bash
opencode mcp list
# Expected output:
# ● ✓ postman      connected  (https://mcp.postman.com/mcp)
# ● ✓ atlassian    connected  (https://mcp.atlassian.com/v1/mcp)
# ● ✓ confluence   connected  (local)
# ● ✓ obsidian     connected  (local)
# ● ✓ github       connected  (local)
```

### Authentication

- **Remote servers**: OAuth flow (tokens stored in OpenCode's secure storage)
- **Local servers**: Environment variables in `opencode.json`
- **Secrets**: Redacted in git repo (`***REDACTED***`)

---

## 4. Agent System

### Built-in Agents (5)

OpenCode includes 5 built-in agents for common tasks:
- `explore` — Codebase exploration
- `general` — General-purpose tasks
- `pr-babysitter` — PR maintenance (also customized)
- `readiness-analyzer` — API analysis (also customized)
- `split-to-prs` — PR splitting (also customized)

### Custom Subagents (4)

| Agent | Mode | Purpose | Permissions |
|-------|------|---------|-------------|
| **readiness-analyzer** | subagent | Analyze APIs for AI agent compatibility (8 pillars, 48 checks) | edit, bash, read, glob, grep |
| **pr-babysitter** | subagent | Keep PRs merge-ready (triage comments, resolve conflicts, fix CI) | bash, read, glob, grep |
| **split-to-prs** | subagent | Split large changes into multiple PRs with proper boundaries | bash, read, glob, grep |
| **test-agent** | subagent | Unified test orchestration (auto-detect, route, execute) | bash, read, glob, grep |

### Agent Configuration

Defined in `opencode.json` under `"agent"`:

```json
{
  "agent": {
    "readiness-analyzer": {
      "description": "Analyze any API for AI agent compatibility...",
      "mode": "subagent",
      "permission": { "edit": "allow", "bash": "allow", ... },
      "options": {}
    }
  }
}
```

---

## 5. Skill System

### Overview

38 skill directories containing 122+ files across these categories:

| Category | Skills | Purpose |
|----------|--------|---------|
| **Testing** | tdd, test-orchestrator, qa, triage-issue | Test-driven development, test execution, bug reporting |
| **API/Postman** | postman-knowledge, postman-routing, agent-ready-apis | API management, routing, compatibility analysis |
| **Project Management** | github-triage, jira-triage-issue, capture-tasks-from-meeting-notes, generate-status-report, spec-to-backlog, to-issues, to-prd | Issue tracking, task extraction, PRD generation |
| **Architecture** | domain-model, ubiquitous-language, grill-me, design-an-interface, improve-codebase-architecture, request-refactor-plan | DDD, terminology, design, refactoring |
| **Development** | edit-article, write-a-skill, create-skill, create-rule, create-subagent, find-skills, setup-pre-commit | Content creation, skill/rule creation, project setup |
| **Infrastructure** | opencode-sdk, zoom-out, caveman, search-company-knowledge, obsidian-vault, git-guardrails-claude-code, update-opencode-* | SDK usage, communication modes, vault management, safety |
| **Redis** | redis-development | 37 rules across 11 categories (connection, data, JSON, RQE, vector, etc.) |
| **Browser** | playwright-cli | Browser automation with 36 tests |

### Redis Development Skill

The `redis-development` skill is loaded via glob pattern in `AGENTS.md`:

```markdown
~/.config/opencode/skills/redis-development/rules/*.md
```

37 rules across 11 categories:
1. Data Structures & Keys (4 rules)
2. Memory & Expiration (2 rules)
3. Connection & Performance (4 rules)
4. JSON Documents (2 rules)
5. Redis Query Engine (6 rules)
6. Vector Search & RedisVL (4 rules)
7. Semantic Caching (2 rules)
8. Streams & Pub/Sub (1 rule)
9. Clustering & Replication (2 rules)
10. Security (3 rules)
11. Observability (2 rules)

---

## 6. Command System

### Postman Commands (8)

| Command | Purpose |
|---------|---------|
| `/postman-setup` | Initialize Postman workspace, collections, environments |
| `/postman-search` | Search APIs in Postman network |
| `/postman-codegen` | Generate client code from Postman requests |
| `/postman-test` | Run Postman collection tests |
| `/postman-docs` | Publish/unpublish API documentation |
| `/postman-mock` | Create/manage mock servers |
| `/postman-sync` | Sync collections with API specs |
| `/postman-security` | Security testing for APIs |

### Automation Commands (2)

| Command | Purpose |
|---------|---------|
| `/sync` | Auto-sync configs → git repo → update docs → commit → push |
| `/test` | Run tests with auto-detection and routing |

---

## 7. Automation Pipeline

### `/sync` Command Flow

```
User runs: /sync [--push] [--dry-run]
                    │
                    ▼
        ┌───────────────────────┐
        │   1. Detect Changes   │
        │   - Compare local     │
        │     vs git repo       │
        │   - New/modified/     │
        │     deleted files     │
        │   - opencode.json,    │
        │     tui.json changes  │
        └───────────┬───────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │   2. Sync to Repo     │
        │   - rsync with        │
        │     exclusions        │
        │   - Secret            │
        │     sanitization      │
        │   - Exclude: docs/,   │
        │     .github/, *.log   │
        └───────────┬───────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │  3. Update Docs       │
        │  - Overview.md        │
        │  - Skills-Index.md    │
        │  - Agent-Catalog.md   │
        │  - Command-Catalog.md │
        │  - MCP-Catalog.md     │
        │  - Changelog.md       │
        │  - Sync to Obsidian   │
        └───────────┬───────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │  4. Commit & Push     │
        │  - Auto commit msg    │
        │  - Push if --push     │
        └───────────────────────┘
```

### Scripts

| Script | Purpose |
|--------|---------|
| `auto-sync.sh` | Main orchestrator (detect → sync → docs → commit → push) |
| `sync-to-repo.sh` | File sync with secret sanitization (jq-based redaction) |
| `update-docs.sh` | Documentation updater (perl-based replacements, Obsidian sync) |

### Secret Sanitization

Patterns redacted in `opencode.json`:
- `ghp_` — GitHub tokens
- `ATATT` — Atlassian tokens
- `sk-[a-zA-Z0-9]` — OpenAI/API keys
- `AKIA[0-9]` — AWS keys
- `AIza` — Google API keys
- `eyJ` — JWT tokens

---

## 8. Testing Framework

### `/test` Command Flow

```
User runs: /test [type]
                    │
                    ▼
        ┌───────────────────────┐
        │   1. Detect Project   │
        │   - Scan for markers  │
        │     (package.json,    │
        │      pom.xml, etc.)   │
        │   - Identify language │
        │     & framework       │
        └───────────┬───────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │   2. Route Tests      │
        │   - api → backend     │
        │   - db → backend      │
        │   - perf → backend    │
        │   - security → backend│
        │   - unit → frontend   │
        │   - integration → FE  │
        │   - component → FE    │
        │   - e2e → frontend    │
        │   - backend → all BE  │
        │   - frontend → all FE │
        │   - full → everything │
        └───────────┬───────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │   3. Execute Tests    │
        │   - Run scripts       │
        │   - Parallel where    │
        │     safe              │
        │   - Capture output    │
        └───────────┬───────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │   4. Report Results   │
        │   - Parse pass/fail   │
        │   - Create issues     │
        │   - Save results      │
        └───────────────────────┘
```

### Test Categories

| Category | Scripts | Tests | Purpose |
|----------|---------|-------|---------|
| **Config Validation** | 4 scripts | 56 tests | Secrets scan, config validation, drift detection, changelog |
| **Auto-Sync & Docs** | 1 script | 29 tests | Auto-sync, update-docs, secret sanitization, Obsidian sync |
| **Test Orchestrator** | 1 script | 41 tests | Detection logic, routing, backend/frontend scripts |
| **Total** | 6 scripts | **126 tests** | All passing |

### Test Execution

```bash
# Run all tests
bash tests/run-all-tests.sh

# Run specific test suite
bash tests/config-validation/test-auto-sync.sh
bash tests/test-orchestrator/run-all-test-scripts.sh
```

---

## 9. CI/CD Workflows

### 1. validate-config.yml

**Trigger**: On push to `main`
**Purpose**: Validate config files, run tests, check for secrets

```yaml
jobs:
  validate:
    - Checkout
    - Install jq
    - Validate opencode.json schema
    - Run secrets scan
    - Run all tests
    - Check for drift
```

### 2. sync-and-log.yml

**Trigger**: Daily at 10 PM UTC (cron)
**Purpose**: Detect drift, generate changelog, commit updates

```yaml
jobs:
  sync-and-log:
    - Checkout (fetch-depth: 0)
    - Detect drift
    - Generate changelog
    - Commit changelog
```

### 3. agent-evals.yml

**Trigger**: Manual (`workflow_dispatch`)
**Purpose**: Run agent evaluation scenarios

```yaml
jobs:
  evals:
    - Checkout
    - Run eval scenarios
    - Generate report
```

---

## 10. Development Workflow

### Daily Workflow

```
1. Make changes in ~/.config/opencode/
2. Run: /sync --push
   - Detects changes
   - Syncs to git repo (secrets redacted)
   - Updates documentation
   - Commits with auto-generated message
   - Pushes to remote
3. CI/CD validates on push
```

### Adding New Components

| Component | Where to Add | What to Update |
|-----------|-------------|----------------|
| New skill | `~/.config/opencode/skills/<name>/SKILL.md` | Run `/sync --push` |
| New agent | `~/.config/opencode/agents/<name>.md` + `opencode.json` | Run `/sync --push` |
| New command | `~/.config/opencode/commands/<name>.md` | Run `/sync --push` |
| New script | `~/.config/opencode/scripts/<name>.sh` + tests | Run `/sync --push` |
| New MCP server | `opencode.json` under `mcp` | Run `/sync --push` |

### Testing New Code

```bash
# TDD workflow
1. Write test first → RED
2. Implement feature → GREEN
3. Refactor → REFACTOR
4. Run all tests: bash tests/run-all-tests.sh
5. Sync: /sync --push
```

---

## 11. Decision Logic

### Auto-Sync Decision Matrix

| Change Detected | Actions Taken |
|----------------|---------------|
| New/modified skill | Update Skills-Index, Overview, Changelog |
| New/modified agent | Update Agent-Catalog, Overview, Changelog |
| New/modified command | Update Command-Catalog, Overview, Changelog |
| opencode.json change | Update MCP-Catalog, Overview, Changelog |
| Any config change | All catalogs + Overview + Changelog + Obsidian sync |
| No changes | Exit early (no action) |

### Test Routing Decision Matrix

| User Input | Project Detected | Tests Run |
|------------|-----------------|-----------|
| `/test api` | Any | Backend API tests |
| `/test db` | Any | Database tests |
| `/test perf` | Any | Performance tests |
| `/test security` | Any | Security tests |
| `/test unit` | Node/Python/Go | Unit tests |
| `/test integration` | Node/Python/Go | Integration tests |
| `/test e2e` | Node/Python/Go | E2E tests |
| `/test backend` | Any | API + DB + Perf + Security |
| `/test frontend` | Node/Python/Go | Unit + Integration + Component + E2E |
| `/test full` | Any | Everything |

---

## 12. Security Model

### Secret Management

1. **Local config**: Secrets stored in `~/.config/opencode/opencode.json` (not in git)
2. **Git repo**: Secrets replaced with `***REDACTED***` by `sync-to-repo.sh`
3. **Patterns detected**: GitHub tokens, Atlassian tokens, OpenAI keys, AWS keys, Google keys, JWTs
4. **Exclusions**: `docs/`, `.github/`, `*.log` excluded from rsync to prevent accidental deletion

### Permission Model

| Permission | Scope | Default |
|------------|-------|---------|
| `*` | All tools | `allow` |
| Agent-specific | Per-agent | Configured in `opencode.json` |

### Git Safety

- `git-guardrails-claude-code` skill blocks dangerous commands
- Protected: `push --force`, `reset --hard`, `clean`, `branch -D`

---

## 13. Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| MCP server disconnected | OAuth token expired | Re-authenticate via OpenCode |
| Tests failing | Missing dependencies | Install required tools (jq, rsync, perl) |
| Docs out of sync | `/sync` not run | Run `/sync --push` |
| Secrets in git | Manual commit without sync | Run `/sync --push` to sanitize |
| rsync deletes files | `--delete` without exclusions | Ensure `docs/`, `.github/` in EXCLUDES |

### Diagnostic Commands

```bash
# Check MCP status
opencode mcp list

# Run all tests
bash ~/.config/opencode/tests/run-all-tests.sh

# Check for drift
bash ~/.config/opencode/scripts/detect-drift.sh --local ~/.config/opencode --repo ~/Desktop/projects/opencode-config

# Scan for secrets
bash ~/.config/opencode/scripts/secrets-scan.sh --dir ~/.config/opencode

# Validate config
bash ~/.config/opencode/scripts/validate-config.sh --config ~/.config/opencode/opencode.json
```

### Recovery

If `docs/design/` is accidentally deleted:

```bash
cd ~/Desktop/projects/opencode-config
git checkout <commit-before-deletion> -- docs/design/
bash scripts/update-docs.sh --repo . --obsidian "~/Documents/br4vetrave1er notes/agent config"
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Sync config to git | `/sync --push` |
| Run all tests | `/test full` or `bash tests/run-all-tests.sh` |
| Check MCP status | `opencode mcp list` |
| Scan for secrets | `bash scripts/secrets-scan.sh --dir ~/.config/opencode` |
| Validate config | `bash scripts/validate-config.sh --config ~/.config/opencode/opencode.json` |
| Detect drift | `bash scripts/detect-drift.sh --local ~/.config/opencode --repo ~/Desktop/projects/opencode-config` |
| Update docs only | `bash scripts/update-docs.sh --repo ~/Desktop/projects/opencode-config` |

---

**Total Stats:**
- **MCP Servers:** 5 (3 local + 2 remote)
- **Agents:** 4 custom subagents
- **Skills:** 38 directories (122+ files)
- **Commands:** 10 (8 Postman + 2 automation)
- **Scripts:** 12 automation scripts
- **Tests:** 126 (all passing)
- **CI/CD:** 3 workflows deployed
- **Docs:** 22 files in `docs/design/`
