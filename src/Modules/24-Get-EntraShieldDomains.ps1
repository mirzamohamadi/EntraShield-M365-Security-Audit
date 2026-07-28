function Get-EntraShieldDnsTxt {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Name)

    try {
        if (Get-Command Resolve-DnsName -ErrorAction SilentlyContinue) {
            return @((Resolve-DnsName -Name $Name -Type TXT -ErrorAction Stop).Strings | ForEach-Object { ($_ -join '') })
        }

        if (Get-Command nslookup -ErrorAction SilentlyContinue) {
            $output = & nslookup -type=TXT $Name 2>$null
            return @($output | Where-Object { $_ -match '"' } | ForEach-Object {
                ($_ -replace '.*"', '' -replace '".*', '').Trim()
            } | Where-Object { $_ })
        }
    }
    catch {
        return @()
    }

    return @()
}

function Test-EntraShieldDnsRecordExists {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [ValidateSet('CNAME','TXT')][string]$Type = 'CNAME'
    )

    try {
        if (Get-Command Resolve-DnsName -ErrorAction SilentlyContinue) {
            $records = Resolve-DnsName -Name $Name -Type $Type -ErrorAction Stop
            return [bool]$records
        }
        if (Get-Command nslookup -ErrorAction SilentlyContinue) {
            $output = & nslookup -type=$Type $Name 2>$null
            return [bool]($output -match $Name)
        }
    }
    catch {
        return $false
    }

    return $false
}

function Get-EntraShieldDomains {
    [CmdletBinding()]
    param([switch]$SkipDnsChecks)

    Write-Verbose 'Collecting domains from Microsoft Graph...'

    $domains = Invoke-EntraShieldGraphRequest -Uri 'domains' -ApiVersion 'v1.0'

    @($domains | ForEach-Object {
        $domainName = $_.id
        $spfPresent = $false
        $dkimEnabled = $false
        $dmarcPolicy = 'missing'

        if (-not $SkipDnsChecks -and $domainName -notmatch '\.onmicrosoft\.com$') {
            $txt = Get-EntraShieldDnsTxt -Name $domainName
            $spfPresent = [bool]($txt | Where-Object { $_ -match '^v=spf1' })

            $dmarcTxt = Get-EntraShieldDnsTxt -Name "_dmarc.$domainName"
            $dmarcRecord = $dmarcTxt | Where-Object { $_ -match '^v=DMARC1' } | Select-Object -First 1
            if ($dmarcRecord -and $dmarcRecord -match 'p=([^;\s]+)') {
                $dmarcPolicy = $Matches[1].ToLowerInvariant()
            }

            $selector1 = Test-EntraShieldDnsRecordExists -Name "selector1._domainkey.$domainName" -Type 'CNAME'
            $selector2 = Test-EntraShieldDnsRecordExists -Name "selector2._domainkey.$domainName" -Type 'CNAME'
            $dkimEnabled = [bool]($selector1 -or $selector2)
        }

        [pscustomobject]@{
            domain      = $domainName
            isVerified  = $_.isVerified
            isDefault   = $_.isDefault
            spfPresent  = $spfPresent
            dkimEnabled = $dkimEnabled
            dmarcPolicy = $dmarcPolicy
        }
    })
}
