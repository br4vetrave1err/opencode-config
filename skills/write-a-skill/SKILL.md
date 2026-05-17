---
name: write-a-skill
description: Create new agent skills with proper structure, progressive disclosure, and bundled resources. Use when user wants to create, write, or build a new skill.
---

# Writing Skills

## Process

1. **Gather requirements** - ask user about:
   - What capability the skill provides
   - When it should be triggered
   - What files/resources it needs

2. **Create SKILL.md** with frontmatter:
   ```yaml
   ---
   name: skill-name
   description: Brief description of capability. Use when [specific triggers].
   ---
   ```

3. **Progressive disclosure** - structure content:
   - Quick start (1-2 sentences)
   - When to use (bullet list)
   - Step-by-step workflow
   - Examples with code blocks
   - Edge cases and gotchas

4. **Bundle resources** - if the skill needs:
   - Scripts → place in `scripts/` subdirectory
   - Templates → place in `templates/` subdirectory
   - References → place in `references/` subdirectory

5. **Test the skill** - verify:
   - Frontmatter name matches directory
   - Description is clear and actionable
   - Triggers are specific (not vague)
   - Examples are complete and runnable

## Example Structure

```
skills/my-skill/
├── SKILL.md           ← Main skill definition
├── scripts/           ← Optional helper scripts
│   └── helper.sh
├── templates/         ← Optional templates
│   └── template.md
└── references/        ← Optional reference docs
    └── api-docs.md
```

## Frontmatter Rules

- `name` must match directory name exactly
- `description` must start with action verb
- Include trigger conditions ("Use when...")
- Keep description under 200 characters

## Common Mistakes

- Vague descriptions ("Helps with stuff")
- Missing trigger conditions
- Name doesn't match directory
- No progressive disclosure (wall of text)
- Examples not runnable
