function Get-EntraShieldGuestUsers {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Users)

    @($Users | Where-Object { $_.userType -eq 'Guest' } | ForEach-Object {
        [pscustomobject]@{
            id                = $_.id
            displayName       = $_.displayName
            userPrincipalName = $_.userPrincipalName
            lastSignInDaysAgo = $_.lastSignInDaysAgo
            owner             = ''
        }
    })
}
