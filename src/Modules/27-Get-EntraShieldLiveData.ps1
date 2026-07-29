function Get-EntraShieldLiveData {
    [CmdletBinding()]
    param(
        [switch]$SkipAuthenticationMethods,
        [switch]$SkipDnsChecks,
        [switch]$IncludeExchangeOnline,
        [switch]$SkipInboxRules,
        [int]$MailboxLimit = 0,
        [switch]$NoProgress,
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

    # ArrayList is used for Windows PowerShell 5.1 compatibility.
    $collectorStatus = New-Object System.Collections.ArrayList

    function Add-CollectorStatus {
        param(
            [string]$Name,
            [string]$Status,
            [string]$Details = ''
        )

        [void]$collectorStatus.Add([pscustomobject]@{
            Name = $Name
            Status = $Status
            Details = $Details
        })
    }

    function Invoke-EntraShieldLiveCollector {
        param(
            [Parameter(Mandatory)][string]$Name,
            [Parameter(Mandatory)][scriptblock]$ScriptBlock,
            [Parameter()]$Fallback = @()
        )

        try {
            $result = & $ScriptBlock
            Add-CollectorStatus -Name $Name -Status 'Success' -Details 'Collected successfully.'
            return $result
        }
        catch {
            $message = $_.Exception.Message
            Add-CollectorStatus -Name $Name -Status 'Failed' -Details $message

            if ($ContinueOnCollectorError) {
                Write-Warning "Collector failed [$Name]: $message"
                return $Fallback
            }

            throw "Collector failed [$Name]: $message"
        }
    }

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
            Add-CollectorStatus -Name 'Tenant metadata' -Status 'Success' -Details 'Collected organization metadata.'
        }
    }
    catch {
        Add-CollectorStatus -Name 'Tenant metadata' -Status 'Warning' -Details $_.Exception.Message
        Write-Warning "Could not collect organization metadata: $($_.Exception.Message)"
    }

    $users = Invoke-EntraShieldLiveCollector -Name 'Users' -Fallback @() -ScriptBlock {
        Get-EntraShieldUsers
    }

    if ($SkipAuthenticationMethods) {
        Write-Warning 'Skipping authentication methods collection. MFA and FIDO2 findings will be incomplete.'
        Add-CollectorStatus -Name 'Authentication methods' -Status 'Skipped' -Details 'Skipped by -SkipAuthenticationMethods.'
        $authenticationMethods = @($users | ForEach-Object {
            [pscustomobject]@{
                userId            = $_.id
                userPrincipalName = $_.userPrincipalName
                methods           = @()
            }
        })
    }
    else {
        $authenticationMethods = Invoke-EntraShieldLiveCollector -Name 'Authentication methods' -Fallback @() -ScriptBlock {
            Get-EntraShieldAuthenticationMethods -Users $users -ContinueOnError:$ContinueOnCollectorError -NoProgress:$NoProgress
        }
    }

    $privilegedRoles = Invoke-EntraShieldLiveCollector -Name 'Directory roles' -Fallback @() -ScriptBlock {
        Get-EntraShieldPrivilegedRoles
    }

    $conditionalAccess = Invoke-EntraShieldLiveCollector -Name 'Conditional Access policies' -Fallback @() -ScriptBlock {
        Get-EntraShieldConditionalAccessPolicies
    }

    $domains = Invoke-EntraShieldLiveCollector -Name 'Domains' -Fallback @() -ScriptBlock {
        Get-EntraShieldDomains -SkipDnsChecks:$SkipDnsChecks
    }

    $guestUsers = Invoke-EntraShieldLiveCollector -Name 'Guest users' -Fallback @() -ScriptBlock {
        Get-EntraShieldGuestUsers -Users $users
    }

    $authenticationPolicy = Invoke-EntraShieldLiveCollector -Name 'Authentication policy' -Fallback ([pscustomobject]@{
        fido2Enabled = $false
        temporaryAccessPassEnabled = $false
        phishingResistantAuthenticationStrengthConfigured = $false
        registrationCampaignTarget = 'Unknown'
        smsEnabled = $false
        voiceEnabled = $false
    }) -ScriptBlock {
        Get-EntraShieldAuthenticationPolicy -ConditionalAccessPolicies $conditionalAccess
    }

    $exchangeForwarding = @()
    if ($IncludeExchangeOnline) {
        $exchangeForwarding = Invoke-EntraShieldLiveCollector -Name 'Exchange Online forwarding' -Fallback @() -ScriptBlock {
            $acceptedDomains = @($domains | ForEach-Object { $_.domain } | Where-Object { $_ -and ($_ -notmatch '\.onmicrosoft\.com$') })
            Get-EntraShieldExchangeForwarding -AcceptedDomains $acceptedDomains -SkipInboxRules:$SkipInboxRules -MailboxLimit $MailboxLimit -ContinueOnError:$ContinueOnCollectorError -NoProgress:$NoProgress
        }
    }
    else {
        Add-CollectorStatus -Name 'Exchange Online forwarding' -Status 'Skipped' -Details 'Skipped because -IncludeExchangeOnline was not specified.'
    }

    [pscustomobject]@{
        TenantMetadata        = $tenantMetadata
        Users                 = $users
        AuthenticationMethods = $authenticationMethods
        PrivilegedRoles       = $privilegedRoles
        ConditionalAccess     = $conditionalAccess
        ExchangeForwarding    = $exchangeForwarding
        GuestUsers            = $guestUsers
        Domains               = $domains
        AuthenticationPolicy  = $authenticationPolicy
        CollectorStatus       = @($collectorStatus.ToArray())
    }
}
