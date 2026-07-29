# Installation

This guide explains how to prepare a local environment for EntraShield.

## Recommended environment

- Windows 10/11
- PowerShell 7 or later
- GitHub Desktop or Git for Windows
- Microsoft Graph PowerShell SDK
- ExchangeOnlineManagement module if testing Exchange Online collection
- Pester if running tests

## Allow local script execution for the current session

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

This is temporary and applies only to the current PowerShell session.

## Install prerequisites

Microsoft Graph only:

```powershell
./tools/Install-EntraShieldPrerequisites.ps1
```

Microsoft Graph + Exchange Online:

```powershell
./tools/Install-EntraShieldPrerequisites.ps1 -IncludeExchangeOnline
```

Microsoft Graph + Exchange Online + Pester:

```powershell
./tools/Install-EntraShieldPrerequisites.ps1 -IncludeExchangeOnline -IncludePester
```

## Import the module

```powershell
Import-Module ./src/EntraShield.psm1 -Force
```

## Check version

```powershell
Get-EntraShieldVersion
```

## Check environment

```powershell
Test-EntraShieldEnvironment | Format-Table -AutoSize
```

## Run demo audit

```powershell
Invoke-EntraShieldAudit -DemoMode -OutputPath ./reports/demo -OpenReport
```

## Run tests

```powershell
Invoke-Pester -Path ./tests
```

## Troubleshooting

### Script is not digitally signed

Run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

### File is blocked after download

Run:

```powershell
Get-ChildItem -Recurse | Unblock-File
```

### Microsoft Graph SDK missing

Run:

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser
```

### Exchange Online module missing

Run:

```powershell
Install-Module ExchangeOnlineManagement -Scope CurrentUser
```
