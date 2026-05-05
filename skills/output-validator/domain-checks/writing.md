# Writing Domain Validation Rules

## Validation Criteria

Output is validated against these writing-specific checks:

### 1. Grammar and Style
- [ ] No grammatical errors
- [ ] Consistent tense throughout
- [ ] Punctuation is correct

### 2. Coherence and Structure
- [ ] Clear logical flow
- [ ] Proper paragraph organization
- [ ] Transitions are smooth

### 3. Factual Accuracy
- [ ] Claims can be verified via web search
- [ ] No misinformation
- [ ] Citations are correct (if required)

### 4. Completeness
- [ ] All required sections present
- [ ] Requirements from format spec met
- [ ] No placeholder content

## Validation Commands

```bash
# Grammar check with language tool or similar
npx languagetool-cli text.md

# Readability score
# - Flesch-Kincaid: target score
# - Gunning Fog: target score

# Word count verification
wc -w text.md  # Should match required
```

## Scoring

| Check | Weight |
|-------|--------|
| Grammar correct | 25 |
| Coherent structure | 25 |
| Facts verified | 25 |
| Complete | 25 |

**Pass threshold**: Score >= 80

## Common Issues

- Grammar: Run through grammar checker
- Facts not verified: Validate claims via web search
- Missing sections: Review format spec
- Incomplete: Ensure all requirements addressed