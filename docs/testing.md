# Testing EntraShield

This guide explains how to test EntraShield locally before merging changes or creating a release.

---

## 1. Allow local PowerShell execution for the current session

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

This does not permanently change your system policy.

---

## 2. Run a quick local test

From the repository root:

```powershell
./tools/Test-EntraShieldLocal.ps1
```

This script:

- Imports the module
- Runs environment checks
- Runs demo audit
- Generates a local test report

---

## 3. Manual demo test

```powershell
Import-Module ./src/EntraShield.psm1 -Force
Invoke-EntraShieldAudit -DemoMode -OutputPath ./reports/demo
```

Expected output:

```text
reports/demo/entra-shield-report.html
reports/demo/entra-shield-report.md
reports/demo/entra-shield-findings.json
```

---

## 4. Environment check

```powershell
Test-EntraShieldEnvironment | Format-Table -AutoSize
```

This checks:

- PowerShell version
- Execution policy
- Module path
- Sample data
- Microsoft Graph SDK
- Exchange Online Management module
- Reports folder

---

## 5. Pester tests

Install Pester:

```powershell
Install-Module Pester -Scope CurrentUser -Force -SkipPublisherCheck
```

Run tests:

```powershell
Invoke-Pester -Path ./tests
```

---

## 6. GitHub Actions

The repository includes a GitHub Actions workflow that:

- Runs a parser check against PowerShell files
- Installs Pester
- Runs tests in the `tests` folder

Workflow file:

```text
.github/workflows/powershell-tests.yml
```

---

## 7. What should pass before merge?

Before merging a feature branch into `main`, verify:

- Module imports without parser errors
- Demo audit generates all output files
- Pester tests pass
- No real tenant reports are committed
- Generated local report folders are ignored
- README and CHANGELOG are updated
