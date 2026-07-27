# Remediation: Enable FIDO2 / Passkeys in Microsoft Entra ID

1. Open Microsoft Entra admin center.
2. Go to **Protection > Authentication methods > Policies**.
3. Select **Passkey (FIDO2)**.
4. Enable the method for a pilot group first.
5. Decide whether synced passkeys, device-bound passkeys, or specific hardware keys are allowed.
6. For high-assurance use cases, consider AAGUID allowlisting and attestation.
7. Register two credentials for privileged users: primary and backup.
8. Use Conditional Access authentication strengths for admin portals.

Reference: https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-deploy-phishing-resistant-passwordless-authentication
