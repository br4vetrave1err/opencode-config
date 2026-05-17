# Execution Checklist

## Phase 1: MCP Servers

- [ ] Add Postman MCP to `opencode.json` (remote, OAuth 2.1)
- [ ] Add Atlassian MCP to `opencode.json` (remote, OAuth 2.1 PKCE)
- [ ] Authenticate Postman: `opencode mcp auth postman`
- [ ] Authenticate Atlassian: `opencode mcp auth atlassian`
- [ ] Verify: `opencode mcp list`

## Phase 2: Agents

- [ ] Create `~/.config/opencode/agents/` directory
- [ ] Create `readiness-analyzer.md` (from Cursor subagent)
- [ ] Create `pr-babysitter.md` (from Cursor babysit skill)
- [ ] Create `split-to-prs.md` (from Cursor split-to-prs skill)
- [ ] Add agent configs to `opencode.json`

## Phase 3: Commands

- [ ] Create `~/.config/opencode/commands/` directory
- [ ] Create `postman-codegen.md`
- [ ] Create `postman-docs.md`
- [ ] Create `postman-mock.md`
- [ ] Create `postman-search.md`
- [ ] Create `postman-security.md`
- [ ] Create `postman-setup.md`
- [ ] Create `postman-sync.md`
- [ ] Create `postman-test.md`

## Phase 4: Skills Consolidation

### Move Existing (22)

- [ ] Move 21 skills from `~/.agents/skills/` → `~/.config/opencode/skills/`
- [ ] Move 1 skill from `~/.claude/skills/` → `~/.config/opencode/skills/`

### Create New from Plugins (8)

- [ ] Create `agent-ready-apis/SKILL.md`
- [ ] Create `postman-knowledge/SKILL.md`
- [ ] Create `postman-routing/SKILL.md`
- [ ] Create `capture-tasks-from-meeting-notes/SKILL.md`
- [ ] Create `generate-status-report/SKILL.md`
- [ ] Create `spec-to-backlog/SKILL.md`
- [ ] Create `search-company-knowledge/SKILL.md`
- [ ] Create `jira-triage-issue/SKILL.md`

### Create New from Cursor Built-in (6)

- [ ] Create `create-rule/SKILL.md`
- [ ] Create `create-skill/SKILL.md`
- [ ] Create `create-subagent/SKILL.md`
- [ ] Create `opencode-sdk/SKILL.md`
- [ ] Create `update-opencode-config/SKILL.md`
- [ ] Create `update-opencode-settings/SKILL.md`

## Phase 5: Config Update

- [x] Update `~/.config/opencode/opencode.json`:
  - [x] Add Postman MCP
  - [x] Add Atlassian MCP
  - [x] Add Redis rules to `instructions` (now in `skills/redis-development/rules/*.md`)
  - [x] Add skill permissions
  - [x] Add custom agent configs

## Phase 8: Redis Skill

- [x] Copy `redis-development` from Cursor plugin cache to `~/.config/opencode/skills/redis-development/`
- [x] Update instructions glob to point to new location
- [x] Sync to git repo (sanitized)
- [x] 37 rule files across 11 categories

## Phase 6: Verification

- [ ] `opencode mcp list` — verify 5 MCP servers
- [ ] `opencode mcp auth atlassian` — complete OAuth
- [ ] `opencode debug config` — verify skills discovered
- [ ] `opencode agent list` — verify 8 agents
- [ ] Test `/postman-setup` command
- [ ] Test `@readiness-analyzer` agent

## Phase 7: Cleanup

- [ ] Remove `~/.agents/skills/` (after confirming all moved)
- [ ] Remove `~/.claude/skills/` (after confirming all moved)
- [ ] Update this checklist with completion date

---

## Related

- [[02-Migration/Plan|Migration Plan]]
- [[04-Updates/Changelog|Changelog]]
