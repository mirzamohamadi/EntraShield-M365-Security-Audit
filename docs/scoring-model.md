# EntraShield Scoring Model

EntraShield calculates a 0-100 score based on weighted identity security categories.

The goal is not to replace a full security assessment. The score is a practical indicator for prioritizing remediation and tracking before/after improvements.

---

## Category Weights

| Category | Weight |
|---|---:|
| Authentication | 25 |
| FIDO2 Readiness | 15 |
| Privileged Access | 20 |
| Conditional Access | 15 |
| Exchange Security | 10 |
| Guest Access | 5 |
| Domain Email Security | 10 |

Total: 100 points.

---

## Severity Penalties

Each finding reduces its category score based on severity.

| Severity | Penalty Ratio |
|---|---:|
| Critical | 60% of category weight |
| High | 35% of category weight |
| Medium | 15% of category weight |
| Low | 5% of category weight |
| Informational | 0% |

Penalties are capped at the category weight. A category score cannot go below zero.

---

## Rating Bands

| Score | Rating |
|---|---|
| 85-100 | Strong |
| 70-84 | Good |
| 50-69 | Needs Improvement |
| 0-49 | High Risk |

---

## Why category-based scoring?

Earlier versions used a flat penalty model. That made demo tenants with intentionally weak settings drop too quickly to zero.

The category-based model is better because it:

- Shows which security area is weak
- Prevents one noisy category from hiding all other categories
- Makes before/after improvement easier to communicate
- Produces a more realistic executive summary

---

## Example

If Authentication has a weight of 25 and includes:

- 1 Critical finding
- 1 Medium finding

Penalty:

```text
Critical: 25 * 0.60 = 15
Medium:   25 * 0.15 = 3.75
Total penalty: 18.75
Authentication score: 25 - 18.75 = 6.25
```

Rounded category score: 6.3 / 25

---

## Important Note

The score is a decision-support metric, not a compliance certificate. Findings should be reviewed by an administrator or security engineer before remediation.
