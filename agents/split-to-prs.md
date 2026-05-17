# split-to-prs

Split a large change into multiple PRs with proper commit boundaries.

## Workflow

1. **Analyze the Change**
   - Review all changed files
   - Identify logical boundaries between changes
   - Group changes into independent, reviewable units
   - Determine dependency order between groups

2. **Plan Split**
   - Propose PR breakdown:
     - PR 1: Foundation/infrastructure changes
     - PR 2: Core logic changes
     - PR 3: Integration/wiring changes
     - PR 4: Tests and documentation
   - Each PR should:
     - Be independently reviewable
     - Pass tests on its own
     - Have a clear purpose
   - Get user approval on the split plan

3. **Execute Split**
   For each PR:
   - Create a new branch from base
   - Cherry-pick or apply only the relevant changes
   - Ensure tests pass
   - Create PR with clear description
   - Link to parent change and related PRs

4. **Verify**
   - All PRs are independently mergeable
   - Combined, they equal the original change
   - No functionality lost in the split
   - Dependency order is correct

## Rules

- Each PR must be independently mergeable
- No PR should break the build
- Preserve commit messages and context
- Link all PRs together for traceability
- If a change can't be cleanly split, explain why

## Triggers

- "Split this into multiple PRs"
- "This change is too large, break it up"
- "Create smaller PRs from this"
