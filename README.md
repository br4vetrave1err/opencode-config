# Opencode Agent Configuration

This repository stores the configuration for the opencode AI agent running on this system. It includes MCP server configs, custom skills, and automated Obsidian vault sync.

## Structure

```
opencode-config/
├── opencode.json          # MCP (Model Context Protocol) configuration
├── skills/                # Custom agent skills (21 skills)
│   ├── caveman/
│   ├── design-an-interface/
│   ├── domain-model/
│   ├── edit-article/
│   ├── find-skills/
│   ├── git-guardrails-claude-code/
│   ├── github-triage/
│   ├── grill-me/
│   ├── improve-codebase-architecture/
│   ├── obsidian-vault/
│   ├── qa/
│   ├── request-refactor-plan/
│   ├── scaffold-exercises/
│   ├── setup-pre-commit/
│   ├── tdd/
│   ├── to-issues/
│   ├── to-prd/
│   ├── triage-issue/
│   ├── ubiquitous-language/
│   ├── write-a-skill/
│   └── zoom-out/
└── scripts/               # Automation scripts
    ├── sync-obsidian.sh       # Linux sync
    ├── sync-obsidian.ps1      # Windows sync
    ├── setup-cron.sh          # Linux scheduler
    └── setup-task-scheduler.ps1 # Windows scheduler
```

## MCP Servers Configured

- **Confluence** - Atlassian Confluence integration
- **Obsidian** - Local vault sync
- **GitHub** - GitHub API integration

## Skills Overview

The project includes 21 custom skills for the opencode agent:

| Skill | Description |
|-------|-------------|
| `tdd` | Test-driven development (supports Python/pytest, JS/Vitest, React Testing Library) |
| `setup-pre-commit` | Set up Husky pre-commit hooks (supports npm/yarn/pnpm/uv/poetry) |
| `improve-codebase-architecture` | Find architectural improvements, deep modules |
| `scaffold-exercises` | Create exercise directory structures |
| `domain-model` | DDD context mapping, ADR creation |
| `grill-me` | Interview user to stress-test plans |
| `design-it-twice` | Generate multiple interface designs |
| `ubiquitous-language` | Extract DDD glossary |
| `github-triage` | Triage GitHub issues |
| `to-prd` | Convert context to PRD |
| `to-issues` | Break plan into GitHub issues |
| `triage-issue` | Investigate and plan bug fixes |
| `qa` | Interactive QA/bug reporting |
| `obsidian-vault` | Search/manage Obsidian notes |
| `write-a-skill` | Create new agent skills |
| `scaffold-exercises` | Exercise directory scaffolding |
| `setup-pre-commit` | Pre-commit hook setup |
| `git-guardrails-claude-code` | Block dangerous git commands |
| `edit-article` | Edit and improve articles |
| `caveman` | Ultra-compressed communication mode |
| `zoom-out` | Get broader context |

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/br4vetrave1err/opencode-config.git ~/opencode-config
```

### 2. Copy Configuration to Opencode

```bash
cp ~/opencode-config/opencode.json ~/.config/opencode/opencode.json
```

### 3. Install Skills

Copy the skills directory to your agent's skills folder:

```bash
cp -r ~/opencode-config/skills ~/.agents/skills
```

### 4. Set Up Obsidian Vault Sync

#### Linux (cron)

```bash
cd ~/opencode-config/scripts
chmod +x sync-obsidian.sh setup-cron.sh
./setup-cron.sh
```

#### Windows (Task Scheduler)

```powershell
# Run PowerShell as Administrator
cd .\scripts
.\setup-task-scheduler.ps1
```

### 5. Manual Sync (Optional)

```bash
# Linux
./scripts/sync-obsidian.sh

# Windows
powershell -ExecutionPolicy Bypass -File .\scripts\sync-obsidian.ps1
```

## Language Support

### Python

- **Package managers**: uv, Poetry
- **Linting**: Ruff, mypy
- **Testing**: pytest
- **Typing**: Pydantic (with `@runtime_checkable` Protocols)

### JavaScript/TypeScript

- **Package managers**: npm, pnpm, yarn
- **Linting/Formatting**: Prettier, ESLint
- **Testing**: Vitest, Jest
- **Type checking**: TypeScript (tsc)

### React + TypeScript

- **Framework**: React + Vite
- **Testing**: Vitest + React Testing Library + user-event
- **API Mocking**: MSW (Mock Service Worker)
- **E2E**: Playwright (optional)

## Environment Variables

Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env
```

```env
ATLASSIAN_SITE_NAME=https://your-site.atlassian.net/wiki/
ATLASSIAN_USER_EMAIL=your-email@example.com
ATLASSIAN_API_TOKEN=your-api-token
GITHUB_TOKEN=your-github-token
```

## Updating

To pull latest changes and sync:

```bash
cd ~/opencode-config
git pull origin main

# Update skills
cp -r skills ~/.agents/

# Update config
cp opencode.json ~/.config/opencode/
```

## Notes

- The `opencode.json` in this repo has secrets replaced with placeholders
- For local development, create your own `~/.config/opencode/opencode.json` with real tokens
- The Obsidian sync runs daily at 6:00 AM by default
- Scripts log to `~/.obsidian-sync.log` (Linux) or Event Viewer (Windows)