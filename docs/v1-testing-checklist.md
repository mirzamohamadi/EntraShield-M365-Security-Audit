# v1.0.0 Testing Checklist

Use this checklist before publishing or promoting EntraShield publicly.

## Local demo validation

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Remove-Module EntraShield -ErrorAction SilentlyContinue
Import-Module ./src/EntraShield.psm1 -Force
Get-EntraShieldVersion
Test-EntraShieldEnvironment | Format-Table -AutoSize
Invoke-EntraShieldAudit -DemoMode -Sanitize -GenerateRemediationPlan -OutputPath ./reports/sanitized-demo -OpenReport
```

Expected files:

```text
entra-shield-report.html
entra-shield-report.md
entra-shield-findings.json
remediation-plan.md
remediation-plan.json
```

## Pester validation

```powershell
Invoke-Pester -Path ./tests
```

## GitHub Actions validation

- Pull Request should trigger PowerShell Tests.
- Parser check should pass.
- Pester tests should pass.

## Live Graph validation

```powershell
Connect-EntraShield
Invoke-EntraShieldAudit -Live -ContinueOnCollectorError -NoProgress -Sanitize -GenerateRemediationPlan -OutputPath ./reports/sanitized-live
```

## Live Exchange validation

```powershell
Connect-EntraShieldExchange
Invoke-EntraShieldAudit -Live -IncludeExchangeOnline -MailboxLimit 5 -ContinueOnCollectorError -NoProgress -Sanitize -GenerateRemediationPlan -OutputPath ./reports/sanitized-exchange
```

## Safety validation

- No real tenant reports committed.
- No tokens committed.
- No real userPrincipalName values in public samples.
- No real domain screenshots committed.
- Sanitized reports manually reviewed before sharing.

## Release validation

- README updated.
- CHANGELOG updated.
- Module version is 1.0.0.
- Release notes prepared.
- GitHub Pages demo uses sanitized content only.
