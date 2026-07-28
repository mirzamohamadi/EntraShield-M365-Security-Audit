# EntraShield PowerShell Module
# Read-only Microsoft 365 / Entra ID security audit toolkit.

$script:EntraShieldRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Get-ChildItem -Path (Join-Path $script:EntraShieldRoot 'Modules') -Filter '*.ps1' | Sort-Object Name | ForEach-Object {
    . $_.FullName
}

Export-ModuleMember -Function @(
    'Connect-EntraShield',
    'Invoke-EntraShieldAudit',
    'Import-EntraShieldSampleData',
    'New-EntraShieldFinding',
    'Test-EntraShieldMFAStatus',
    'Test-EntraShieldFIDO2Readiness',
    'Test-EntraShieldPrivilegedRoles',
    'Test-EntraShieldConditionalAccess',
    'Test-EntraShieldExchangeSecurity',
    'Test-EntraShieldGuestUsers',
    'Test-EntraShieldDomainEmailSecurity',
    'New-EntraShieldReport',
    'Invoke-EntraShieldGraphRequest',
    'Get-EntraShieldLiveData',
    'Get-EntraShieldUsers',
    'Get-EntraShieldAuthenticationMethods',
    'Get-EntraShieldPrivilegedRoles',
    'Get-EntraShieldConditionalAccessPolicies',
    'Get-EntraShieldDomains',
    'Get-EntraShieldGuestUsers',
    'Get-EntraShieldAuthenticationPolicy'
)
