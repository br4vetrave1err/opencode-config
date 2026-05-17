# Conflict Resolution

## Skill Name Conflicts

### triage-issue

| Source | Description | Resolution |
|--------|-------------|------------|
| Existing (`~/.agents/skills/triage-issue/`) | Triage codebase bugs, find root cause, TDD fix plan | **Keep** as `triage-issue` |
| Atlassian plugin | Triage Jira bugs, check duplicates, create/link issues | **Rename** to `jira-triage-issue` |

**Reason:** Both serve different domains (codebase vs Jira). Keeping both avoids losing functionality.

### grill-me vs domain-model

| Skill | Description | Resolution |
|-------|-------------|------------|
| `grill-me` | Generic plan/design grilling | **Keep** — lightweight, general-purpose |
| `domain-model` | Grilling + CONTEXT.md/ADR management + glossary | **Keep** — extends grill-me with domain awareness |

**Reason:** `domain-model` builds on `grill-me` concept but adds CONTEXT.md/ADR management. Both useful in different contexts.

---

## Cursor Built-in Skills — Skipped

| Skill | Reason | Alternative |
|-------|--------|-------------|
| `canvas` | Cursor-IDE-only UI feature | No equivalent in any agent platform |
| `statusline` | Cursor-IDE-only UI feature | OpenCode TUI has its own status bar |
| `shell` | Already native | OpenCode bash tool |
| `migrate-to-skills` | Cursor-internal migration | Not needed for OpenCode |
| `babysit` | Migrated as agent | `pr-babysitter` subagent |
| `split-to-prs` | Migrated as agent | `split-to-prs` subagent |
| `sdk` | Cursor-specific | `opencode-sdk` (OpenCode's own SDK) |

---

## Model Configuration Decision

**Decision:** No per-agent model override.

**Reason:** User does not have Anthropic subscription. All agents inherit from global OpenCode config (auto-selected via `/connect`).

**Impact:** Simpler config, easier maintenance. If different models are needed later, add `model` field to specific agent configs.

---

## Claude Code Compatibility

**Decision:** Keep enabled (zero cost).

**Reason:** After migration, `~/.claude/skills/` and `~/.agents/skills/` are empty. OpenCode skips empty dirs instantly. Keeping compatibility allows future skills installed to those locations to work without config changes.

**Alternative:** `export OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1` to disable.

---

## Related

- [[02-Migration/Plan|Migration Plan]]
- [[02-Migration/Before-After|Before/After Comparison]]
