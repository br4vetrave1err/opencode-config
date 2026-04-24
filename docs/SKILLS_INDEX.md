# Opencode Agent Skills Guide

A comprehensive guide to using agent skills for planning, development, and tooling. Based on mattpocock/skills with custom additions for this project.

## Quick Reference

| Need | Use Skill | When to Use |
|------|-----------|-------------|
| Convert idea to PRD | `to-prd` | After discussing a feature idea |
| Break plan into issues | `to-issues` | After creating a PRD or spec |
| Stress-test a plan | `grill-me` | Before starting major work |
| Design multiple interfaces | `design-it-twice` | When designing new APIs/modules |
| Plan a refactor | `request-refactor-plan` | Before significant refactoring |
| Build with TDD | `tdd` | Building features or fixing bugs |
| Debug a bug | `triage-issue` | When investigating a bug |
| Improve architecture | `improve-codebase-architecture` | When codebase feels complex |
| Set up pre-commit hooks | `setup-pre-commit` | Setting up new project |
| Block dangerous git | `git-guardrails-claude-code` | To prevent destructive git ops |
| Create new skills | `write-a-skill` | When creating custom skills |
| Edit/improve articles | `edit-article` | When improving documentation |
| Extract domain terms | `ubiquitous-language` | In domain-driven projects |
| Manage Obsidian notes | `obsidian-vault` | Searching/creating vault notes |
| Scaffold exercises | `scaffold-exercises` | Creating course material |
| Monitor Docker containers | `docker-monitor` | Debugging container issues |
| Continuous Docker monitor | `continuous-monitor` | Background error monitoring |

---

## Planning & Design

### to-prd
Turn the current conversation context into a Product Requirements Document and submit it as a GitHub issue.

**When to use:** After discussing a feature idea when you have a clear user need but no formal spec.

**Customization:** Uses GitHub MCP to create issues automatically.

---

### to-issues
Break any plan, spec, or PRD into independently-grabbable GitHub issues using vertical slices (tracer bullets).

**When to use:** After you have a PRD when a feature needs to be broken into implementable chunks.

**Customization:** Creates issues with proper labels and milestones via GitHub MCP.

---

### grill-me
Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.

**When to use:** Before starting major work, when there are unresolved assumptions, or to stress-test a design.

---

### design-it-twice
Generate multiple radically different interface designs for a module using parallel sub-agents.

**When to use:** When designing a new API or module, or when you're unsure which approach is best.

**Approaches:** Minimal interface, Maximum flexibility, Optimize for common case, Ports & adapters.

---

### request-refactor-plan
Create a detailed refactor plan with small, safe commits via user interview, then file it as a GitHub issue.

---

### ubiquitous-language
Extract a DDD-style ubiquitous language glossary from the current conversation, flagging ambiguities. Saves to `UBIQUITOUS_LANGUAGE.md`.

---

## Development

### tdd
Test-driven development with red-green-refactor loop. Builds features one vertical slice at a time.

**Workflow:**
```
RED:   Write test → fails
GREEN: Minimal code → passes
REFACTOR: Clean up → tests still pass
```

**Custom Framework Support:**

| Language | Framework |
|----------|-----------|
| Python | pytest |
| TypeScript/JS | Vitest, Jest |
| React + TS | React Testing Library + user-event |

**Python additions:** pytest, Pydantic with `@runtime_checkable` Protocols, Ruff/mypy.

---

### triage-issue
Investigate a bug by exploring the codebase, identify root cause, and create a GitHub issue with a TDD-based fix plan.

---

### improve-codebase-architecture
Explore a codebase for architectural improvement opportunities, focusing on deepening shallow modules.

**Customization:** Added Python/Pydantic patterns for deep modules.

---

### scaffold-exercises
Create exercise directory structures with sections, problems, solutions, and explainers.

**Customization:** Supports both TypeScript (`main.ts`) and Python (`main.py`).

---

## Tooling & Setup

### setup-pre-commit
Set up Husky pre-commit hooks with lint-staged, type checking, and tests.

**Customization - Supported tools:**

| Type | Tools |
|------|-------|
| JS Package Managers | npm, pnpm, yarn |
| Python Package Managers | uv, Poetry |
| Linting | Prettier, Ruff |
| Type Checking | tsc, mypy |
| Testing | Vitest, Jest, pytest |

---

### git-guardrails-claude-code
Set up Claude Code hooks to block dangerous git commands before execution (push, reset --hard, clean, branch -D).

---

## Writing & Knowledge

### write-a-skill
Create new agent skills with proper structure, progressive disclosure, and bundled resources.

---

### edit-article
Edit and improve articles by restructuring sections, improving clarity, and tightening prose.

---

### obsidian-vault
Search, create, and manage notes in an Obsidian vault with wikilinks.

**Vault location:** `/home/br4vetrave1er/Documents/br4vetrave1er notes`

---

## Docker Monitoring (Custom)

### docker-monitor
Monitor Docker containers, analyze logs, and debug issues.

### continuous-monitor
Run persistent background monitor that watches containers and auto-restarts on failure.

**Usage:**
```bash
# Linux
./scripts/monitor.sh /path/to/Makefile up
./scripts/monitor.sh /path/to/Makefile dev &

# Windows
.\scripts\monitor.ps1 -Makefile "C:\path\to\Makefile" -Target up
```

---

## Recommended Workflows

### Feature Implementation
1. `grill-me` - Clarify requirements
2. `design-it-twice` - Explore interface options
3. `to-prd` - Create formal spec
4. `to-issues` - Break into issues
5. `tdd` - Implement one issue at a time

### Bug Fix
1. `triage-issue` - Investigate root cause
2. `tdd` - Write failing test first
3. Implement fix
4. Verify test passes

### Refactor
1. `improve-codebase-architecture` - Find opportunities
2. `request-refactor-plan` - Plan the refactor
3. `tdd` - Implement in small steps