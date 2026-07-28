# EntraShield

**Find identity security gaps before attackers do.**

EntraShield is an open-source Microsoft 365 and Microsoft Entra ID security audit toolkit focused on Zero Trust, MFA, phishing-resistant authentication, privileged access, Conditional Access, Exchange Online exposure, guest access, and domain email security.

The project is designed for Microsoft 365 administrators, cloud engineers, security analysts, and MSP teams who want a practical way to review common identity security weaknesses and produce a clean executive-style report.

> Current status: **v0.2.0 MVP / Microsoft Graph live collector preview**  
> The project supports demo mode and a read-only live mode for Microsoft Graph collection. Live collection currently covers users, authentication methods, directory roles, Conditional Access policies, domains, guest users, and authentication method policy posture.

---

## Why EntraShield?

Identity is now one of the most attacked layers in enterprise environments. Many breaches start with a compromised mailbox, a phished MFA prompt, an over-privileged admin account, weak recovery process, legacy authentication, or a forgotten guest user.

EntraShield helps answer questions like:

- Are privileged users protected with phishing-resistant MFA?
- Is SMS still used as a primary or fallback authentication method?
- Are FIDO2/passkeys enabled and adopted?
- Are Conditional Access policies aligned with a Zero Trust baseline?
- Are there too many Global Administrators?
- Are guest accounts stale or unmanaged?
- Are SPF, DKIM, and DMARC configured correctly?
- Are there suspicious external forwarding rules in Exchange Online?

---

## Sample Report Preview

![EntraShield sample dashboard](reports/screenshots/sample-dashboard.svg)

Open the full sample output:

- [Sample HTML report](reports/sample-report.html)
- [Sample Markdown report](reports/sample-report.md)

---

## Key Features

- MFA and authentication methods audit
- FIDO2 / passkey readiness assessment
- Privileged role review
- Conditional Access baseline validation
- Legacy authentication exposure check
- Exchange Online forwarding and inbox rule review
- Guest user and external access review
- SPF, DKIM, and DMARC domain security check
- Risk-based scoring model
- HTML, Markdown, and JSON reporting
- Demo mode with sample data
- Read-only first approach for safe auditing

---

## Current Audit Categories

| Category | What it checks |
|---|---|
| Authentication | MFA registration, SMS usage, weak methods, phishing-resistant methods |
| FIDO2 Readiness | FIDO2/passkey policy, admin adoption, Temporary Access Pass readiness, authentication strength |
| Privileged Access | Global Admin count, inactive admins, emergency accounts, excessive standing privilege |
| Conditional Access | Legacy auth blocking, admin MFA, phishing-resistant MFA, risky sign-ins, compliant devices |
| Exchange Security | External forwarding, suspicious inbox rules, mailbox exposure indicators |
| Guest Access | Stale guest users, old external accounts, unmanaged collaboration risk |
| Domain Email Security | SPF, DKIM, and DMARC posture |

---

## Quick Start: Demo Mode

Demo mode does not require a Microsoft tenant. It uses sample JSON data stored in `tests/sample-data`.

```powershell
Import-Module ./src/EntraShield.psm1 -Force
Invoke-EntraShieldAudit -DemoMode -OutputPath ./reports
```

This generates:

```text
reports/entra-shield-report.html
reports/entra-shield-report.md
reports/entra-shield-findings.json
```

---

## Live Tenant Mode: Microsoft Graph Read-Only Preview

Live tenant mode uses Microsoft Graph in a read-only manner. It currently collects:

- Users
- Authentication methods
- Directory roles and members
- Conditional Access policies
- Domains and basic DNS email security posture
- Guest users
- Authentication method policy posture

Recommended Microsoft Graph delegated permissions:

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

Install dependencies:

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

Run a live read-only audit:

```powershell
Import-Module ./src/EntraShield.psm1 -Force
Connect-EntraShield
Invoke-EntraShieldAudit -Live -OutputPath ./reports/live
```

