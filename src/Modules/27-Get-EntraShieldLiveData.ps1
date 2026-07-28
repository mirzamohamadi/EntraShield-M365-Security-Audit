function Get-EntraShieldLiveData {
    [CmdletBinding()]
    param(
        [switch]$SkipAuthenticationMethods,
        [switch]$SkipDnsChecks,
        [switch]$ContinueOnCollectorError
    )

    if (-not (Get-Command Get-MgContext -ErrorAction SilentlyContinue)) {
        throw 'Microsoft Graph PowerShell SDK is not loaded. Run Connect-EntraShield first.'
    }

    $context = Get-MgContext
    if (-not $context) {
        throw 'No active Microsoft Graph context found. Run Connect-EntraShield first.'
    }

    Write-Host 'Collecting live Microsoft Entra / Microsoft 365 data in read-only mode...' -ForegroundColor Cyan

    $tenantMetadata = [pscustomobject]@{
        displayName   = 'Unknown Tenant'
        tenantId      = $context.TenantId
        defaultDomain = ''
    }

    try {
        $org = Invoke-EntraShieldGraphRequest -Uri 'organization?$select=id,displayName,verifiedDomains' -ApiVersion 'v1.0'
        $orgFirst = @($org)[0]
        if ($orgFirst) {
            $defaultDomain = @($orgFirst.verifiedDomains | Where-Object { $_.isDefault -eq $true } | Select-Object -First 1).name
            $tenantMetadata = [pscustomobject]@{
                displayName   = $orgFirst.displayName
                tenantId      = $orgFirst.id
                defaultDomain = $defaultDomain
            }
        }
    }
    catch {
        Write-Warning "Could not collect organization metadata: $($_.Exception.Message)"
    }

    $users = Get-EntraShieldUsers

    if ($SkipAuthenticationMethods) {
        Write-Warning 'Skipping authentication methods collection. MFA and FIDO2 findings will be incomplete.'
        $authenticationMethods = @($users | ForEach-Object {
            [pscustomobject]@{
                userId            = $_.id
                userPrincipalName = $_.userPrincipalName
                methods           = @()
            }
        })
    }
    else {
        $authenticationMethods = Get-EntraShieldAuthenticationMethods -Users $users -ContinueOnError:$ContinueOnCollectorError
    }

    $privilegedRoles = Get-EntraShieldPrivilegedRoles
    $conditionalAccess = Get-EntraShieldConditionalAccessPolicies
    $domains = Get-EntraShieldDomains -SkipDnsChecks:$SkipDnsChecks
    $guestUsers = Get-EntraShieldGuestUsers -Users $users
    $authenticationPolicy = Get-EntraShieldAuthenticationPolicy -ConditionalAccessPolicies $conditionalAccess

    [pscustomobject]@{
        TenantMetadata        = $tenantMetadata
        Users                 = $users
        AuthenticationMethods = $authenticationMethods
        PrivilegedRoles       = $privilegedRoles
        ConditionalAccess     = $conditionalAccess
        ExchangeForwarding    = @()
        GuestUsers            = $guestUsers
        Domains               = $domains
        AuthenticationPolicy  = $authenticationPolicy
    }
}
