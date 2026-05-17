---
name: create-skill
description: Create SKILL.md files with proper frontmatter and structure
---

# Create Skill

Create new skill files with proper frontmatter and structure for OpenCode agents.

## Skill File Format

Skills are defined in `SKILL.md` files with YAML frontmatter:

```markdown
---
name: my-skill-name
description: Short description shown in skill picker
---

# Skill Title

When to use this skill. Clear trigger conditions.

## Workflow

Step-by-step instructions for the agent.

## Examples

Concrete examples of using this skill.

## Resources

References to scripts, templates, or other files.
```

## Where to Create Skills

- **Project-level:** `.opencode/skills/<skill-name>/SKILL.md`
- **Global:** `~/.config/opencode/skills/<skill-name>/SKILL.md`

## Naming Convention

- Directory: kebab-case (`my-skill-name`)
- File: always `SKILL.md`
- Name in frontmatter: matches directory name

## Skill Design Principles

1. **Single purpose**: One skill does one thing well
2. **Clear triggers**: When should the agent use this?
3. **Actionable steps**: Numbered workflows the agent can follow
4. **Progressive disclosure**: Start simple, add detail as needed
5. **Self-contained**: Include all context the agent needs

## Workflow

1. Define the skill's purpose and triggers
2. Check if an existing skill covers this
3. Create directory: `~/.config/opencode/skills/<name>/`
4. Create `SKILL.md` with frontmatter and content
5. Test by triggering the skill in a session

## Related Files

Skills can include additional files in their directory:
- Scripts: `scripts/`
- Templates: `templates/`
- References: `references/`
