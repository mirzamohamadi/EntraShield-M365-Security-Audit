function Get-EntraShieldPrivilegedRoles {
    [CmdletBinding()]
    param()

    Write-Verbose 'Collecting directory roles from Microsoft Graph...'

    $roles = Invoke-EntraShieldGraphRequest -Uri 'directoryRoles?$select=id,displayName' -ApiVersion 'v1.0'
    $results = New-Object System.Collections.Generic.List[object]

    foreach ($role in @($roles)) {
        try {
            $members = Invoke-EntraShieldGraphRequest -Uri "directoryRoles/$($role.id)/members?`$select=id,displayName,userPrincipalName,userType" -ApiVersion 'v1.0'
            $userMembers = @($members | Where-Object { $_.userPrincipalName } | ForEach-Object {
                [pscustomobject]@{
                    userId            = $_.id
                    displayName       = $_.displayName
                    userPrincipalName = $_.userPrincipalName
                    userType          = $_.userType
                }
            })

            $results.Add([pscustomobject]@{
                roleId   = $role.id
                roleName = $role.displayName
                members  = $userMembers
            })
        }
        catch {
            Write-Warning "Could not collect members for role $($role.displayName): $($_.Exception.Message)"
        }
    }

    return @($results)
}
