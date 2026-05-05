# Physics Domain Validation Rules

## Validation Criteria

Output is validated against these physics-specific checks:

### 1. Unit Consistency
- [ ] All quantities have consistent units
- [ ] Unit conversions are correct
- [ ] Final answer has correct SI units

### 2. Formula Correctness
- [ ] Correct physics formulas applied
- [ ] Formulas are appropriate for the system
- [ ] No formula misuse or incorrect application

### 3. Physical Reasoning
- [ ] Assumptions are stated and reasonable
- [ ] Physics principles correctly applied
- [ ] Results are physically meaningful

### 4. Numerical Accuracy
- [ ] Calculations are correct
- [ ] No order-of-magnitude errors
- [ ] Precision appropriate for the problem

## Validation Commands

```python
# Unit verification using pint or sympy.physics.units
from sympy.physics.units import *

# Check consistency
convert_to(meter * kilogram / second**2, SI.get_unit_system())

# Numerical magnitude check
1e-15 < quantity < 1e15  # Reasonable physical range
```

## Scoring

| Check | Weight |
|-------|--------|
| Units consistent | 30 |
| Formulas correct | 25 |
| Physical reasoning | 25 |
| Numerical accuracy | 20 |

**Pass threshold**: Score >= 80

## Common Issues

- Unit confusion: Use SI units consistently
- Wrong formula: Verify formula applies to your system
- Missing conversion: Check all unit conversions
- Order of magnitude: Re-estimate expected scale