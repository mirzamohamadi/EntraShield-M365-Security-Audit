function Import-EntraShieldSampleData {
    [CmdletBinding()]
    param(
        [string]$SampleDataPath = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'tests/sample-data')
    )

    if (-not (Test-Path $SampleDataPath)) {
        throw "Sample data path not found: $SampleDataPath"
    }

    $files = @{
        TenantMetadata        = 'tenantMetadata.json'
        Users                 = 'users.json'
        AuthenticationMethods = 'authenticationMethods.json'
        PrivilegedRoles       = 'privilegedRoles.json'
        ConditionalAccess     = 'conditionalAccessPolicies.json'
        ExchangeForwarding    = 'exchangeForwarding.json'
        GuestUsers            = 'guestUsers.json'
        Domains               = 'domains.json'
        AuthenticationPolicy  = 'authenticationPolicy.json'
    }

    $data = [ordered]@{}
    foreach ($key in $files.Keys) {
        $path = Join-Path $SampleDataPath $files[$key]
        if (Test-Path $path) {
            $data[$key] = Get-Content $path -Raw | ConvertFrom-Json
        }
        else {
            $data[$key] = @()
        }
    }

    [pscustomobject]$data
}
