# Opencode Agent Configuration

Consolidated AI agent configuration for OpenCode. Mirrors `~/.config/opencode/` with additional docs and scripts.

## Structure

```
opencode-config/
├── opencode.json              ← Main config (MCP, agents, permissions)
├── skills/                    ← 36 skills (mirrors ~/.config/opencode/skills/)
│   ├── caveman/               ← Original (21 skills from ~/.agents/skills/)
│   ├── design-an-interface/
│   ├── ...
│   ├── playwright-cli/        ← From Claude Code compatibility
│   ├── agent-ready-apis/      ← From Postman plugin (3)
│   ├── postman-knowledge/
│   ├── postman-routing/
│   ├── capture-tasks-from-meeting-notes/ ← From Atlassian plugin (5)
│   ├── generate-status-report/
│   ├── spec-to-backlog/
│   ├── search-company-knowledge/
│   ├── jira-triage-issue/
│   ├── create-rule/           ← From Cursor built-in (6)
│   ├── create-skill/
│   ├── create-subagent/
│   ├── opencode-sdk/
│   ├── update-opencode-config/
│   └── update-opencode-settings/
├── agents/                    ← 3 custom subagents
│   ├── readiness-analyzer.md
│   ├── pr-babysitter.md
│   └── split-to-prs.md
├── commands/                  ← 8 Postman workflow commands
│   ├── postman-sync.md
│   ├── postman-codegen.md
│   ├── postman-search.md
│   ├── postman-test.md
│   ├── postman-mock.md
│   ├── postman-docs.md
│   ├── postman-security.md
│   └── postman-setup.md
├── docs/
│   └── design/                ← Architecture & design docs (from Obsidian)
│       ├── 00-Overview.md
│       ├── 01-Architecture/   ← 8 files (system, directory, MCP, agent, etc.)
│       ├── 02-Migration/      ← 4 files (plan, checklist, conflicts)
│       ├── 03-Skills/         ← 5 files (catalogs for skills, agents, commands, MCP)
│       ├── 04-Updates/        ← Changelog
│       └── 05-Reference/      ← 3 files (quick-start, auth, reference index)
├── scripts/                   ← Automation (sync Obsidian docs to repo)
│   ├── sync-obsidian.sh       ← Linux: sync Obsidian → docs/design/
│   ├── sync-obsidian.ps1      ← Windows: sync Obsidian → docs/design/
│   ├── setup-cron.sh          ← Linux: schedule daily sync
│   └── setup-task-scheduler.ps1 ← Windows: schedule daily sync
├── README.md
├── .env.example
└── .gitignore
```

## MCP Servers

| Server | Type | Auth | Status |
|--------|------|------|--------|
| confluence | local | PAT | ✅ Active |
| obsidian | local | None | ✅ Active |
| github | local | Token | ✅ Active |
| postman | remote | OAuth 2.1 | ✅ Authenticated |
| atlassian | remote | OAuth 2.1 (PKCE) | ✅ Authenticated |

## Skills

36 skills across 5 categories:

| Category | Count | Examples |
|----------|-------|----------|
| Planning & Design | 8 | to-prd, to-issues, grill-me, design-an-interface |
| Development | 7 | tdd, triage-issue, improve-codebase-architecture |
| API & Postman | 6 | postman-sync, postman-codegen, agent-ready-apis |
| Project Management | 5 | capture-tasks-from-meeting-notes, generate-status-report |
| Tooling & Knowledge | 10 | obsidian-vault, write-a-skill, caveman |

See [docs/design/03-Skills/Skills-Index.md](docs/design/03-Skills/Skills-Index.md) for quick reference.

## Agents

| Agent | Mode | Description |
|-------|------|-------------|
| readiness-analyzer | subagent | Scan OpenAPI specs for agent-readiness (8 pillars, 48 checks) |
| pr-babysitter | subagent | Keep PRs merge-ready (conflicts, comments, CI loop) |
| split-to-prs | subagent | Split large changes into multiple PRs |

## Commands

All Postman workflow commands (trigger with `/` prefix in TUI):

| Command | Description |
|---------|-------------|
| `/postman-sync` | Sync Postman collections with local API code |
| `/postman-codegen` | Generate typed client code from collections |
| `/postman-search` | Discover APIs across workspaces |
| `/postman-test` | Run collection tests, diagnose failures |
| `/postman-mock` | Create mock servers |
| `/postman-docs` | Analyze and improve API documentation |
| `/postman-security` | Security audit (OWASP API Top 10) |
| `/postman-setup` | First-run Postman MCP configuration |

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/br4vetrave1err/opencode-config.git ~/opencode-config
```

### 2. Copy Configuration to OpenCode

```bash
cp ~/opencode-config/opencode.json ~/.config/opencode/opencode.json
# Edit with real tokens (this repo has placeholders)
```

### 3. Install Skills, Agents, Commands

```bash
cp -r ~/opencode-config/skills/* ~/.config/opencode/skills/
cp -r ~/opencode-config/agents/* ~/.config/opencode/agents/
cp -r ~/opencode-config/commands/* ~/.config/opencode/commands/
```

### 4. Authenticate Remote MCP Servers

```bash
opencode mcp auth postman
opencode mcp auth atlassian
```

### 5. Verify

```bash
opencode mcp list
# Should show 5 servers (3 local + 2 remote)
```

## Environment Variables

```bash
cp .env.example .env
```

```env
CONFLUENCE_BASE_URL=https://your-site.atlassian.net/wiki
CONFLUENCE_USERNAME=your-email@example.com
PAT=your-personal-access-token
GITHUB_TOKEN=your-github-token
```

## Updating

```bash
cd ~/opencode-config
git pull origin main
cp -r skills/* ~/.config/opencode/skills/
cp -r agents/* ~/.config/opencode/agents/
cp -r commands/* ~/.config/opencode/commands/
cp opencode.json ~/.config/opencode/
```

## Obsidian Vault Sync

Design docs are maintained in Obsidian (`agent config/`) and synced to this repo as backup:

```bash
# Manual sync
./scripts/sync-obsidian.sh

# Set up daily sync at 6 AM
./scripts/setup-cron.sh
```

## Changelog

See [docs/design/04-Updates/Changelog.md](docs/design/04-Updates/Changelog.md) for dated change logs.

## Notes

- `opencode.json` in this repo has secrets replaced with `<REDACTED>`
- Create your own `~/.config/opencode/opencode.json` with real tokens
- All skills load from `~/.config/opencode/skills/` (new canonical location)
- Old locations (`~/.agents/skills/`, `~/.claude/skills/`) have been removed
