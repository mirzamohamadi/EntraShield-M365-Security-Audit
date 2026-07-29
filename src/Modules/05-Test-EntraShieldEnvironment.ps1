function Test-EntraShieldEnvironment {
    [CmdletBinding()]
    param(
        [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
    )

    # Use ArrayList for Windows PowerShell 5.1 compatibility.
    # Generic List[object] can throw "Argument types do not match" in some PS 5.1 return/enumeration scenarios.
    $checks = New-Object System.Collections.ArrayList

    function Add-Check {
        param(
            [string]$Name,
            [bool]$Passed,
            [string]$Details,
            [string]$Recommendation = ''
        )

        [void]$checks.Add([pscustomobject]@{
            Name = $Name
            Passed = $Passed
            Details = $Details
            Recommendation = $Recommendation
        })
    }

    $psVersion = $PSVersionTable.PSVersion.ToString()
    Add-Check -Name 'PowerShell version' -Passed ($PSVersionTable.PSVersion.Major -ge 7) -Details "Detected PowerShell $psVersion" -Recommendation 'Use PowerShell 7 or later for best compatibility.'

    $executionPolicy = Get-ExecutionPolicy
    Add-Check -Name 'Execution policy' -Passed ($executionPolicy -ne 'Restricted' -and $executionPolicy -ne 'AllSigned') -Details "Current policy: $executionPolicy" -Recommendation 'For local testing, run: Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass'

    $moduleFile = Join-Path $ProjectRoot 'src/EntraShield.psm1'
    Add-Check -Name 'Module file exists' -Passed (Test-Path $moduleFile) -Details $moduleFile -Recommendation 'Run this command from the repository root.'

    $sampleData = Join-Path $ProjectRoot 'tests/sample-data'
    Add-Check -Name 'Sample data exists' -Passed (Test-Path $sampleData) -Details $sampleData -Recommendation 'Ensure tests/sample-data is present.'

    $graphModule = Get-Module Microsoft.Graph.Authentication -ListAvailable | Select-Object -First 1
    $graphDetails = if ($graphModule) { "Installed: $($graphModule.Version)" } else { 'Not installed' }
    Add-Check -Name 'Microsoft Graph SDK' -Passed ([bool]$graphModule) -Details $graphDetails -Recommendation 'Install-Module Microsoft.Graph -Scope CurrentUser'

    $exoModule = Get-Module ExchangeOnlineManagement -ListAvailable | Select-Object -First 1
    $exoDetails = if ($exoModule) { "Installed: $($exoModule.Version)" } else { 'Not installed' }
    Add-Check -Name 'Exchange Online module' -Passed ([bool]$exoModule) -Details $exoDetails -Recommendation 'Install-Module ExchangeOnlineManagement -Scope CurrentUser'

    $reportPath = Join-Path $ProjectRoot 'reports'
    Add-Check -Name 'Reports folder' -Passed (Test-Path $reportPath) -Details $reportPath -Recommendation 'Create reports folder or run Invoke-EntraShieldAudit once.'

    return @($checks.ToArray())
}
