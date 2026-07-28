function Invoke-EntraShieldAudit {
    [CmdletBinding()]
    param(
        [switch]$DemoMode,
        [switch]$Live,
        [switch]$SkipAuthenticationMethods,
        [switch]$SkipDnsChecks,
        [switch]$IncludeExchangeOnline,
        [switch]$SkipInboxRules,
        [int]$MailboxLimit = 0,
        [switch]$ContinueOnCollectorError,
        [string]$SampleDataPath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'tests/sample-data'),
        [string]$OutputPath = './reports',
        [string]$TenantName,
        [string]$PreparedBy = 'EntraShield'
    )

    if ($Live -and $DemoMode) {
        throw 'Choose either -Live or -DemoMode, not both.'
    }

    if (-not $Live -and -not $DemoMode) {
        Write-Verbose 'No mode selected. Defaulting to demo mode.'
        $DemoMode = $true
    }

    if ($Live) {
        $data = Get-EntraShieldLiveData -SkipAuthenticationMethods:$SkipAuthenticationMethods -SkipDnsChecks:$SkipDnsChecks -IncludeExchangeOnline:$IncludeExchangeOnline -SkipInboxRules:$SkipInboxRules -MailboxLimit $MailboxLimit -ContinueOnCollectorError:$ContinueOnCollectorError
        if (-not $TenantName -and $data.TenantMetadata.displayName) { $TenantName = $data.TenantMetadata.displayName }
        if (-not $TenantName) { $TenantName = 'Live Tenant' }
        $assessmentMode = 'Live Microsoft Graph Read-Only'
    }
    else {
        $data = Import-EntraShieldSampleData -SampleDataPath $SampleDataPath
        if (-not $TenantName -and $data.TenantMetadata.displayName) { $TenantName = $data.TenantMetadata.displayName }
        if (-not $TenantName) { $TenantName = 'Demo Tenant' }
        $assessmentMode = 'Demo Sample Data'
    }

    $results = @(
        Test-EntraShieldMFAStatus -Data $data
        Test-EntraShieldFIDO2Readiness -Data $data
        Test-EntraShieldPrivilegedRoles -Data $data
        Test-EntraShieldConditionalAccess -Data $data
        Test-EntraShieldExchangeSecurity -Data $data
        Test-EntraShieldGuestUsers -Data $data
        Test-EntraShieldDomainEmailSecurity -Data $data
    )

    $allFindings = @($results | ForEach-Object { $_.Findings })
    $metrics = [ordered]@{}
    foreach ($r in $results) {
        foreach ($p in $r.Metrics.PSObject.Properties) {
            $metrics[$p.Name] = $p.Value
        }
    }

    New-EntraShieldReport -Findings $allFindings -Metrics ([pscustomobject]$metrics) -OutputPath $OutputPath -TenantName $TenantName -PreparedBy $PreparedBy -AssessmentMode $assessmentMode
}
