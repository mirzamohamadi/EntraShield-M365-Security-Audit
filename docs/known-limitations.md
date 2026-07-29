# Known Limitations

EntraShield is a security audit helper, not a complete compliance platform.

## Current limitations

- Live collectors require Microsoft Graph permissions and admin consent.
- Conditional Access parsing is heuristic-based and does not fully evaluate every policy condition.
- FIDO2/passkey readiness is based on available Graph authentication method and policy data.
- Exchange Online collector requires ExchangeOnlineManagement and appropriate Exchange permissions.
- DNS checks depend on local DNS tooling and public DNS availability.
- Inbox rule suspiciousness is heuristic-based and should be reviewed manually.
- The score is a prioritization metric, not a certification or compliance guarantee.
- Real tenant reports may contain sensitive information and must be sanitized before sharing.

## Recommended usage

1. Run first in demo mode.
2. Run against a lab tenant.
3. Validate findings manually.
4. Use before/after reporting to track hardening work.
5. Do not run against production tenants without explicit authorization.

## Planned improvements

- Better Conditional Access policy analysis
- More structured Exchange Online findings
- GitHub Pages demo report
- Remediation plan generation
- Sanitized report export mode
- Stronger Pester coverage
