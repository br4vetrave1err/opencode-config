---
name: create-rule
description: Create rule files for persistent AI guidance
---

# Create Rule

Create rule files that provide persistent guidance to AI agents across sessions.

## What Are Rules

Rules are markdown files that define persistent instructions, preferences, or conventions that AI agents should follow. Unlike skills (which are triggered by specific situations), rules are always active.

## Rule File Format

```markdown
# Rule Title

## Description
Brief description of what this rule governs.

## Rules
- Rule 1: Specific instruction
- Rule 2: Specific instruction
- Rule 3: Specific instruction

## Examples
Good: Example of correct behavior
Bad: Example of incorrect behavior
```

## Where to Create Rules

- **Project-level:** `.opencode/rules/` in the project root
- **Global:** `~/.config/opencode/rules/`

## Naming Convention

- Use kebab-case: `code-style.md`, `testing-conventions.md`
- Be specific about scope: `redis-key-naming.md`, `api-error-handling.md`

## When to Create Rules

- Team conventions that should always be followed
- Project-specific patterns not covered by existing skills
- Preferences that reduce back-and-forth
- Security requirements

## Workflow

1. Identify the rule's scope and purpose
2. Check if a similar rule already exists
3. Create the rule file with clear, actionable instructions
4. Include examples of correct and incorrect behavior
5. Test by asking the agent to follow the rule
