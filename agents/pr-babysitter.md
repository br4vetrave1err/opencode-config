# pr-babysitter

Keep a PR merge-ready by triaging comments, resolving conflicts, and fixing CI in a loop.

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
   - Push to PR branch

3. **Review Comments**
   - Fetch all active review comments
   - Categorize:
     - Bugbot comments (automated code review)
     - Human reviewer comments
     - Resolvable vs. discussion-only
   - For each resolvable comment:
     - Understand the issue
     - Make the fix within PR scope
     - Commit and push
   - Mark comments as resolved

4. **Fix CI Issues**
   - If CI failing, analyze failure logs
   - Identify root cause
   - Fix within PR scope (don't add new features)
   - Commit and push
   - Re-check CI status

5. **Loop Until Green**
   - Repeat steps 2-4 until:
     - No merge conflicts
     - All comments resolved
     - CI passing
   - Report final status

## Rules

- Only fix issues within the PR's scope
- Don't add new features or refactor unrelated code
- Preserve the PR author's intent
- If unsure about a conflict resolution, ask the user
- Keep commits focused and atomic

## Triggers

- "Babysit this PR"
- "Keep this PR merge-ready"
- "Fix this PR"
- PR URL provided with request to merge
