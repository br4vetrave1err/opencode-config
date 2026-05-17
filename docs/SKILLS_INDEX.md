# Opencode Agent Skills Guide

Comprehensive guide to all 41 agent skills. Updated 2026-05-17.

## Quick Reference

| Need | Use Skill | Category |
|------|-----------|----------|
| Convert idea to PRD | `to-prd` | Planning |
| Break plan into issues | `to-issues` | Planning |
| Stress-test a plan | `grill-me` | Planning |
| Design multiple interfaces | `design-an-interface` | Planning |
| Plan a refactor | `request-refactor-plan` | Planning |
| Build with TDD | `tdd` | Development |
| Debug a bug (codebase) | `triage-issue` | Development |
| Debug a bug (Jira) | `jira-triage-issue` | Project Mgmt |
| Improve architecture | `improve-codebase-architecture` | Development |
| Sync API ↔ Postman | `/postman-sync` (command) | API |
| Run API tests | `/postman-test` (command) | API |
| Extract action items from meetings | `capture-tasks-from-meeting-notes` | Project Mgmt |
| Generate status report → Confluence | `generate-status-report` | Project Mgmt |
| Convert Confluence spec → Jira | `spec-to-backlog` | Project Mgmt |
| Search company knowledge | `search-company-knowledge` | Project Mgmt |
| Set up pre-commit hooks | `setup-pre-commit` | Tooling |
| Block dangerous git | `git-guardrails-claude-code` | Tooling |
| Create new skills | `write-a-skill` / `create-skill` | Tooling |
| Edit/improve articles | `edit-article` | Writing |
| Manage Obsidian notes | `obsidian-vault` | Knowledge |

---

## Planning & Design (8)

### to-prd
Turn conversation context into a PRD, submit as GitHub issue.

### to-issues
Break a plan/PRD into vertical-slice GitHub issues.

### grill-me
Relentlessly interview user about a plan/design until all decisions resolved.

### design-an-interface
Generate multiple interface designs via parallel sub-agents.

### request-refactor-plan
Create detailed refactor plan with tiny commits, file as GitHub issue.

### domain-model
Grilling session against domain model, updates CONTEXT.md/ADRs.

### ubiquitous-language
Extract DDD-style ubiquitous language glossary.

### zoom-out
Tell agent to zoom out for broader context.

---

## Development (7)

### tdd
Test-driven development with red-green-refactor loop. Supports Python (pytest), TypeScript/JS (Vitest/Jest), React (RTL + user-event).

### triage-issue
Investigate codebase bugs, find root cause, create GitHub issue with TDD fix plan.

### improve-codebase-architecture
Find architectural improvement opportunities, deepen shallow modules.

### qa
Interactive QA session, user reports bugs, agent files GitHub issues.

### scaffold-exercises
Create exercise directory structures with sections, problems, solutions.

### playwright-cli
Automate browser interactions, test web pages, work with Playwright tests.

### caveman
Ultra-compressed communication mode, cuts ~75% tokens.

---

## API & Postman (6)

### agent-ready-apis
Knowledge about AI agent API compatibility (8 pillars, 48 checks). Use with `readiness-analyzer` agent.

### postman-knowledge
Postman concepts and MCP tool guidance. Reference for all Postman MCP tools.

### postman-routing
Auto-route API/Postman requests to the correct command or skill.

### /postman-sync (command)
Sync Postman collections with local API code. Detects OpenAPI specs, creates/updates collections.

### /postman-codegen (command)
Generate typed client code from Postman collections. Matches project conventions.

### /postman-search (command)
Discover APIs across Postman workspaces using natural language.

### /postman-test (command)
Run collection tests, diagnose failures, suggest fixes.

### /postman-mock (command)
Create Postman mock servers from collections or API specs.

### /postman-docs (command)
Analyze and improve API documentation completeness.

### /postman-security (command)
Security audit against OWASP API Top 10.

### /postman-setup (command)
First-run Postman MCP configuration guide.

---

## Project Management (5)

### capture-tasks-from-meeting-notes
Extract action items from meeting notes → create Jira tasks.

### generate-status-report
Generate project status reports from Jira → publish to Confluence.

### spec-to-backlog
Convert Confluence specs → structured Jira backlogs with Epics.

### search-company-knowledge
Search across Confluence + Jira for internal company knowledge.

### jira-triage-issue
Triage bug reports, check Jira duplicates, create or link issues.

---

## Tooling & Setup (6)

### setup-pre-commit
Set up Husky pre-commit hooks with lint-staged, Prettier, type checking, tests. Supports npm/pnpm/yarn, uv/Poetry, Ruff, mypy.

### git-guardrails-claude-code
Block dangerous git commands (push, reset --hard, clean, branch -D) via pre-tool hooks.

### write-a-skill / create-skill
Create new agent skills with proper structure, progressive disclosure, bundled resources.

### create-rule
Create rule files for persistent AI guidance across sessions.

### create-subagent
Create custom subagent .md files with system prompts and permissions.

### update-opencode-config
Edit opencode.json and tui.json configuration files safely.

### update-opencode-settings
Update OpenCode TUI settings (theme, keybinds, scroll, display).

### opencode-sdk
Guide for building with OpenCode SDK (`@opencode-ai/sdk`).

---

## Writing & Knowledge (4)

### edit-article
Edit and improve articles by restructuring, improving clarity, tightening prose.

### obsidian-vault
Search, create, and manage Obsidian vault notes with wikilinks.

### find-skills
Discover and install agent skills from the ecosystem.

### github-triage
Triage GitHub issues via label-based state machine with interactive grilling.

---

## Custom (5)

### autonomous-agent
Autonomous agent operations with logging, sandboxing, and drive operations.

### continuous-monitor
Persistent background Docker monitor that auto-restarts containers on failure.

### docker-monitor
Docker container debugging, log analysis, and health checks.

### output-validator
Output validation with domain-specific checks (coding, math, physics, writing).

### problem-planner
Problem planning and decomposition into actionable steps.

---

## Recommended Workflows

### Feature Implementation
1. `grill-me` → Clarify requirements
2. `design-an-interface` → Explore options
3. `to-prd` → Create formal spec
4. `to-issues` → Break into issues
5. `tdd` → Implement one issue at a time

### API Development (Postman)
1. `/postman-setup` → Connect Postman
2. Write API code locally
3. `/postman-sync` → Push to Postman
4. `/postman-docs` → Generate docs
5. `/postman-mock` → Create mock server
6. `/postman-test` → Run tests
7. `/postman-security` → Security audit
8. `/postman-codegen` → Generate client SDK

### Bug Fix
1. `triage-issue` (codebase) or `jira-triage-issue` (Jira)
2. `tdd` → Write failing test first
3. Implement fix
4. Verify test passes

### Meeting → Action Items
1. `capture-tasks-from-meeting-notes` → Extract → create Jira tasks
2. `generate-status-report` → Weekly status → publish to Confluence

### Spec → Implementation
1. `spec-to-backlog` → Confluence spec → Jira backlog with Epics
2. `search-company-knowledge` → Find related internal docs
