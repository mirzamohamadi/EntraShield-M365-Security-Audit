param(
    [switch]$DemoMode = $true,
    [string]$OutputPath = './reports'
)

Import-Module "$PSScriptRoot/EntraShield.psm1" -Force
Invoke-EntraShieldAudit -DemoMode:$DemoMode -OutputPath $OutputPath
