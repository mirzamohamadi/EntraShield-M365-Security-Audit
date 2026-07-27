function Test-EntraShieldMFAStatus {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Data)

    $findings = New-Object System.Collections.Generic.List[object]
    $users = @($Data.Users)
    $methods = @($Data.AuthenticationMethods)
    $roles = @($Data.PrivilegedRoles)
    $adminUserIds = @($roles | ForEach-Object { $_.members } | ForEach-Object { $_.userId } | Select-Object -Unique)

    $phishingResistantTypes = @('fido2SecurityKey','passkey','windowsHelloForBusiness','certificateBasedAuthentication','smartCard')
    $mfaCapableTypes = @('microsoftAuthenticator','softwareOath','sms','voice','emailOtp') + $phishingResistantTypes

    $registered = @($methods | Where-Object { $_.methods.type | Where-Object { $_ -in $mfaCapableTypes } })
    $fido = @($methods | Where-Object { $_.methods.type | Where-Object { $_ -in $phishingResistantTypes } })
    $sms = @($methods | Where-Object { $_.methods.type -contains 'sms' })
    $withoutMfa = @($users | Where-Object {
        $uid = $_.id
        -not ($methods | Where-Object { $_.userId -eq $uid -and ($_.methods.type | Where-Object { $_ -in $mfaCapableTypes }) })
    })
    $adminsWithoutStrongMfa = @($adminUserIds | Where-Object {
        $uid = $_
        -not ($methods | Where-Object { $_.userId -eq $uid -and ($_.methods.type | Where-Object { $_ -in $phishingResistantTypes }) })
    })

    if ($adminsWithoutStrongMfa.Count -gt 0) {
        $findings.Add((New-EntraShieldFinding -Id 'ES-MFA-001' -Title 'Privileged users without phishing-resistant MFA' -Severity 'Critical' -Category 'Authentication' -Impact 'Compromise of a privileged account may lead to full tenant takeover, data exposure, mailbox compromise, and unauthorized policy changes.' -Evidence "$($adminsWithoutStrongMfa.Count) privileged user(s) do not have a phishing-resistant authentication method registered." -Recommendation 'Require FIDO2 security keys, passkeys, certificate-based authentication, or Windows Hello for Business for privileged roles. Remove SMS and voice fallback for admin accounts.' -Reference 'https://www.cisa.gov/sites/default/files/publications/fact-sheet-implementing-phishing-resistant-mfa-508c.pdf'))
    }

    if ($sms.Count -gt 0) {
        $findings.Add((New-EntraShieldFinding -Id 'ES-MFA-002' -Title 'SMS authentication is still in use' -Severity 'Medium' -Category 'Authentication' -Impact 'SMS-based MFA is vulnerable to SIM swapping, phishing, telecom compromise, and real-time proxy attacks.' -Evidence "$($sms.Count) user(s) have SMS registered as an authentication method." -Recommendation 'Plan a migration from SMS to Microsoft Authenticator number matching, FIDO2 security keys, passkeys, or certificate-based authentication. Disable SMS first for privileged users.' -Reference 'https://pages.nist.gov/800-63-4/sp800-63b.html'))
    }

    if ($users.Count -gt 0) {
        $withoutPct = [math]::Round(($withoutMfa.Count / $users.Count) * 100, 1)
        if ($withoutPct -gt 10) {
            $findings.Add((New-EntraShieldFinding -Id 'ES-MFA-003' -Title 'More than 10% of users have no MFA registered' -Severity 'High' -Category 'Authentication' -Impact 'Users without MFA remain exposed to password spraying, credential stuffing, and basic phishing attacks.' -Evidence "$($withoutMfa.Count) of $($users.Count) users ($withoutPct%) have no MFA-capable method registered." -Recommendation 'Launch an MFA registration campaign and prioritize users with access to email, finance, HR, and remote access systems.' -Reference 'https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-methods'))
        }
    }

    [pscustomobject]@{
        Metrics = [pscustomobject]@{
            TotalUsers = $users.Count
            MfaRegisteredUsers = $registered.Count
            Fido2OrPasskeyUsers = $fido.Count
            SmsUsers = $sms.Count
            UsersWithoutMfa = $withoutMfa.Count
            AdminsWithoutPhishingResistantMfa = $adminsWithoutStrongMfa.Count
        }
        Findings = $findings
    }
}
