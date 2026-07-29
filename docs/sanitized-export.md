# Sanitized Export

Sanitized export helps create shareable reports without exposing real tenant data.

## Generate a sanitized demo report

```powershell
Invoke-EntraShieldAudit -DemoMode -Sanitize -GenerateRemediationPlan -OutputPath ./reports/sanitized-demo
```

## Generate a sanitized live report

```powershell
Connect-EntraShield
Invoke-EntraShieldAudit -Live -Sanitize -ContinueOnCollectorError -NoProgress -GenerateRemediationPlan -OutputPath ./reports/sanitized-live
```

## What gets sanitized?

EntraShield masks common sensitive values in report text:

- Email addresses and UPNs
- GUIDs / object IDs / tenant IDs
- IPv4 addresses
- Common domain references
- Tenant name in report summary

Examples:

```text
admin@contoso.com -> user@example.com
11111111-2222-3333-4444-555555555555 -> 00000000-0000-0000-0000-000000000000
10.10.10.5 -> x.x.x.x
contoso.com -> tenant-domain.example
```

## What does not get sanitized?

- Reference URLs are preserved.
- Static documentation content is not modified.
- Screenshots must still be reviewed manually.

## Recommendation

Always manually review sanitized reports before sharing them publicly.
