---
name: jira-triage-issue
description: Triage bug reports, check Jira duplicates, create or link issues
---

# Jira Triage Issue

Triage bug reports by checking for duplicates in Jira, investigating root cause, and creating or linking issues.

## Workflow

1. **Understand the Bug**
   - What is the reported behavior?
   - What is the expected behavior?
   - What are the reproduction steps?
   - Which component/service is affected?

2. **Search for Duplicates**
   - Search Jira for similar issues using keywords
   - Check recently closed issues (may have been fixed)
   - Check known bugs backlog
   - If duplicate found: link to existing issue, inform user

3. **Investigate Root Cause**
   - Search codebase for relevant code
   - Check recent changes that may have introduced the bug
   - Identify the root cause

4. **Create Issue**
   - If no duplicate, create a new Jira issue
   - Include: clear summary, description, reproduction steps, expected vs actual behavior
   - Set appropriate priority, labels, component
   - Link to related issues if applicable

5. **Propose Fix Plan**
   - Outline the fix approach
   - Estimate complexity
   - Suggest test strategy

## Input

- Bug report from user (description, steps, screenshots)
- Optionally: codebase context, recent changes

## Output

- Duplicate check result
- New issue link (if created) or existing issue link (if duplicate)
- Root cause analysis
- Fix recommendation
