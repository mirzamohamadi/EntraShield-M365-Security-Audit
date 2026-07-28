function Get-EntraShieldUsers {
    [CmdletBinding()]
    param()

    Write-Verbose 'Collecting users from Microsoft Graph...'

    try {
        $uri = 'users?$select=id,displayName,userPrincipalName,userType,accountEnabled,department,createdDateTime,signInActivity&$top=999'
        $rawUsers = Invoke-EntraShieldGraphRequest -Uri $uri -ApiVersion 'beta'
    }
    catch {
        Write-Warning "Could not collect signInActivity from beta users endpoint. Falling back to v1.0 users. Error: $($_.Exception.Message)"
        $uri = 'users?$select=id,displayName,userPrincipalName,userType,accountEnabled,department,createdDateTime&$top=999'
        $rawUsers = Invoke-EntraShieldGraphRequest -Uri $uri -ApiVersion 'v1.0'
    }

    $now = Get-Date

    @($rawUsers | ForEach-Object {
        $lastSignInDaysAgo = 999
        if ($_.signInActivity -and $_.signInActivity.lastSignInDateTime) {
            try {
                $last = [datetime]$_.signInActivity.lastSignInDateTime
                $lastSignInDaysAgo = [int]($now - $last).TotalDays
            }
            catch {
                $lastSignInDaysAgo = 999
            }
        }

        $identityText = "$($_.displayName) $($_.userPrincipalName)"
        $isBreakGlass = $identityText -match '(?i)break\s*glass|break-glass|emergency|cloud-only emergency'

        [pscustomobject]@{
            id                = $_.id
            displayName       = $_.displayName
            userPrincipalName = $_.userPrincipalName
            userType          = $_.userType
            accountEnabled    = [bool]$_.accountEnabled
            department        = $_.department
            createdDateTime   = $_.createdDateTime
            lastSignInDaysAgo = $lastSignInDaysAgo
            isBreakGlass      = [bool]$isBreakGlass
        }
    })
}
