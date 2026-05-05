---
name: problem-planner
description: Generates structured implementation plans for autonomous problem-solving. Use when you need to create a step-by-step plan with tools, skills, rollback, and success criteria for a problem.
---

# Problem Planner Skill

This skill generates detailed, executable implementation plans for the autonomous agent.

## Input Format

When invoking this skill, provide:

```
PROBLEM STATEMENT:
{problem_text}

DOMAIN CLASSIFICATION:
- Domain: {domain}
- Subdomain: {subdomain}
- Confidence: {confidence}
- Key Entities: {entities}
- Required Skills: {skills}
- Required Tools: {tools}

DATA FILES:
{files_list}

FORMAT SPECIFICATION:
{format_spec}
```

## Output Format

Generate a JSON plan:

```json
{
  "plan_id": "plan_{timestamp}",
  "title": "Brief title of the plan",
  "domain": "coding|math|physics|writing|data_analysis|general",
  "complexity": "low|medium|high",
  "estimated_duration": "X minutes",
  "steps": [
    {
      "step_id": 1,
      "action": "Brief description of what this step does",
      "tool": "bash|read|write|edit|codesearch|web-search|skill",
      "skill_name": "tdd|edit-article (only if tool is skill)",
      "command": "actual command or file path (if applicable)",
      "inputs": ["file1.txt", "data.csv"],
      "expected_output": "What this step should produce",
      "rollback_on_fail": "How to recover if this step fails",
      "dependencies": [],
      "success_criteria": ["output contains X", "no error in output"]
    }
  ],
  "risks": [
    "Risk description and mitigation"
  ],
  "success_criteria": [
    "all tests pass",
    "output file exists at expected path",
    "validation score >= 80"
  ],
  "fallback_plan": {
    "description": "Alternative approach if primary plan fails",
    "steps": []
  }
}
```

## Planning Guidelines

### Step Design Principles

1. **Atomicity**: Each step should do one thing well
2. **Independent re-execution**: Any step can be re-run on failure
3. **Sequential execution**: Steps run one at a time
4. **Clear outputs**: Each step produces verifiable output
5. **Rollback**: Include rollback for each step

### Tool Selection by Domain

| Domain | Preferred Tools |
|--------|----------------|
| coding | `bash` (for code execution), `read`, `write`, `edit` |
| math | `bash` (python/sympy), `web-search` |
| physics | `bash`, `web-search` |
| writing | `read`, `edit`, `web-search` |
| data_analysis | `bash` (pandas), `read`, `write`, `edit` |

### Domain-Specific Step Patterns

#### Coding Problems

1. **Setup/TDD**: Create test file first, verify it fails
2. **Implementation**: Write code to make tests pass
3. **Verification**: Run tests, check coverage
4. **Edge cases**: Handle error cases

Example:
```json
{
  "step_id": 1,
  "action": "Create test file with TDD approach",
  "tool": "write",
  "inputs": ["problem_statement.md"],
  "expected_output": "tests/test_solve.py exists with failing tests",
  "rollback_on_fail": "Delete test file if incomplete"
}
```

#### Math Problems

1. **Derivation**: Show mathematical steps
2. **Verification**: Use sympy to verify derivation
3. **Computation**: Compute final answer
4. **Unit check**: Verify dimensional consistency

#### Physics Problems

1. **Identify principles**: List applicable physics principles
2. **Formula selection**: Select correct formulas
3. **Computation**: Solve for unknowns
4. **Unit validation**: Check final units

#### Writing Problems

1. **Research**: Use web-search to verify facts
2. **Outline**: Create structure
3. **Draft**: Write content
4. **Review**: Grammar and coherence check

## Plan Validation

Before returning the plan, validate:

1. ✅ Each step has a clear action
2. ✅ Each step's expected output is verifiable
3. ✅ Dependencies are correctly ordered
4. ✅ Rollback exists for critical steps
5. ✅ Success criteria are measurable
6. ✅ Plan covers the entire problem scope

## Iteration with User Feedback

If user provides feedback on plan:
1. Analyze feedback
2. Identify which steps need revision
3. Revise plan
4. Present revised plan

If user requests restart:
1. Acknowledge and pass back to orchestrator for re-classification

## Example Plans

### Simple Coding Plan

```json
{
  "plan_id": "plan_20260101_120000",
  "title": "Implement factorial function with tests",
  "domain": "coding",
  "complexity": "low",
  "estimated_duration": "5 minutes",
  "steps": [
    {
      "step_id": 1,
      "action": "Create test file with failing test for factorial",
      "tool": "write",
      "command": "tests/test_factorial.py",
      "inputs": ["problem.md"],
      "expected_output": "Test file with factorial(5)==120 failing",
      "rollback_on_fail": "rm tests/test_factorial.py",
      "dependencies": [],
      "success_criteria": ["test file exists", "pytest shows 1 failing test"]
    },
    {
      "step_id": 2,
      "action": "Implement factorial function",
      "tool": "write",
      "command": "factorial.py",
      "inputs": ["tests/test_factorial.py"],
      "expected_output": "factorial.py with recursive implementation",
      "rollback_on_fail": "rm factorial.py",
      "dependencies": [1],
      "success_criteria": ["pytest passes"]
    },
    {
      "step_id": 3,
      "action": "Verify all tests pass",
      "tool": "bash",
      "command": "pytest tests/",
      "inputs": ["factorial.py", "tests/test_factorial.py"],
      "expected_output": "All tests passing",
      "rollback_on_fail": "Review error and fix implementation",
      "dependencies": [1, 2],
      "success_criteria": ["exit code 0", "all tests pass"]
    }
  ],
  "risks": ["None for simple factorial"],
  "success_criteria": ["all tests pass", "function handles edge cases"]
}
```

### Math Problem Plan

```json
{
  "plan_id": "plan_20260101_120001",
  "title": "Solve differential equation dy/dx = -ky",
  "domain": "math",
  "complexity": "medium",
  "estimated_duration": "15 minutes",
  "steps": [
    {
      "step_id": 1,
      "action": "Verify analytical solution using sympy",
      "tool": "bash",
      "command": "python verify_solution.py",
      "inputs": ["problem.md"],
      "expected_output": "Solution y = Ce^(-kx) verified",
      "rollback_on_fail": "Check derivation manually",
      "dependencies": [],
      "success_criteria": ["sympy returns True for check"]
    },
    {
      "step_id": 2,
      "action": "Compute solution for given initial condition",
      "tool": "bash",
      "command": "python compute.py",
      "inputs": ["verified_solution.py"],
      "expected_output": "y(2) = computed_value",
      "rollback_on_fail": "Verify computation manually",
      "dependencies": [1],
      "success_criteria": ["value computed", "units correct"]
    }
  ],
  "risks": ["Solution may have integration constant ambiguity"],
  "success_criteria": ["verified via sympy", "dimensionally correct"]
}
```

## Output Instructions

Return the plan in the output format shown above. Include all fields. Make sure:
- Steps are numbered sequentially
- Dependencies reference correct step_ids
- Rollback is actionable
- Success criteria are measurable