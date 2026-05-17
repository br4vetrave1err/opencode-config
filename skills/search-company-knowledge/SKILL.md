---
name: search-company-knowledge
description: Search across Confluence and Jira for internal company knowledge
---

# Search Company Knowledge

Search across Confluence and Jira to find internal company knowledge, decisions, and context.

## When to Use

- Before starting work on a feature (check for existing specs)
- When investigating a bug (check for known issues)
- When onboarding to a project (find architecture docs)
- When making a decision (check for prior ADRs)

## Workflow

1. **Understand Query**
   - What is the user looking for?
   - Which system is most likely to have it?
     - Confluence: specs, decisions, meeting notes, documentation
     - Jira: bugs, feature requests, project history

2. **Search Confluence**
   - Use `confluence_search` with relevant CQL
   - Search by title, content, labels
   - Filter by space if known

3. **Search Jira**
   - Use `atlassian_searchJiraIssuesUsingJql` with relevant JQL
   - Search by summary, description, labels
   - Filter by project, status, type if known

4. **Synthesize Results**
   - Group findings by relevance
   - Highlight key decisions, specs, or known issues
   - Provide links to source pages/issues

## Search Strategies

### By Topic
```
Confluence: type=page AND text ~ "topic"
Jira: text ~ "topic" AND project = "PROJ"
```

### By Decision
```
Confluence: type=page AND text ~ "decision" AND text ~ "topic"
Jira: type = Story AND text ~ "ADR" OR text ~ "decision"
```

### By Project
```
Confluence: space = "PROJ" AND text ~ "topic"
Jira: project = "PROJ" AND text ~ "topic"
```

## Output Format

- Summary of findings
- Relevant pages/issues with links
- Key decisions or context extracted
- Gaps (what wasn't found)
