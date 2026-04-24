# Opencode Agent Configuration

This repository stores the configuration for the opencode AI agent running on this system. It includes MCP server configs, custom skills, and automated Obsidian vault sync.

## Structure

```
opencode-config/
├── opencode.json          # MCP (Model Context Protocol) configuration
├── skills/                # Custom agent skills (23 skills)
│   ├── caveman/
│   ├── continuous-monitor/    # Docker continuous monitoring
│   ├── design-an-interface/
│   ├── docker-monitor/        # Docker container debugging
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
├── scripts/               # Automation scripts
│   ├── sync-obsidian.sh       # Linux sync
│   ├── sync-obsidian.ps1      # Windows sync
│   ├── setup-cron.sh          # Linux scheduler
│   ├── setup-task-scheduler.ps1 # Windows scheduler
│   ├── monitor.sh             # Docker monitor (Linux)
│   └── monitor.ps1            # Docker monitor (Windows)
└── README.md
```

## MCP Servers Configured

- **Confluence** - Atlassian Confluence integration
- **Obsidian** - Local vault sync
- **GitHub** - GitHub API integration

## Skills Overview

The project includes 23 custom skills for the opencode agent:

| Skill | Description |
|-------|-------------|
| `tdd` | Test-driven development (Python/pytest, JS/Vitest, React Testing Library) |
| `setup-pre-commit` | Pre-commit hooks (npm/yarn/pnpm, uv/poetry) |
| `improve-codebase-architecture` | Deep module refactoring |
| `docker-monitor` | Docker container debugging, log analysis |
| `continuous-monitor` | Background monitor with auto-restart |
| `scaffold-exercises` | Exercise directory scaffolding |
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
cd .\scripts
.\setup-task-scheduler.ps1
```

### 5. Docker Continuous Monitor

The monitor script takes a Makefile path and target, auto-starts containers if not running, and restarts on failure.

#### Linux

```bash
cd ~/opencode-config/scripts

# Monitor a project
./monitor.sh /path/to/project/Makefile up
./monitor.sh ./Makefile dev

# Run in background
./monitor.sh /path/to/Makefile up &
```

#### Windows

```powershell
# With parameters
.\monitor.ps1 -Makefile "C:\path\to\Makefile" -Target up

# Interactive (prompts for Makefile path)
.\monitor.ps1
```

View logs:
```bash
tail -f ~/.docker-monitor.log      # All logs
tail -f ~/.docker-monitor-errors.log  # Errors only
```

Stop monitor:
```bash
pkill -f monitor.sh    # Linux
# or Ctrl+C in terminal
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

```bash
cd ~/opencode-config
git pull origin main
cp -r skills ~/.agents/
cp opencode.json ~/.config/opencode/
```

## Notes

- `opencode.json` has secrets replaced with placeholders
- Create your own `~/.config/opencode/opencode.json` with real tokens
- Obsidian sync runs daily at 6:00 AM
- Docker monitor logs: `~/.docker-monitor.log`, `~/.docker-monitor-errors.log`