# Conditional Access Baseline

A practical Microsoft Entra Conditional Access baseline should include policies that reduce common identity attack paths.

## Suggested Baseline Policies

1. Block legacy authentication.
2. Require MFA for privileged roles.
3. Require phishing-resistant MFA for admin portals.
4. Require MFA for all users.
5. Block or challenge risky sign-ins.
6. Require compliant device for privileged access where possible.
7. Exclude and monitor emergency access accounts.
8. Restrict access from unknown or high-risk locations when appropriate.

## Deployment Advice

- Start in report-only mode.
- Exclude emergency access accounts carefully.
- Validate impact before enforcement.
- Use named locations and device compliance thoughtfully.
- Avoid creating lockout scenarios.

Reference: https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview
