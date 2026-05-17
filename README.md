# Opencode Agent Configuration

Consolidated AI agent configuration for OpenCode. All skills, agents, commands, and MCP servers managed under `~/.config/opencode/`.

## Structure

```
opencode-config/
├── opencode.json          # MCP (5 servers), agents (3), permissions
├── skills/                # 41 skills total
│   ├── agent-ready-apis/      # Postman: API agent-readiness
│   ├── postman-knowledge/     # Postman: MCP tool guidance
│   ├── postman-routing/       # Postman: Auto-routing
│   ├── capture-tasks-from-meeting-notes/  # Atlassian: Meeting → Jira
│   ├── generate-status-report/            # Atlassian: Jira → Confluence
│   ├── spec-to-backlog/                   # Atlassian: Confluence → Jira
│   ├── search-company-knowledge/          # Atlassian: Cross-system search
│   ├── jira-triage-issue/                 # Atlassian: Bug triage
│   ├── create-rule/                       # Cursor-adapted: Rule creation
│   ├── create-skill/                      # Cursor-adapted: Skill creation
│   ├── create-subagent/                   # Cursor-adapted: Agent creation
│   ├── opencode-sdk/                      # Cursor-adapted: SDK guide
│   ├── update-opencode-config/            # Cursor-adapted: Config editing
│   ├── update-opencode-settings/          # Cursor-adapted: TUI settings
│   ├── autonomous-agent/                  # Custom: Autonomous operations
│   ├── continuous-monitor/                # Custom: Docker monitoring
│   ├── docker-monitor/                    # Custom: Container debugging
│   ├── output-validator/                  # Custom: Output validation
│   ├── problem-planner/                   # Custom: Problem decomposition
│   └── [22 original skills...]
├── agents/                # 3 custom subagents
│   ├── readiness-analyzer.md  # API agent-readiness scanner
│   ├── pr-babysitter.md       # PR merge-readiness loop
│   └── split-to-prs.md        # Split changes into PRs
├── commands/              # 8 Postman workflow commands
│   ├── postman-sync.md
│   ├── postman-codegen.md
│   ├── postman-search.md
│   ├── postman-test.md
│   ├── postman-mock.md
│   ├── postman-docs.md
│   ├── postman-security.md
│   └── postman-setup.md
├── scripts/               # Automation scripts
│   ├── sync-obsidian.sh       # Linux sync
│   ├── sync-obsidian.ps1      # Windows sync
│   ├── setup-cron.sh          # Linux scheduler
│   ├── setup-task-scheduler.ps1 # Windows scheduler
│   ├── monitor.sh             # Docker monitor (Linux)
│   └── monitor.ps1            # Docker monitor (Windows)
├── docs/
│   ├── SKILLS_INDEX.md        # Skills guide
│   └── updates/               # Dated changelog
└── README.md
```

## MCP Servers

| Server | Type | Auth | Status |
|--------|------|------|--------|
| confluence | local | PAT | ✅ Active |
| obsidian | local | None | ✅ Active |
| github | local | Token | ✅ Active |
| postman | remote | OAuth 2.1 | ⬜ Pending auth |
| atlassian | remote | OAuth 2.1 (PKCE) | ⬜ Pending auth |

## Skills Overview

41 skills across 5 categories:

| Category | Count | Examples |
|----------|-------|----------|
| Planning & Design | 8 | to-prd, to-issues, grill-me, design-an-interface |
| Development | 7 | tdd, triage-issue, improve-codebase-architecture |
| API & Postman | 6 | postman-sync, postman-codegen, agent-ready-apis |
| Project Management | 5 | capture-tasks-from-meeting-notes, generate-status-report |
| Tooling & Knowledge | 15 | obsidian-vault, write-a-skill, caveman |

See [docs/SKILLS_INDEX.md](docs/SKILLS_INDEX.md) for full catalog.

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

### 3. Install Skills

```bash
cp -r ~/opencode-config/skills/* ~/.config/opencode/skills/
```

### 4. Install Agents

```bash
cp -r ~/opencode-config/agents/* ~/.config/opencode/agents/
```

### 5. Install Commands

```bash
cp -r ~/opencode-config/commands/* ~/.config/opencode/commands/
```

### 6. Authenticate Remote MCP Servers

```bash
opencode mcp auth postman
opencode mcp auth atlassian
```

### 7. Verify

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

## Changelog

See [docs/updates/](docs/updates/) for dated change logs.

## Notes

- `opencode.json` in this repo has secrets replaced with `<REDACTED>`
- Create your own `~/.config/opencode/opencode.json` with real tokens
- All skills load from `~/.config/opencode/skills/` (new canonical location)
- Old locations (`~/.agents/skills/`, `~/.claude/skills/`) have been removed
