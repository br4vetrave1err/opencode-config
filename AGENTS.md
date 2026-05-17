# Global Rules

These rules apply to all OpenCode sessions.

## Redis Development

Load Redis development rules from consolidated skills directory:

```
~/.config/opencode/skills/redis-development/rules/*.md
```

These rules cover:
- Connection: pooling, blocking, pipelining, timeouts, client cache
- Data: structure selection, transactions, key naming, incr, hash field expiry
- JSON: partial updates, JSON vs Hash comparison
- RAM: limits, TTL management
- RQE: index management, query optimization, field types, dialect, skip initial scan
- Cluster: hash tags, read replicas
- Security: ACLs, auth, network
- Semantic Cache: best practices, LangCache usage
- Streams: choosing patterns
- Vector: algorithm choice, hybrid search, index creation, RAG pattern
- Observability: commands, metrics

## General

- Follow project conventions for code style
- Never commit secrets or tokens
- Use TDD for new features and bug fixes
- Keep commits small and focused
