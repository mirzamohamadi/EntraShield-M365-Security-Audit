# Before / After Workflow

A strong portfolio story is built around measurable improvement.

## Step 1 - Create a lab tenant

Use a Microsoft 365 Business Premium trial or E5 developer tenant.

## Step 2 - Create intentional weaknesses

Examples:

- Too many Global Administrators
- Admins without phishing-resistant MFA
- SMS authentication enabled
- Missing Conditional Access baseline
- External forwarding rule in a test mailbox
- Weak DMARC policy
- Stale guest users

## Step 3 - Run EntraShield before remediation

```powershell
Invoke-EntraShieldAudit -Live -ContinueOnCollectorError -NoProgress -GenerateRemediationPlan -OutputPath ./reports/before
```

## Step 4 - Apply remediations

Use the generated remediation plan.

## Step 5 - Run EntraShield again

```powershell
Invoke-EntraShieldAudit -Live -ContinueOnCollectorError -NoProgress -GenerateRemediationPlan -OutputPath ./reports/after
```

## Step 6 - Compare results

Example:

```text
Before: 42/100 - High Risk
After:  86/100 - Strong
```

## Step 7 - Share safely

Use sanitized output before sharing:

```powershell
Invoke-EntraShieldAudit -Live -Sanitize -ContinueOnCollectorError -NoProgress -GenerateRemediationPlan -OutputPath ./reports/sanitized-after
```
