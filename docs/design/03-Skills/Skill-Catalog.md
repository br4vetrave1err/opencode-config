# Skill Catalog

Complete catalog of all 36 skills organized by source.

---

## Original OpenCode Skills (21)

Moved from `~/.agents/skills/` → `~/.config/opencode/skills/`

| # | Skill | Description |
|---|-------|-------------|
| 1 | `caveman` | Ultra-compressed communication mode, cuts ~75% tokens |
| 2 | `design-an-interface` | Generate multiple interface designs via parallel sub-agents |
| 3 | `domain-model` | Grilling session against domain model, updates CONTEXT.md/ADRs |
| 4 | `edit-article` | Edit and improve articles by restructuring and tightening prose |
| 5 | `find-skills` | Discover and install agent skills from the ecosystem |
| 6 | `git-guardrails-claude-code` | Block dangerous git commands via pre-tool hooks |
| 7 | `github-triage` | Triage GitHub issues via label-based state machine |
| 8 | `grill-me` | Interview user relentlessly about a plan/design |
| 9 | `improve-codebase-architecture` | Find architectural improvement opportunities, deepen shallow modules |
| 10 | `obsidian-vault` | Search, create, and manage Obsidian vault notes |
| 11 | `qa` | Interactive QA session, user reports bugs, agent files GitHub issues |
| 12 | `request-refactor-plan` | Create detailed refactor plan with tiny commits, file as GitHub issue |
| 13 | `scaffold-exercises` | Create exercise directory structures with sections/problems/solutions |
| 14 | `setup-pre-commit` | Set up Husky pre-commit hooks with lint-staged/Prettier |
| 15 | `tdd` | Test-driven development with red-green-refactor loop |
| 16 | `to-issues` | Break a plan/PRD into vertical-slice GitHub issues |
| 17 | `to-prd` | Turn conversation context into a PRD, submit as GitHub issue |
| 18 | `triage-issue` | Triage a bug, find root cause, create GitHub issue with TDD fix plan |
| 19 | `ubiquitous-language` | Extract DDD-style ubiquitous language glossary |
| 20 | `write-a-skill` | Create new agent skills with proper structure |
| 21 | `zoom-out` | Tell agent to zoom out for broader context |

---

## Claude Code Compatibility (1)

Moved from `~/.claude/skills/` → `~/.config/opencode/skills/`

| # | Skill | Description |
|---|-------|-------------|
| 22 | `playwright-cli` | Automate browser interactions, test web pages, work with Playwright tests |

---

## Postman Plugin (3)

From `~/.cursor/plugins/cache/cursor-public/postman/`

| # | Skill | Description |
|---|-------|-------------|
| 23 | `agent-ready-apis` | Knowledge about AI agent API compatibility (8 pillars, 48 checks) |
| 24 | `postman-knowledge` | Postman concepts and MCP tool guidance |
| 25 | `postman-routing` | Auto-route API/Postman requests to correct command |

---

## Atlassian Plugin (5)

From `~/.cursor/plugins/cache/cursor-public/atlassian/`

| # | Skill | Description |
|---|-------|-------------|
| 26 | `capture-tasks-from-meeting-notes` | Extract action items from meeting notes → create Jira tasks |
| 27 | `generate-status-report` | Generate project status reports from Jira → publish to Confluence |
| 28 | `spec-to-backlog` | Convert Confluence specs → structured Jira backlogs with Epics |
| 29 | `search-company-knowledge` | Search across Confluence + Jira for internal company knowledge |
| 30 | `jira-triage-issue` | Triage bug reports, check Jira duplicates, create/link issues |

---

## Cursor Built-in Adapted (6)

From `~/.cursor/skills-cursor/`

| # | Skill | Description |
|---|-------|-------------|
| 31 | `create-rule` | Create rule files for persistent AI guidance |
| 32 | `create-skill` | Create SKILL.md files with proper frontmatter and structure |
| 33 | `create-subagent` | Create custom subagent .md files with system prompts |
| 34 | `opencode-sdk` | Guide for building with OpenCode SDK (`@opencode-ai/sdk`) |
| 35 | `update-opencode-config` | Edit opencode.json/tui.json configuration files |
| 36 | `update-opencode-settings` | Update OpenCode TUI settings (theme, keybinds, scroll) |

---

## Related

- [[03-Skills/Skills-Index|Skills Index]] (quick reference)
- [[03-Skills/Agent-Catalog|Agent Catalog]]
- [[03-Skills/Command-Catalog|Command Catalog]]
