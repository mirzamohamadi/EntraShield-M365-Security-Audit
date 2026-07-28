# Live Tenant Setup Guide

This guide explains how to test EntraShield against a real Microsoft 365 / Microsoft Entra ID tenant in read-only mode.

> Recommended lab: Microsoft 365 Business Premium trial or Microsoft 365 E5 developer/test tenant.

---

## 1. Create a Test Tenant

For a realistic lab, use one of these options:

### Option A: Microsoft 365 Business Premium Trial

Best practical option for this project because it includes Microsoft Entra ID P1 and Conditional Access.

### Option B: Microsoft 365 E5 Developer Tenant

Best if you qualify through the Microsoft 365 Developer Program.

### Option C: Existing Non-Production Tenant

Use only if you have permission and can safely grant read-only Graph permissions.

---

## 2. Prepare Test Users

Create 8-15 test users, for example:

```text
alice.finance@yourtenant.onmicrosoft.com
bob.itadmin@yourtenant.onmicrosoft.com
charlie.hr@yourtenant.onmicrosoft.com
security.admin@yourtenant.onmicrosoft.com
global.admin1@yourtenant.onmicrosoft.com
global.admin2@yourtenant.onmicrosoft.com
breakglass01@yourtenant.onmicrosoft.com
breakglass02@yourtenant.onmicrosoft.com
nomfa.user@yourtenant.onmicrosoft.com
```

Assign licenses to users that need mailbox or authentication testing.

---

## 3. Create Intentional Test Conditions

To validate findings, intentionally create a few weak conditions in the lab tenant:

- Multiple Global Administrators
- One or more admin accounts without FIDO2/passkey
- SMS authentication enabled for some users
- One user with no MFA-capable method
- Conditional Access policy for admin MFA enabled
- Legacy authentication block policy disabled or report-only
- No phishing-resistant MFA policy for admins
- Guest users with old sign-in activity
- Domain with weak or missing DMARC if using a custom domain

Do not use real sensitive data in the lab.

---

## 4. Install PowerShell Dependencies

Install PowerShell 7 if needed:

```text
https://learn.microsoft.com/powershell/scripting/install/installing-powershell
```

Install Microsoft Graph PowerShell SDK:

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

Optional dependency for Exchange Online live collection:

```powershell
Install-Module ExchangeOnlineManagement -Scope CurrentUser
```

---

## 5. Required Microsoft Graph Permissions

EntraShield live mode uses delegated Microsoft Graph permissions.

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

### Why these permissions?

| Permission | Purpose |
|---|---|
| User.Read.All | Read users |
| Directory.Read.All | Read directory objects and tenant metadata |
| RoleManagement.Read.Directory | Read directory roles and privileged assignments |
| Policy.Read.All | Read Conditional Access and authentication policies |
| Domain.Read.All | Read verified domains |
| Reports.Read.All | Read reporting-related information where available |
| AuditLog.Read.All | Read sign-in activity when available |
| UserAuthenticationMethod.Read.All | Read user MFA and authentication method registrations |

Admin consent may be required.

---

## 6. Connect to Microsoft Graph

From the repository root:

```powershell
Import-Module ./src/EntraShield.psm1 -Force
Connect-EntraShield
```

A browser sign-in window opens. Sign in with an administrator account that can consent to the required read-only permissions.

---

## 7. Run a Live Audit

```powershell
Invoke-EntraShieldAudit -Live -OutputPath ./reports/live
```

Generated files:

```text
reports/live/entra-shield-report.html
reports/live/entra-shield-report.md
reports/live/entra-shield-findings.json
```

---

## 8. Run a Live Audit With Exchange Online

Exchange Online collection is optional. First connect to Exchange Online:

```powershell
Connect-EntraShieldExchange
```

Then run:

```powershell
Invoke-EntraShieldAudit -Live -IncludeExchangeOnline -OutputPath ./reports/live-exchange
```

For a small first test:

```powershell
Invoke-EntraShieldAudit -Live -IncludeExchangeOnline -MailboxLimit 5 -OutputPath ./reports/live-exchange-test
```

To skip inbox rules and check only mailbox-level forwarding:

```powershell
Invoke-EntraShieldAudit -Live -IncludeExchangeOnline -SkipInboxRules -OutputPath ./reports/live-forwarding-only
```

For details, see:

```text
docs/exchange-online-setup.md
```

---

## 9. Run a Partial Audit Without Authentication Methods

If you cannot grant `UserAuthenticationMethod.Read.All` yet:

```powershell
Invoke-EntraShieldAudit -Live -SkipAuthenticationMethods -OutputPath ./reports/live-partial
```

This will still collect users, roles, Conditional Access policies, domains, and guests, but MFA/FIDO2 findings will be incomplete.

---

## 10. DNS Checks

Domain checks attempt to detect:

- SPF TXT records
- DMARC TXT records
- Microsoft 365 DKIM selector CNAME records

If DNS tools are not available or you want to skip DNS checks:

```powershell
Invoke-EntraShieldAudit -Live -SkipDnsChecks -OutputPath ./reports/live-no-dns
```

---

## 11. Before / After Portfolio Scenario

For a strong portfolio story:

1. Run EntraShield against the intentionally weak lab tenant.
2. Save the first report as `before`.
3. Fix the findings:
   - Enable FIDO2/passkeys
   - Reduce Global Admins
   - Add Conditional Access policies
   - Remove SMS from admin accounts
   - Clean stale guests
   - Improve DMARC
4. Run EntraShield again.
5. Save the second report as `after`.
6. Publish a LinkedIn post showing the improvement.

Example:

```text
Before: 45/100 - High Risk
After:  86/100 - Strong
```

---

## 12. Safety Notes

- Run only in a lab or tenant where you have permission.
- The current live collectors are read-only.
- Do not commit real tenant reports to a public repository.
- Sanitize screenshots before publishing.
- Do not upload tenant IDs, real usernames, real domains, IP addresses, or mailbox data to GitHub.

---

## 13. Troubleshooting

### Error: Microsoft Graph PowerShell SDK is not installed

Run:

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

### Error: Insufficient privileges

You may need admin consent for Graph permissions, especially:

```text
UserAuthenticationMethod.Read.All
Policy.Read.All
Directory.Read.All
```

### Authentication methods collection fails

Run partial mode:

```powershell
Invoke-EntraShieldAudit -Live -SkipAuthenticationMethods
```

Then ask a Global Administrator to consent to `UserAuthenticationMethod.Read.All`.

### Conditional Access collection fails

Conditional Access requires Microsoft Entra ID P1 licensing and appropriate permissions.

---

## References

- Microsoft Graph PowerShell SDK: https://learn.microsoft.com/powershell/microsoftgraph/installation
- Microsoft Graph permissions reference: https://learn.microsoft.com/graph/permissions-reference
- Conditional Access deployment planning: https://learn.microsoft.com/en-us/entra/identity/conditional-access/plan-conditional-access
- Microsoft Entra passwordless deployment planning: https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-deploy-phishing-resistant-passwordless-authentication
