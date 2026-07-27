# Contributing to EntraShield

Thank you for considering a contribution.

## Principles

- Keep audit operations read-only by default.
- Do not commit secrets, tenant IDs, tokens, customer data, or screenshots with sensitive information.
- Prefer clear findings with practical remediation guidance.
- Include references when adding security recommendations.
- Add sample data for new modules so the project remains testable without a live tenant.

## Finding Format

Each finding should include:

- ID
- Title
- Severity
- Category
- Impact
- Evidence
- Recommendation
- Reference

## Branch Naming

```text
feature/add-graph-user-collector
fix/report-rendering
```

## Pull Request Checklist

- [ ] Code is read-only by default
- [ ] Sample data updated if needed
- [ ] README/docs updated if behavior changed
- [ ] No secrets or real tenant data included
- [ ] Findings use the standard schema
