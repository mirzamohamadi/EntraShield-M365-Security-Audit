# Remediation Plan

EntraShield can generate a remediation plan from audit findings.

## Generate remediation output

```powershell
Invoke-EntraShieldAudit -DemoMode -GenerateRemediationPlan -OutputPath ./reports/demo-remediation
```

This creates:

```text
remediation-plan.md
remediation-plan.json
```

## Live example

```powershell
Connect-EntraShield
Invoke-EntraShieldAudit -Live -ContinueOnCollectorError -NoProgress -GenerateRemediationPlan -OutputPath ./reports/live
```

## Remediation phases

Findings are grouped into practical remediation phases:

| Severity | Phase |
|---|---|
| Critical | Phase 1 - First 7 days |
| High | Phase 2 - Next 30 days |
| Medium | Phase 3 - 60 days |
| Low | Backlog / Continuous improvement |

## Important note

The remediation plan is guidance, not an automatic change engine. Review every recommendation before applying changes to a tenant.
