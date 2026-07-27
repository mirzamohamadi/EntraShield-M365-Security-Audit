function Invoke-EntraShieldAudit {
    [CmdletBinding()]
    param(
        [switch]$DemoMode,
        [string]$SampleDataPath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'tests/sample-data'),
        [string]$OutputPath = './reports',
        [string]$TenantName
    )

    if (-not $DemoMode) {
        Write-Warning 'Live tenant collection is planned for v0.2.0. Running demo mode unless live collectors are implemented.'
        $DemoMode = $true
    }

    if ($DemoMode) {
        $data = Import-EntraShieldSampleData -SampleDataPath $SampleDataPath
        if (-not $TenantName -and $data.TenantMetadata.displayName) { $TenantName = $data.TenantMetadata.displayName }
        if (-not $TenantName) { $TenantName = 'Demo Tenant' }
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

    New-EntraShieldReport -Findings $allFindings -Metrics ([pscustomobject]$metrics) -OutputPath $OutputPath -TenantName $TenantName
}
