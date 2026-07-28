function Connect-EntraShieldExchange {
    [CmdletBinding()]
    param(
        [string]$UserPrincipalName,
        [switch]$UseDeviceAuthentication,
        [switch]$ShowProgress
    )

    if (-not (Get-Module ExchangeOnlineManagement -ListAvailable)) {
        throw 'ExchangeOnlineManagement module is not installed. Run: Install-Module ExchangeOnlineManagement -Scope CurrentUser'
    }

    Import-Module ExchangeOnlineManagement -ErrorAction Stop

    $params = @{
        ShowProgress = [bool]$ShowProgress
    }

    if ($UserPrincipalName) {
        $params.UserPrincipalName = $UserPrincipalName
    }

    if ($UseDeviceAuthentication) {
        $params.Device = $true
    }

    Connect-ExchangeOnline @params
}
