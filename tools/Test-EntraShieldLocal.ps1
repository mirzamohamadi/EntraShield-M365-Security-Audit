param(
    [string]$OutputPath = './reports/generated-local-test'
)

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $projectRoot

Import-Module ./src/EntraShield.psm1 -Force

Write-Host 'Running environment checks...' -ForegroundColor Cyan
Test-EntraShieldEnvironment | Format-Table -AutoSize

Write-Host 'Running demo audit...' -ForegroundColor Cyan
$result = Invoke-EntraShieldAudit -DemoMode -OutputPath $OutputPath
$result | Format-List

Write-Host "Open report: $($result.Html)" -ForegroundColor Green
