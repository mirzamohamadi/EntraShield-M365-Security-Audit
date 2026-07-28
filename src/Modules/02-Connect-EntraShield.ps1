function Connect-EntraShield {
    [CmdletBinding()]
    param(
        [string[]]$Scopes = @(
            'User.Read.All',
            'Directory.Read.All',
            'RoleManagement.Read.Directory',
            'Policy.Read.All',
            'Domain.Read.All',
            'Reports.Read.All',
            'AuditLog.Read.All',
            'UserAuthenticationMethod.Read.All'
        )
    )

    if (-not (Get-Module Microsoft.Graph.Authentication -ListAvailable)) {
        throw 'Microsoft.Graph PowerShell SDK is not installed. Run: Install-Module Microsoft.Graph -Scope CurrentUser'
    }

    Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
    Connect-MgGraph -Scopes $Scopes
}
