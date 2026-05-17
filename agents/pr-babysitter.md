---
name: pr-babysitter
description: Keep a PR merge-ready by triaging comments, resolving conflicts, and fixing CI in a loop.
---

# pr-babysitter

**Description:** Keep a PR merge-ready by triaging comments, resolving conflicts, and fixing CI in a loop.

## Workflow

1. **Check PR Status**
   - Fetch PR details and current state
   - Check for merge conflicts
   - Check CI status (passing/failing/pending)
   - List active review comments

2. **Resolve Merge Conflicts**
   - If conflicts exist, fetch base branch
   - Merge base into PR branch
   - Resolve conflicts intelligently:
     - Keep PR changes where they don't conflict
     - Keep base changes where PR has no changes
     - For true conflicts, analyze both sides and choose the correct resolution
   - Commit resolved conflicts

3. **Triage Comments**
   - Categorize comments: blocking vs non-blocking
   - Resolve addressed comments
   - Flag unresolved blocking comments

4. **Fix CI**
   - Analyze failing CI logs
   - Identify root cause
   - Apply fixes iteratively
   - Re-run CI until passing

5. **Final Check**
   - All comments resolved or addressed
   - CI passing
   - No merge conflicts
   - PR is ready to merge

## When to Use

- PR has merge conflicts
- CI is failing
- Review comments need triaging
- PR is close to merge-ready but needs final polish

## Permissions

- `bash`: allow (for git operations)
- `read`: allow (for reading files)
- `glob`: allow (for finding files)
- `grep`: allow (for searching code)
