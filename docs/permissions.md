# Permissions

The future live collection mode should use Microsoft Graph permissions carefully and only request what is needed.

## Recommended Read-Only Graph Scopes

```text
User.Read.All
Directory.Read.All
RoleManagement.Read.Directory
Policy.Read.All
Domain.Read.All
Reports.Read.All
AuditLog.Read.All
```

## Exchange Online

Exchange Online checks may require Exchange Online PowerShell with appropriate read-only admin privileges.

## Important Notes

- Use least privilege for audit accounts.
- Prefer a dedicated audit identity.
- Do not run early versions against production tenants without reviewing the code.
- Never store tokens or exported tenant data in GitHub.
