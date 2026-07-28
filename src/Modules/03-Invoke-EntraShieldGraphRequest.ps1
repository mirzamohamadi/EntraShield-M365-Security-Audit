function Invoke-EntraShieldGraphRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Uri,
        [ValidateSet('v1.0','beta')][string]$ApiVersion = 'v1.0',
        [switch]$NoPaging
    )

    if (-not (Get-Command Invoke-MgGraphRequest -ErrorAction SilentlyContinue)) {
        throw 'Microsoft Graph PowerShell SDK is not loaded. Run Connect-EntraShield first.'
    }

    if ($Uri -notmatch '^https://') {
        $requestUri = "https://graph.microsoft.com/$ApiVersion/$($Uri.TrimStart('/'))"
    }
    else {
        $requestUri = $Uri
    }

    $items = New-Object System.Collections.Generic.List[object]

    do {
        $response = Invoke-MgGraphRequest -Method GET -Uri $requestUri -ErrorAction Stop

        if ($null -ne $response.value) {
            foreach ($item in $response.value) {
                $items.Add($item)
            }
            $requestUri = $response.'@odata.nextLink'
        }
        else {
            return $response
        }

        if ($NoPaging) { break }
    } while ($requestUri)

    return @($items)
}
