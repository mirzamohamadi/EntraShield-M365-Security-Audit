# Remediation: Configure DMARC

1. Inventory all systems sending email for the domain.
2. Ensure SPF includes authorized sending services.
3. Enable DKIM for Microsoft 365 and third-party senders.
4. Publish DMARC in monitoring mode first: `p=none`.
5. Review aggregate reports.
6. Move to `p=quarantine` and eventually `p=reject` when legitimate senders pass alignment.

Reference: https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/email-authentication-dmarc-configure
