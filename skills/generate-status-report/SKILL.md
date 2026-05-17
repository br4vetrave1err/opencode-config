---
name: generate-status-report
description: Generate project status reports from Jira and publish to Confluence
---

# Generate Status Report

Generate a project status report from Jira data and publish it to Confluence.

## Workflow

1. **Gather Data**
   - Query Jira for issues in the reporting period
   - Group by status: Done, In Progress, Blocked, Not Started
   - Calculate velocity and burndown if applicable
   - Identify blockers and risks

2. **Structure Report**
   - Executive summary (1-2 paragraphs)
   - Completed this period
   - In progress
   - Blocked items (with blockers identified)
   - Next period plan
   - Risks and dependencies
   - Metrics (velocity, cycle time, etc.)

3. **Publish to Confluence**
   - Find or create the status report page
   - Format using Confluence storage format
   - Include Jira issue macros where appropriate
   - Set appropriate labels and permissions

4. **Notify**
   - Confirm page created/updated
   - Provide link to the report
   - Suggest distribution list

## Parameters

- Project key(s)
- Reporting period (week, sprint, month)
- Confluence space and parent page
- Include/exclude specific issue types
