# Math Domain Validation Rules

## Validation Criteria

Output is validated against these math-specific checks:

### 1. Derivation Verification
- [ ] Mathematical steps are shown
- [ ] Derivation can be verified independently
- [ ] No logical leaps in the proof

### 2. Computation Verification
- [ ] Final answer is numerically correct
- [ ] Computations verified via independent method (e.g., sympy)
- [ ] No arithmetic errors

### 3. Dimensional Analysis
- [ ] Units are consistent throughout
- [ ] Final answer has correct units
- [ ] Unit conversions are accurate

### 4. Formula Application
- [ ] Correct formulas are applied
- [ ] Formulas are applied in the right context
- [ ] No formula misuse

## Validation Commands

```python
# Sympy verification
from sympy import *
x = Symbol('x')
# Verify derivative
diff(sin(x), x) == cos(x)

# Verify integral
integrate(exp(-x), (x, 0, oo)) == 1

# Numerical verification
abs(actual - expected) < tolerance
```

## Scoring

| Check | Weight |
|-------|--------|
| Derivation verified | 30 |
| Computation correct | 25 |
| Units consistent | 25 |
| Formula correct | 20 |

**Pass threshold**: Score >= 80

## Common Issues

- Wrong formula: Review problem and select appropriate formula
- Unit mismatch: Check each step's units
- Arithmetic error: Verify with independent calculation
- Missing steps: Show all derivation steps