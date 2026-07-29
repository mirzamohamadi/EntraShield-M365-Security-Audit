# Command Reference

## Get-EntraShieldVersion

Shows module version and environment information.

```powershell
Get-EntraShieldVersion
```

## Test-EntraShieldEnvironment

Checks local prerequisites.

```powershell
Test-EntraShieldEnvironment | Format-Table -AutoSize
```

## Connect-EntraShield

Connects to Microsoft Graph with read-only delegated scopes.

```powershell
Connect-EntraShield
```

Default scopes:

```text
User.Read.All
Directory.Read.All
RoleManagement.Read.Directory
Policy.Read.All
Domain.Read.All
Reports.Read.All
AuditLog.Read.All
UserAuthenticationMethod.Read.All
```

## Connect-EntraShieldExchange

Connects to Exchange Online PowerShell.

```powershell
Connect-EntraShieldExchange
```

With account:

```powershell
Connect-EntraShieldExchange -UserPrincipalName admin@yourtenant.onmicrosoft.com
```

With device authentication:

```powershell
Connect-EntraShieldExchange -UseDeviceAuthentication
```

## Invoke-EntraShieldAudit

Runs the audit.

### Demo mode

```powershell
Invoke-EntraShieldAudit -DemoMode -OutputPath ./reports/demo
```

### Live Microsoft Graph mode

```powershell
Connect-EntraShield
Invoke-EntraShieldAudit -Live -ContinueOnCollectorError -NoProgress -OutputPath ./reports/live
```

### Live Exchange Online mode

```powershell
Connect-EntraShield
Connect-EntraShieldExchange
Invoke-EntraShieldAudit -Live -IncludeExchangeOnline -MailboxLimit 10 -ContinueOnCollectorError -NoProgress -OutputPath ./reports/live-exchange
```

### Sanitized output

```powershell
Invoke-EntraShieldAudit -DemoMode -Sanitize -OutputPath ./reports/sanitized-demo
```

### Remediation plan

```powershell
Invoke-EntraShieldAudit -DemoMode -GenerateRemediationPlan -OutputPath ./reports/demo-remediation
```

### Sanitized report + remediation plan

```powershell
Invoke-EntraShieldAudit -DemoMode -Sanitize -GenerateRemediationPlan -OutputPath ./reports/sanitized-demo
```

## Main parameters

| Parameter | Description |
|---|---|
| `-DemoMode` | Uses sample data and does not require a tenant. |
| `-Live` | Uses live Microsoft Graph collectors. |
| `-IncludeExchangeOnline` | Includes Exchange Online mailbox forwarding / inbox rule checks. |
| `-SkipAuthenticationMethods` | Skips user authentication method collection. |
| `-SkipDnsChecks` | Skips DNS checks for SPF/DKIM/DMARC. |
| `-SkipInboxRules` | Checks mailbox-level forwarding only and skips inbox rules. |
| `-MailboxLimit` | Limits number of mailboxes inspected by Exchange collector. |
| `-ContinueOnCollectorError` | Continues audit if one collector fails. |
| `-NoProgress` | Suppresses progress bars. |
| `-OpenReport` | Opens generated HTML report automatically. |
| `-Sanitize` | Masks common sensitive values in generated reports. |
| `-GenerateRemediationPlan` | Generates remediation-plan.md and remediation-plan.json. |
| `-OutputPath` | Report output directory. |
| `-PreparedBy` | Custom report prepared-by value. |

## New-EntraShieldRemediationPlan

Generates remediation plan from findings. Normally called by `Invoke-EntraShieldAudit -GenerateRemediationPlan`.

## ConvertTo-EntraShieldSanitizedText

Masks common sensitive values in text.

```powershell
ConvertTo-EntraShieldSanitizedText 'admin@contoso.com signed in from 10.10.10.5'
```
