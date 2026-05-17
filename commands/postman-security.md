---
description: "Security audit against OWASP API Top 10"
agent: build
---

# Postman Security

Audit API for security vulnerabilities against OWASP API Security Top 10.

## Workflow

1. **Select Collection or Spec**
   - List available collections
   - Ask user which to audit

2. **Run OWASP Checks**
   For each of the OWASP API Top 10:

   - **API1: Broken Object Level Authorization**
     - Check for IDOR vulnerabilities
     - Verify resource access controls

   - **API2: Broken Authentication**
     - Check authentication mechanisms
     - Verify token handling

   - **API3: Broken Object Property Level Authorization**
     - Check for mass assignment
     - Verify property-level access controls

   - **API4: Unrestricted Resource Consumption**
     - Check rate limiting
     - Verify pagination and size limits

   - **API5: Broken Function Level Authorization**
     - Check admin endpoint protection
     - Verify role-based access

   - **API6: Unrestricted Access to Sensitive Business Flows**
     - Check for abuse prevention
     - Verify business logic protections

   - **API7: Server Side Request Forgery**
     - Check URL parameter handling
     - Verify input validation

   - **API8: Security Misconfiguration**
     - Check CORS settings
     - Verify error handling (no stack traces)

   - **API9: Improper Inventory Management**
     - Check for deprecated endpoints
     - Verify API versioning

   - **API10: Unsafe Consumption of APIs**
     - Check third-party API handling
     - Verify trust boundaries

3. **Report Findings**
   - Severity rating for each finding (Critical, High, Medium, Low)
   - Description of vulnerability
   - Affected endpoints
   - Remediation recommendations
   - References to OWASP documentation

4. **Prioritize Fixes**
   - Sort by severity
   - Provide actionable fix steps
   - Estimate effort for each fix

## Output

- Security score
- Findings by severity
- Detailed remediation plan
- OWASP reference links
