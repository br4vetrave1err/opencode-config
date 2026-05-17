---
name: capture-tasks-from-meeting-notes
description: Extract action items from meeting notes and create Jira tasks
---

# Capture Tasks from Meeting Notes

Extract action items from meeting notes and create structured Jira tasks.

## Workflow

1. **Parse Meeting Notes**
   - Read the meeting notes provided by the user
   - Identify action items (tasks assigned to people with deadlines)
   - Extract context: project, priority, dependencies

2. **Structure Tasks**
   For each action item, extract:
   - Summary (concise title)
   - Description (full context from notes)
   - Assignee (if mentioned)
   - Due date (if mentioned)
   - Priority (High/Medium/Low based on context)
   - Labels (project, meeting date, etc.)

3. **Create Jira Issues**
   - Use the Atlassian MCP to create issues
   - Set appropriate issue type (Task, Story, Bug)
   - Link to epic if applicable
   - Add meeting notes as description

4. **Confirm**
   - List all created issues with links
   - Confirm assignees and due dates
   - Flag any items that need clarification

## Input Format

User provides meeting notes as text. Can include:
- Raw transcript
- Structured notes with action items
- Bullet points with assignments

## Output

- Summary of extracted action items
- List of created Jira issues with links
- Any items that need clarification
