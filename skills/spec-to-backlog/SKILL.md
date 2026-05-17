---
name: spec-to-backlog
description: Convert Confluence specs into structured Jira backlogs with Epics
---

# Spec to Backlog

Convert a Confluence specification document into a structured Jira backlog with Epics, Stories, and Tasks.

## Workflow

1. **Read Spec**
   - Fetch the Confluence page containing the spec
   - Parse sections, requirements, and acceptance criteria
   - Identify functional and non-functional requirements

2. **Decompose**
   - Group requirements into Epics (major feature areas)
   - Break Epics into Stories (user-facing functionality)
   - Break Stories into Tasks (implementation steps)
   - Identify dependencies between items

3. **Structure**
   For each item, define:
   - Summary (clear, actionable title)
   - Description (context + acceptance criteria)
   - Issue type (Epic, Story, Task)
   - Priority (based on spec ordering)
   - Story points (if estimable from spec)
   - Labels (project, component, etc.)

4. **Create in Jira**
   - Create Epics first
   - Create Stories linked to Epics
   - Create Tasks linked to Stories
   - Set up issue links for dependencies

5. **Verify**
   - List all created issues
   - Confirm hierarchy is correct
   - Provide backlog summary

## Input

- Confluence page URL or title + space key
- Target Jira project
- Optional: existing epic to add stories to
