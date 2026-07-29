function ConvertTo-EntraShieldSanitizedText {
    [CmdletBinding()]
    param(
        [AllowNull()][object]$Value
    )

    if ($null -eq $Value) { return '' }

    $text = [string]$Value

    # GUIDs / object IDs / tenant IDs
    $text = [regex]::Replace($text, '\b[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}\b', '00000000-0000-0000-0000-000000000000')

    # IPv4 addresses
    $text = [regex]::Replace($text, '\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b', 'x.x.x.x')

    # Common tenant / domain references. Avoid changing full reference URLs.
    if ($text -notmatch '^https?://') {
        $text = [regex]::Replace($text, '\b([a-z0-9-]+\.)+(onmicrosoft\.com|local|com|net|org|io|co|de|nl|ca|com\.au|edu)\b', 'tenant-domain.example', 'IgnoreCase')
    }

    # Email addresses and UPNs are replaced after domain masking so the final output is stable.
    $text = [regex]::Replace($text, '[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}', 'user@example.com', 'IgnoreCase')

    return $text
}

function ConvertTo-EntraShieldSanitizedFinding {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Finding
    )

    [pscustomobject]@{
        Id             = $Finding.Id
        Title          = ConvertTo-EntraShieldSanitizedText $Finding.Title
        Severity       = $Finding.Severity
        Category       = $Finding.Category
        Impact         = ConvertTo-EntraShieldSanitizedText $Finding.Impact
        Evidence       = ConvertTo-EntraShieldSanitizedText $Finding.Evidence
        Recommendation = ConvertTo-EntraShieldSanitizedText $Finding.Recommendation
        Reference      = $Finding.Reference
    }
}
