# Threat Model

EntraShield focuses on identity attack paths commonly seen in Microsoft 365 environments.

## Primary Threats

- Credential phishing
- MFA fatigue attacks
- SIM swap and SMS interception
- Adversary-in-the-middle login proxy attacks
- Legacy authentication abuse
- Privileged account compromise
- Mailbox forwarding after compromise
- Stale guest user access
- Domain spoofing and business email compromise

## Out of Scope for MVP

- Endpoint detection
- Full SIEM correlation
- Incident response automation
- Automatic remediation
- Password cracking or offensive testing

## Defensive Goal

Reduce the probability and impact of identity compromise by identifying weak authentication methods, excessive privileges, missing Conditional Access baselines, and email security gaps.
