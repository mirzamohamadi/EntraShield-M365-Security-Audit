# FIDO2 / Passkey Readiness

FIDO2 readiness is not only about enabling a checkbox. A strong rollout requires policy, onboarding, recovery, and user education.

## Readiness Checks

- Is Passkey (FIDO2) enabled in Microsoft Entra ID?
- Are privileged users targeted first?
- Is Temporary Access Pass available for secure bootstrapping?
- Is a phishing-resistant authentication strength configured?
- Are weak fallback methods removed for privileged users?
- Are users required to register backup credentials?
- Are specific authenticator models controlled where needed?

## Recommended Phased Rollout

1. Pilot with IT and security team.
2. Register two FIDO2 credentials per privileged user.
3. Require phishing-resistant MFA for admin portals.
4. Remove SMS/voice fallback for admin accounts.
5. Expand to executives and high-risk users.
6. Expand passkeys to general workforce.

References:

- https://fidoalliance.org/fido2/
- https://fidoalliance.org/passkeys/
- https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-deploy-phishing-resistant-passwordless-authentication
