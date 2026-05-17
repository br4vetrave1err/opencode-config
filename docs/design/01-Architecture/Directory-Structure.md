# Directory Structure

```
~/.config/opencode/
│
├── opencode.json                    ← Main config (MCP, agents, instructions, permissions)
├── tui.json                         ← TUI-specific settings (theme, keybinds)
├── AGENTS.md                        ← Global rules/instructions
│
├── agents/                          ← Custom agents (subagents)
│   ├── readiness-analyzer.md        ← API agent-readiness analysis (8 pillars, 48 checks)
│   ├── pr-babysitter.md             ← PR merge-readiness (conflicts, comments, CI)
│   └── split-to-prs.md              ← Split large changes into multiple PRs
│
├── commands/                        ← Custom commands (triggered with /)
│   ├── postman-codegen.md           ← Generate typed client code
│   ├── postman-docs.md              ← Analyze/improve API docs
│   ├── postman-mock.md              ← Create mock servers
│   ├── postman-search.md            ← Discover APIs
│   ├── postman-security.md          ← OWASP security audit
│   ├── postman-setup.md             ← First-run Postman MCP setup
│   ├── postman-sync.md              ← Sync collections ↔ code
│   └── postman-test.md              ← Run collection tests
│
├── skills/                          ← All 36 skills
│   │
│   ├── # Original (moved from ~/.agents/skills/)
│   ├── caveman/                     ← Ultra-compressed communication
│   ├── design-an-interface/         ← Multiple interface designs
│   ├── domain-model/                ← Domain model grilling
│   ├── edit-article/                ← Article editing
│   ├── find-skills/                 ← Discover/install skills
│   ├── git-guardrails-claude-code/  ← Block dangerous git
│   ├── github-triage/               ← GitHub issue triage
│   ├── grill-me/                    ← Plan stress-testing
│   ├── improve-codebase-architecture/ ← Architecture improvement
│   ├── obsidian-vault/              ← Obsidian note management
│   ├── qa/                          ← Interactive QA → GitHub issues
│   ├── request-refactor-plan/       ← Refactor planning
│   ├── scaffold-exercises/          ← Exercise scaffolding
│   ├── setup-pre-commit/            ← Pre-commit hooks
│   ├── tdd/                         ← Test-driven development
│   ├── to-issues/                   ← Plan → GitHub issues
│   ├── to-prd/                      ← Context → PRD
│   ├── triage-issue/                ← Bug triage (codebase)
│   ├── ubiquitous-language/         ← DDD glossary extraction
│   ├── write-a-skill/               ← Create new skills
│   ├── zoom-out/                    ← Broader context
│   │
│   ├── # From Claude Code compatibility
│   ├── playwright-cli/              ← Browser automation
│   │
│   ├── # From Postman plugin
│   ├── agent-ready-apis/            ← API agent-readiness knowledge
│   ├── postman-knowledge/           ← Postman MCP guidance
│   ├── postman-routing/             ← Auto-route API requests
│   │
│   ├── # From Atlassian plugin
│   ├── capture-tasks-from-meeting-notes/ ← Meeting notes → Jira tasks
│   ├── generate-status-report/      ← Jira → Confluence reports
│   ├── spec-to-backlog/             ← Confluence spec → Jira backlog
│   ├── search-company-knowledge/    ← Search Jira + Confluence
│   ├── jira-triage-issue/           ← Jira bug triage (renamed)
│   │
│   └── # From Cursor built-in (adapted)
│       ├── create-rule/             ← Create rule files
│       ├── create-skill/            ← Create skill files
│       ├── create-subagent/         ← Create agent files
│       ├── opencode-sdk/            ← OpenCode SDK guidance
│       ├── update-opencode-config/  ← Edit opencode.json
│       └── update-opencode-settings/ ← Edit tui.json
│
├── package.json                     ← npm package (for local MCP servers)
├── package-lock.json                ← npm lockfile
└── node_modules/                    ← npm dependencies
```

---

## Skill Discovery

OpenCode searches for skills in these locations (walks up from CWD to git root):

| Location | Pattern | Scope |
|----------|---------|-------|
| Project | `.opencode/skills/<name>/SKILL.md` | Current project |
| Global | `~/.config/opencode/skills/<name>/SKILL.md` | All projects |
| Claude compat | `.claude/skills/<name>/SKILL.md` | Project-level |
| Claude compat | `~/.claude/skills/<name>/SKILL.md` | Global |
| Agent compat | `.agents/skills/<name>/SKILL.md` | Project-level |
| Agent compat | `~/.agents/skills/<name>/SKILL.md` | Global |

**After migration:** All skills live in `~/.config/opencode/skills/`. The old locations (`~/.agents/skills/`, `~/.claude/skills/`) are cleaned up.

---

## Related

- [[01-Architecture/System-Overview|System Overview]]
- [[01-Architecture/Skill-Discovery|Skill Discovery]]
