---
name: create-skill
description: Create SKILL.md files with proper frontmatter and structure
---

# Creating Skills

## Process

1. **Create directory** named after the skill (kebab-case)
2. **Create SKILL.md** with frontmatter:
   ```yaml
   ---
   name: my-skill-name
   description: Short description shown in skill picker
   ---
   ```
3. **Write content** with progressive disclosure
4. **Add resources** (scripts, templates) if needed
5. **Test** the skill triggers correctly

## Frontmatter Template

```yaml
---
name: skill-name
description: Brief description of capability. Use when [specific triggers].
---
```

## Rules

- `name` must match directory name exactly
- `description` must be actionable and include trigger conditions
- Keep frontmatter minimal (name + description only)
- Use kebab-case for skill names

## Example

```
skills/my-new-skill/
├── SKILL.md
├── scripts/
│   └── helper.sh
└── templates/
    └── template.md
```
