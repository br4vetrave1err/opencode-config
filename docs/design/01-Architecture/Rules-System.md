# Rules System

## Rule Sources (Precedence)

| Order | Source | Path |
|-------|--------|------|
| 1 | Local | `<project>/AGENTS.md` |
| 2 | Local (Claude compat) | `<project>/CLAUDE.md` |
| 3 | Global | `~/.config/opencode/AGENTS.md` |
| 4 | Global (Claude compat) | `~/.claude/CLAUDE.md` |
| 5 | Instructions | `opencode.json` → `instructions` array |

The first matching file wins in each category.

---

## Custom Instructions

Specify additional instruction files in `opencode.json`:

```json
{
  "instructions": [
    "CONTRIBUTING.md",
    "docs/guidelines.md",
    ".cursor/rules/*.md",
    "~/.cursor/plugins/cache/cursor-public/redis-development/*/rules/*.md"
  ]
}
```

### Our Instructions

```json
{
  "instructions": [
    "~/.cursor/plugins/cache/cursor-public/redis-development/*/rules/*.md"
  ]
}
```

This loads 30+ Redis development rules covering:
- **Connection:** pooling, blocking, pipelining, timeouts, client cache
- **Data:** structure selection, transactions, key naming, incr, hash field expiry
- **JSON:** partial updates, JSON vs Hash comparison
- **RAM:** limits, TTL management
- **RQE:** index management, query optimization, field types, dialect
- **Cluster:** hash tags, read replicas
- **Security:** ACLs, auth, network
- **Semantic Cache:** best practices, LangCache usage
- **Streams:** choosing patterns
- **Vector:** algorithm choice, hybrid search, index creation, RAG pattern
- **Observability:** commands, metrics

### Remote Instructions

```json
{
  "instructions": [
    "https://raw.githubusercontent.com/my-org/shared-rules/main/style.md"
  ]
}
```

Remote instructions are fetched with a 5 second timeout.

---

## Referencing External Files in AGENTS.md

```markdown
# Project Rules

## External File Loading
CRITICAL: When you encounter a file reference (e.g., @rules/general.md),
use your Read tool to load it on a need-to-know basis.

## Development Guidelines
For TypeScript code style: @docs/typescript-guidelines.md
For React patterns: @docs/react-patterns.md
For API standards: @docs/api-standards.md
```

---

## Related

- [[01-Architecture/System-Overview|System Overview]]
- [[05-Reference/Opencode-Agent-Config-Project|Project Details]]