If you do not have permission to read authentication methods yet, you can run a partial live audit:

```powershell
Invoke-EntraShieldAudit -Live -SkipAuthenticationMethods -OutputPath ./reports/live-partial
```

For detailed setup, see:

```text
docs/live-tenant-setup.md
```

> Note: Exchange Online live forwarding collection is planned for a later milestone. Current live mode keeps ExchangeForwarding empty unless sample/demo data is used.

---

## Example Finding

```text
Finding ID: ES-MFA-001
Title: Privileged users without phishing-resistant MFA
Severity: Critical
Category: Authentication
Impact: A compromised privileged account may lead to full tenant takeover.
Recommendation: Require FIDO2 security keys, passkeys, certificate-based authentication, or Windows Hello for Business for privileged roles.
```

---

## Scoring Model

EntraShield calculates a score from 0 to 100.

| Score | Rating |
|---|---|
| 85-100 | Strong |
| 70-84 | Good |
| 50-69 | Needs Improvement |
| 0-49 | High Risk |

Current scoring categories:

```text
Authentication Security: 25 points
Privileged Access:      20 points
Conditional Access:     20 points
Exchange Security:      15 points
Guest Access:           10 points
Domain Email Security:  10 points
```

---

## Suggested Deployment Roadmap

1. Start with demo mode and review the sample report.
2. Add Microsoft Graph live collectors.
3. Test in a non-production Microsoft 365 tenant.
4. Validate findings manually.
5. Add MSP-style reporting and customer branding.
6. Add remediation templates with `-WhatIf` only.

---

## Security Philosophy

EntraShield follows a **read-only first** model.

The project should never modify tenant configuration by default. Any future remediation functionality should require explicit flags such as:

```powershell
Invoke-EntraShieldRemediation -Finding ES-MFA-001 -WhatIf
```

No secrets, tokens, tenant IDs, or customer data should be committed to the repository.

---

## References

- NIST Digital Identity Guidelines SP 800-63B: https://pages.nist.gov/800-63-4/sp800-63b.html
- CISA: Implementing Phishing-Resistant MFA: https://www.cisa.gov/sites/default/files/publications/fact-sheet-implementing-phishing-resistant-mfa-508c.pdf
- FIDO Alliance FIDO2: https://fidoalliance.org/fido2/
- FIDO Alliance Passkeys: https://fidoalliance.org/passkeys/
- Microsoft Entra passwordless deployment planning: https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-deploy-phishing-resistant-passwordless-authentication
- Microsoft Conditional Access: https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview
- OWASP Authentication Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html

---

## Roadmap

### v0.1.0

- [x] Repository structure
- [x] Demo mode data model
- [x] Sample findings
- [x] HTML and Markdown sample report
- [x] PowerShell module skeleton
- [x] Documentation baseline

### v0.2.0

- [x] Microsoft Graph user collector
- [x] Authentication methods collector
- [x] Directory roles collector
- [x] Conditional Access collector
- [x] Domain collector with basic DNS checks
- [x] Guest user collector
- [x] Live vs demo mode separation
- [x] Live tenant setup documentation
- [ ] Expanded test coverage with Pester

### v0.3.0

- [ ] Exchange Online live collector
- [ ] SPF/DKIM/DMARC DNS resolver
- [ ] FIDO2/passkey readiness expansion
- [ ] Pester tests

### v1.0.0

- [ ] Production-ready read-only audit
- [ ] MSP report mode
- [ ] GitHub Pages demo
- [ ] Installation script
- [ ] Full documentation

---

## Hashtags / Topics

`Microsoft365` `MicrosoftEntra` `CyberSecurity` `ZeroTrust` `PowerShell` `FIDO2` `Passkeys` `Passwordless` `MFA` `CloudSecurity` `IAM` `IdentitySecurity`

---

## License

MIT License. See [LICENSE](LICENSE).
