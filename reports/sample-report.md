# EntraShield Security Audit Report

**Tenant:** Contoso Demo Tenant  
**Prepared by:** EntraShield  
**Assessment mode:** Demo Sample Data  
**Generated:** 2026-07-28  
**Overall Score:** 58/100  
**Rating:** Needs Improvement

## Executive Summary

This sample report demonstrates the EntraShield MSP-style output format. It is generated from demo data only and does not contain real tenant information.

| Severity | Count |
|---|---:|
| Critical | 2 |
| High | 3 |
| Medium | 2 |
| Low | 0 |
| Informational | 0 |

## Category Scores

| Category | Score | Weight | Findings | Critical | High | Medium | Low |
|---|---:|---:|---:|---:|---:|---:|---:|
| Authentication | 10.0 | 25 | 1 | 1 | 0 | 0 | 0 |
| FIDO2 Readiness | 9.8 | 15 | 1 | 0 | 1 | 0 | 0 |
| Privileged Access | 13.0 | 20 | 1 | 0 | 1 | 0 | 0 |
| Conditional Access | 6.0 | 15 | 1 | 1 | 0 | 0 | 0 |
| Exchange Security | 6.5 | 10 | 1 | 0 | 1 | 0 | 0 |
| Guest Access | 4.2 | 5 | 1 | 0 | 0 | 1 | 0 |
| Domain Email Security | 8.5 | 10 | 1 | 0 | 0 | 1 | 0 |

## Top Recommendations

- **[Critical] Privileged users without phishing-resistant MFA:** Require FIDO2 security keys or passkeys for all privileged roles.
- **[Critical] Missing phishing-resistant MFA policy for admins:** Create an authentication strength policy for phishing-resistant MFA.
- **[High] External mailbox forwarding detected:** Review and disable unnecessary external forwarding.
- **[High] FIDO2/passkey authentication is not enabled:** Enable Passkey (FIDO2) for a pilot group and then privileged users.
- **[High] Too many Global Administrators:** Reduce standing Global Administrator assignments and use least privilege roles.
- **[Medium] DMARC policy is missing or set to none:** Move DMARC toward quarantine/reject after validation.
- **[Medium] Stale guest users detected:** Run access reviews and remove stale guests.

## Findings

### ES-MFA-001: Privileged users without phishing-resistant MFA

- **Severity:** Critical
- **Category:** Authentication
- **Evidence:** 4 privileged users do not have FIDO2/passkey/certificate-based authentication.
- **Recommendation:** Require FIDO2 security keys or passkeys for all privileged roles.

### ES-CA-003: Missing phishing-resistant MFA policy for admins

- **Severity:** Critical
- **Category:** Conditional Access
- **Evidence:** No enabled Conditional Access policy detected.
- **Recommendation:** Create an authentication strength policy for phishing-resistant MFA.

### ES-EXO-001: External mailbox forwarding detected

- **Severity:** High
- **Category:** Exchange Security
- **Evidence:** 2 external forwarding rules detected.
- **Recommendation:** Review and disable unnecessary external forwarding.

### ES-FIDO-001: FIDO2/passkey authentication is not enabled

- **Severity:** High
- **Category:** FIDO2 Readiness
- **Evidence:** FIDO2 policy is disabled.
- **Recommendation:** Enable Passkey (FIDO2) for a pilot group and then privileged users.

### ES-PRIV-001: Too many Global Administrators

- **Severity:** High
- **Category:** Privileged Access
- **Evidence:** 5 Global Administrator accounts detected.
- **Recommendation:** Reduce standing Global Administrator assignments and use least privilege roles.

### ES-DNS-003: DMARC policy is missing or set to none

- **Severity:** Medium
- **Category:** Domain Email Security
- **Evidence:** 2 domains have weak DMARC posture.
- **Recommendation:** Move DMARC toward quarantine/reject after validation.

### ES-GUEST-001: Stale guest users detected

- **Severity:** Medium
- **Category:** Guest Access
- **Evidence:** 2 guest users inactive for more than 180 days.
- **Recommendation:** Run access reviews and remove stale guests.
