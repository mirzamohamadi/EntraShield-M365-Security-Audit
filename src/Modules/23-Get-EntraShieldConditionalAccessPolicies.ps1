function Get-EntraShieldConditionalAccessBaselineKey {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Policy)

    $name = [string]$Policy.displayName
    $lower = $name.ToLowerInvariant()
    $grant = $Policy.grantControls
    $authStrength = $grant.authenticationStrength

    if ($lower -match 'legacy' -and $lower -match 'block') { return 'blockLegacyAuthentication' }
    if (($lower -match 'phishing' -or $authStrength) -and ($lower -match 'admin' -or $Policy.conditions.users.includeRoles)) { return 'requirePhishingResistantForAdmins' }
    if ($lower -match 'admin' -and $lower -match 'mfa') { return 'requireMfaForAdmins' }
    if (($lower -match 'all users' -or $lower -match 'all-users') -and $lower -match 'mfa') { return 'requireMfaForAllUsers' }
    if ($lower -match 'high.?risk|risky') { return 'blockHighRiskSignIns' }
    if ($lower -match 'compliant' -and $lower -match 'admin') { return 'requireCompliantDeviceForAdmins' }

    return 'custom'
}

function Convert-EntraShieldConditionalAccessState {
    [CmdletBinding()]
    param([string]$State)

    switch ($State) {
        'enabled' { 'enabled' }
        'disabled' { 'disabled' }
        'enabledForReportingButNotEnforced' { 'reportOnly' }
        default { $State }
    }
}

function Get-EntraShieldConditionalAccessPolicies {
    [CmdletBinding()]
    param()

    Write-Verbose 'Collecting Conditional Access policies from Microsoft Graph...'

    try {
        $policies = Invoke-EntraShieldGraphRequest -Uri 'identity/conditionalAccess/policies' -ApiVersion 'v1.0'
    }
    catch {
        throw "Could not collect Conditional Access policies. Required permission: Policy.Read.All and an Entra ID P1-capable tenant. Error: $($_.Exception.Message)"
    }

    @($policies | ForEach-Object {
        [pscustomobject]@{
            id                                   = $_.id
            displayName                          = $_.displayName
            state                                = Convert-EntraShieldConditionalAccessState -State $_.state
            baselineKey                          = Get-EntraShieldConditionalAccessBaselineKey -Policy $_
            rawState                             = $_.state
            rawAuthenticationStrengthDisplayName = $_.grantControls.authenticationStrength.displayName
            rawAuthenticationStrengthId          = $_.grantControls.authenticationStrength.id
        }
    })
}
