# EntraShield Security Audit Report

**Tenant:** Contoso Demo Tenant  
**Prepared by:** EntraShield  
**Assessment mode:** Demo Sample Data  
**Generated:** 2026-07-27  
**Overall Score:** 49/100  
**Rating:** High Risk

## Executive Summary

This sample report demonstrates how EntraShield presents identity security findings for a Microsoft 365 / Microsoft Entra ID environment. It is based on demo data only and does not contain real tenant information.

| Severity | Count |
|---|---:|
| Critical | 2 |
| High | 3 |
| Medium | 2 |
| Low | 0 |

## Findings

### ES-MFA-001: Privileged users without phishing-resistant MFA

- **Severity:** Critical
- **Category:** Authentication
- **Evidence:** 4 privileged users do not have FIDO2/passkey/certificate-based authentication.
- **Recommendation:** Require FIDO2 security keys or passkeys for all privileged roles.

### ES-FIDO-001: FIDO2/passkey authentication is not enabled

- **Severity:** High
- **Category:** FIDO2 Readiness
- **Evidence:** FIDO2 policy is disabled.
- **Recommendation:** Enable Passkey (FIDO2) for a pilot group and then privileged users.

### ES-CA-003: Missing phishing-resistant MFA policy for admins

- **Severity:** Critical
- **Category:** Conditional Access
- **Evidence:** No enabled Conditional Access policy detected.
- **Recommendation:** Create an authentication strength policy for phishing-resistant MFA.

### ES-PRIV-001: Too many Global Administrators

- **Severity:** High
- **Category:** Privileged Access
- **Evidence:** 5 Global Administrator accounts detected.
- **Recommendation:** Reduce standing Global Administrator assignments and use least privilege roles.

### ES-EXO-001: External mailbox forwarding detected

- **Severity:** High
- **Category:** Exchange Security
- **Evidence:** 2 external forwarding rules detected.
- **Recommendation:** Review and disable unnecessary external forwarding.

### ES-GUEST-001: Stale guest users detected

- **Severity:** Medium
- **Category:** Guest Access
- **Evidence:** 2 guest users inactive for more than 180 days.
- **Recommendation:** Run access reviews and remove stale guests.

### ES-DNS-003: DMARC policy is missing or set to none

- **Severity:** Medium
- **Category:** Domain Email Security
- **Evidence:** 2 domains have weak DMARC posture.
- **Recommendation:** Move DMARC toward quarantine/reject after validation.
