# EntraShield

![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-blue)
![Platform](https://img.shields.io/badge/Platform-Microsoft%20365%20%7C%20Entra%20ID-2563eb)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Release-v1.0.0-success)

**Find identity security gaps before attackers do.**

EntraShield is an open-source Microsoft 365 and Microsoft Entra ID Zero Trust security audit toolkit focused on MFA, FIDO2/passkeys, privileged access, Conditional Access, Exchange Online exposure, guest access, domain email security, remediation planning, and sanitized reporting.

> Current status: **v1.0.0 stable public release**  
> EntraShield supports demo mode, read-only Microsoft Graph live collection, optional Exchange Online forwarding / inbox rule inspection, category-based scoring, collector status tracking, remediation plan generation, sanitized export, GitHub Pages demo assets, environment checks, example scripts, and Pester-based test scaffolding.

---

## Why EntraShield?

Identity is now one of the most attacked layers in enterprise environments. Many incidents begin with compromised credentials, weak MFA, over-privileged admin roles, legacy authentication, mailbox forwarding after compromise, stale guest users, or weak domain email authentication.

EntraShield helps administrators and security teams answer questions like:

- Are privileged users protected with phishing-resistant MFA?
- Is SMS still used as a primary or fallback authentication method?
- Are FIDO2/passkeys enabled and adopted?
- Are Conditional Access policies aligned with a Zero Trust baseline?
- Are there too many Global Administrators?
- Are mailbox forwarding rules exposing data?
- Are guest accounts stale or unmanaged?
- Are SPF, DKIM, and DMARC configured correctly?
- Can we generate a remediation plan and sanitized report safely?

---

## Sample Report Preview

![EntraShield sample dashboard](reports/screenshots/sample-dashboard.svg)

Open the full sample output:

- [Sample HTML report](reports/sample-report.html)
- [Sample Markdown report](reports/sample-report.md)
- [GitHub Pages demo entry](docs/index.html)

---

## Key Features

- Demo mode with safe sample data
- Read-only Microsoft Graph live collection
- Optional Exchange Online mailbox forwarding and inbox rule inspection
- MFA and authentication methods audit
- FIDO2 / passkey readiness assessment
- Privileged role review
- Conditional Access baseline validation
- Guest user and external access review
- SPF, DKIM, and DMARC domain email security checks
- Category-based scoring model
- Collector status tracking
- HTML, Markdown, and JSON reporting
- Remediation plan generation
- Sanitized export for safe sharing
- Environment validation command
- Local helper scripts
- Pester test scaffolding
- GitHub Actions parser and test workflow
- GitHub Pages-ready demo assets

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

Demo mode does not require a Microsoft tenant.

If PowerShell blocks local scripts, run this for the current session:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

Import the module and run a demo audit:

```powershell
Import-Module ./src/EntraShield.psm1 -Force
Invoke-EntraShieldAudit -DemoMode -OutputPath ./reports/demo -OpenReport
```

Generate a sanitized demo report and remediation plan:

```powershell
Invoke-EntraShieldAudit -DemoMode -Sanitize -GenerateRemediationPlan -OutputPath ./reports/sanitized-demo -OpenReport
```

Run a local environment check:

```powershell
Test-EntraShieldEnvironment | Format-Table -AutoSize
```

Or use the helper script:

```powershell
./tools/Test-EntraShieldLocal.ps1
```

---

## Live Microsoft Graph Audit

Install dependencies:

```powershell
./tools/Install-EntraShieldPrerequisites.ps1
```

Connect and run a safer live audit:

```powershell
Import-Module ./src/EntraShield.psm1 -Force
Connect-EntraShield
Invoke-EntraShieldAudit -Live -ContinueOnCollectorError -NoProgress -OutputPath ./reports/live -OpenReport
```

If you cannot grant authentication method permissions yet:

```powershell
Invoke-EntraShieldAudit -Live -SkipAuthenticationMethods -ContinueOnCollectorError -NoProgress -OutputPath ./reports/live-partial
```

---

## Live Microsoft Graph + Exchange Online Audit

Install dependencies:

```powershell
./tools/Install-EntraShieldPrerequisites.ps1 -IncludeExchangeOnline
```

Run Exchange Online checks with a mailbox limit for the first test:

```powershell
Import-Module ./src/EntraShield.psm1 -Force
Connect-EntraShield
Connect-EntraShieldExchange
Invoke-EntraShieldAudit -Live -IncludeExchangeOnline -MailboxLimit 10 -ContinueOnCollectorError -NoProgress -OutputPath ./reports/live-exchange -OpenReport
```

Forwarding-only mode:

```powershell
Invoke-EntraShieldAudit -Live -IncludeExchangeOnline -SkipInboxRules -ContinueOnCollectorError -NoProgress -OutputPath ./reports/live-forwarding-only
```

---

## Remediation Plan

Generate a remediation plan from findings:

```powershell
Invoke-EntraShieldAudit -DemoMode -GenerateRemediationPlan -OutputPath ./reports/demo-remediation
```

Outputs:

```text
remediation-plan.md
remediation-plan.json
```

Remediation phases:

| Severity | Phase |
|---|---|
| Critical | Phase 1 - First 7 days |
| High | Phase 2 - Next 30 days |
| Medium | Phase 3 - 60 days |
| Low | Backlog / Continuous improvement |

---

## Sanitized Export

Use sanitized output before sharing reports publicly:

```powershell
Invoke-EntraShieldAudit -Live -Sanitize -ContinueOnCollectorError -NoProgress -GenerateRemediationPlan -OutputPath ./reports/sanitized-live
```

Sanitization masks common sensitive values such as:

- Email addresses and UPNs
- GUIDs / object IDs / tenant IDs
- IPv4 addresses
- Common domain references
- Tenant name in report summary

Always manually review sanitized reports before publishing.

---

## Testing

Run Pester tests locally:

```powershell
Install-Module Pester -Scope CurrentUser -Force -SkipPublisherCheck
Invoke-Pester -Path ./tests
```

Run the local helper:

```powershell
./tools/Test-EntraShieldLocal.ps1
```

GitHub Actions also runs parser checks and Pester tests.

---

## Documentation

- Installation: `docs/installation.md`
- Command reference: `docs/command-reference.md`
- v1 testing checklist: `docs/v1-testing-checklist.md`
- Live tenant setup: `docs/live-tenant-setup.md`
- Exchange Online setup: `docs/exchange-online-setup.md`
- Scoring model: `docs/scoring-model.md`
- Remediation plan: `docs/remediation.md`
- Sanitized export: `docs/sanitized-export.md`
- GitHub Pages demo: `docs/github-pages.md`
- Before / after workflow: `docs/before-after-workflow.md`
- Testing: `docs/testing.md`
- Known limitations: `docs/known-limitations.md`
- Release process: `docs/release-process.md`
- Threat model: `docs/threat-model.md`
- Examples: `examples/README.md`

---

## Security Philosophy

EntraShield follows a **read-only first** model.

The project should never modify tenant configuration by default. Any future remediation functionality should require explicit opt-in and safe preview behavior.

Do not commit:

- Real tenant reports
- Access tokens
- Exported Graph data
- Customer data
- Screenshots with real identities or domains

Use `-Sanitize` before sharing reports.

---

## Known Limitations

EntraShield is a security audit helper, not a full compliance platform.

Current limitations include:

- Conditional Access analysis is heuristic-based.
- Inbox rule suspiciousness is heuristic-based and requires manual review.
- DNS checks depend on local DNS tooling and public DNS availability.
- Live collectors require appropriate Microsoft Graph / Exchange permissions.
- The score is a prioritization metric, not a certification.

See `docs/known-limitations.md` for details.

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

## Release Status

### v1.0.0

- [x] Demo mode
- [x] Microsoft Graph live mode
- [x] Optional Exchange Online live mode
- [x] Category-based scoring
- [x] Collector status tracking
- [x] HTML, Markdown, and JSON reports
- [x] Remediation plan generation
- [x] Sanitized export
- [x] GitHub Pages demo assets
- [x] Pester test scaffolding
- [x] GitHub Actions workflow
- [x] Documentation set
- [x] Security policy and templates

---

## License

MIT License. See [LICENSE](LICENSE).
