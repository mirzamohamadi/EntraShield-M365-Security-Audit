# Exchange Online Live Collector Setup

This guide explains how to use EntraShield's optional Exchange Online live collector.

The collector is read-only and checks for:

- Mailbox-level forwarding
- External forwarding targets
- Inbox rules that forward or redirect messages
- Suspicious inbox rules that delete, mark as read, hide, or act on sensitive keywords

---

## 1. Install Exchange Online PowerShell

```powershell
Install-Module ExchangeOnlineManagement -Scope CurrentUser
```

If the module is already installed, update it:

```powershell
Update-Module ExchangeOnlineManagement
```

---

## 2. Connect to Microsoft Graph First

```powershell
Import-Module ./src/EntraShield.psm1 -Force
Connect-EntraShield
```

This collects tenant, user, role, Conditional Access, domain, guest, and authentication method posture data.

---

## 3. Connect to Exchange Online

```powershell
Connect-EntraShieldExchange
```

Or specify an admin account:

```powershell
Connect-EntraShieldExchange -UserPrincipalName admin@yourtenant.onmicrosoft.com
```

If browser sign-in is difficult, try device authentication:

```powershell
Connect-EntraShieldExchange -UseDeviceAuthentication
```

---

## 4. Run Live Audit With Exchange Online

```powershell
Invoke-EntraShieldAudit -Live -IncludeExchangeOnline -OutputPath ./reports/live-exchange
```

Generated files:

```text
reports/live-exchange/entra-shield-report.html
reports/live-exchange/entra-shield-report.md
reports/live-exchange/entra-shield-findings.json
```

---

## 5. Safer First Test: Limit Mailboxes

For the first test in a lab tenant, limit inspection to a small number of mailboxes:

```powershell
Invoke-EntraShieldAudit -Live -IncludeExchangeOnline -MailboxLimit 5 -OutputPath ./reports/live-exchange-test
```

---

## 6. Mailbox Forwarding Only

If you want to skip inbox rules and only check mailbox-level forwarding:

```powershell
Invoke-EntraShieldAudit -Live -IncludeExchangeOnline -SkipInboxRules -OutputPath ./reports/live-forwarding-only
```

---

## 7. Required Roles / Permissions

The account should have enough Exchange Online permissions to read mailboxes and inbox rules.

Recommended lab/admin roles:

- Exchange Administrator
- Global Reader plus appropriate Exchange read permissions where possible
- Global Administrator in a lab tenant only

For production environments, avoid using Global Administrator. Use least privilege.

---

## 8. What the Collector Looks For

### Mailbox-level forwarding

The collector checks mailbox forwarding settings such as:

- ForwardingSmtpAddress
- ForwardingAddress
- DeliverToMailboxAndForward

External forwarding is flagged as high risk.

### Inbox rules

The collector checks rules with actions such as:

- ForwardTo
- ForwardAsAttachmentTo
- RedirectTo
- DeleteMessage
- MarkAsRead
- MoveToFolder

Rules are treated as more suspicious if they contain sensitive keywords such as:

```text
invoice, payment, wire, bank, mfa, password, security, alert, admin, payroll, credential, verify
```

---

## 9. Lab Testing Ideas

In a test mailbox, create a harmless rule such as:

```text
If subject contains "invoice", mark as read and move to Archive.
```

Or create a forwarding rule to another test mailbox/domain.

Do not use real sensitive data.

---

## 10. Safety Notes

- This collector is read-only.
- Do not publish real mailbox names or forwarding targets in a public repository.
- Sanitize reports before sharing screenshots.
- Test in a lab tenant before running in any production tenant.

---

## 11. Troubleshooting

### Error: Exchange Online cmdlets are not available

Run:

```powershell
Install-Module ExchangeOnlineManagement -Scope CurrentUser
Connect-EntraShieldExchange
```

### Error: Access denied for mailbox rules

Use an account with sufficient Exchange Online permissions, preferably in a lab tenant.

### Audit takes too long

Use:

```powershell
Invoke-EntraShieldAudit -Live -IncludeExchangeOnline -MailboxLimit 5
```

or:

```powershell
Invoke-EntraShieldAudit -Live -IncludeExchangeOnline -SkipInboxRules
```
