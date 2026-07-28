# EntraShield Architecture

EntraShield is organized around four layers:

1. **Collectors**: gather data from Microsoft Graph, Exchange Online, DNS, or sample JSON files.
2. **Analyzers**: evaluate the data and produce normalized findings.
3. **Scoring Engine**: calculates risk and readiness scores.
4. **Report Generator**: creates HTML, Markdown, and JSON output.

## Current MVP Flow

```text
Sample JSON Data -> Analyzer Modules -> Finding Objects -> Report Generator -> HTML/MD/JSON
```

## Planned Live Flow

```text
Microsoft Graph / Exchange Online PowerShell / DNS -> Collectors -> Analyzer Modules -> Report Generator
```

## Safety Model

- Read-only by default
- No remediation without explicit user action
- No secrets stored
- No tenant data committed
- Demo mode available for public testing
