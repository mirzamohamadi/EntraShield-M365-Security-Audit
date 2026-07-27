function Test-EntraShieldPrivilegedRoles {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Data)

    $findings = New-Object System.Collections.Generic.List[object]
    $roles = @($Data.PrivilegedRoles)
    $users = @($Data.Users)
    $globalAdmins = @($roles | Where-Object { $_.roleName -eq 'Global Administrator' } | ForEach-Object { $_.members })
    $allAdmins = @($roles | ForEach-Object { $_.members } | Select-Object -Property userId, userPrincipalName, displayName -Unique)
    $breakGlass = @($users | Where-Object { $_.isBreakGlass -eq $true })

    if ($globalAdmins.Count -gt 4) {
        $findings.Add((New-EntraShieldFinding -Id 'ES-PRIV-001' -Title 'Too many Global Administrators' -Severity 'High' -Category 'Privileged Access' -Impact 'Excessive Global Administrator assignments increase the blast radius of credential compromise or insider misuse.' -Evidence "$($globalAdmins.Count) Global Administrator account(s) detected." -Recommendation 'Reduce standing Global Administrator assignments. Use least privilege roles and Privileged Identity Management where possible.' -Reference 'https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference'))
    }

    $inactiveAdmins = @($allAdmins | ForEach-Object {
        $uid = $_.userId
        $u = $users | Where-Object { $_.id -eq $uid } | Select-Object -First 1
        if ($u.lastSignInDaysAgo -gt 90) { $u }
    })

    if ($inactiveAdmins.Count -gt 0) {
        $findings.Add((New-EntraShieldFinding -Id 'ES-PRIV-002' -Title 'Inactive privileged accounts detected' -Severity 'High' -Category 'Privileged Access' -Impact 'Dormant privileged accounts are high-value targets and may go unnoticed during compromise.' -Evidence "$($inactiveAdmins.Count) privileged account(s) have not signed in for more than 90 days." -Recommendation 'Review, disable, or remove privileged role assignments for inactive accounts. Monitor emergency accounts separately.' -Reference 'https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure'))
    }

    if ($breakGlass.Count -lt 2) {
        $findings.Add((New-EntraShieldFinding -Id 'ES-PRIV-003' -Title 'Less than two emergency access accounts detected' -Severity 'Medium' -Category 'Privileged Access' -Impact 'A single emergency access account may create operational risk if it is unavailable during an outage or lockout.' -Evidence "$($breakGlass.Count) emergency access account(s) marked in data." -Recommendation 'Maintain two emergency access accounts, exclude them from restrictive Conditional Access policies, protect them with strong credentials, and monitor their usage.' -Reference 'https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access'))
    }

    [pscustomobject]@{
        Metrics = [pscustomobject]@{
            GlobalAdministrators = $globalAdmins.Count
            PrivilegedUsers = $allAdmins.Count
            InactivePrivilegedUsers = $inactiveAdmins.Count
            EmergencyAccessAccounts = $breakGlass.Count
        }
        Findings = $findings
    }
}
