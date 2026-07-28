# Changelog

## 0.3.0 - Exchange Online live collector preview

### Added
- Optional Exchange Online live collector
- `Connect-EntraShieldExchange`
- `Invoke-EntraShieldAudit -Live -IncludeExchangeOnline`
- Mailbox-level forwarding detection
- External forwarding target detection
- Inbox rule forwarding and redirect detection
- Suspicious inbox rule heuristics
- `-MailboxLimit` for safer lab testing
- `-SkipInboxRules` for faster mailbox-level forwarding checks
- `docs/exchange-online-setup.md`

### Changed
- Live data collector can now include Exchange Online findings when requested
- README updated with Exchange Online live audit commands
- Live tenant setup guide updated with Exchange Online workflow
- Module version updated to 0.3.0

### Notes
- Exchange Online collection is optional and requires `ExchangeOnlineManagement`.
- Run `Connect-EntraShieldExchange` before using `-IncludeExchangeOnline`.
- Do not publish real mailbox reports without sanitization.

## 0.2.0 - Microsoft Graph live collector preview

### Added
- Read-only live Microsoft Graph collection mode
- `Invoke-EntraShieldAudit -Live`
- Live user collector
- Live authentication methods collector
- Live directory roles and members collector
- Live Conditional Access policy collector
- Live domain collector with basic DNS checks
- Live guest user collector
- Authentication method policy posture collector
- `docs/live-tenant-setup.md`
- `-SkipAuthenticationMethods` for partial live audits without `UserAuthenticationMethod.Read.All`
- `-SkipDnsChecks` for live audits without DNS validation
- `-ContinueOnCollectorError` for lab troubleshooting

### Changed
- README updated with live mode instructions and Graph permissions
- Demo mode and live mode are now explicitly separated
- Report generator now includes assessment mode and prepared-by metadata

### Notes
- Current live collectors are read-only.
- Do not publish real tenant reports without sanitization.

## 0.1.0 - MVP / Demo-first release

### Added
- Initial repository structure
- PowerShell module skeleton
- Demo mode sample data
- Finding schema
- Risk scoring model
- Sample HTML report
- Sample Markdown report
- Documentation baseline
- GitHub Actions workflow placeholders

### Notes
- Initial release intended for portfolio demonstration, safe offline testing, and design review.
