function Test-EntraShieldFIDO2Readiness {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Data)

    $findings = New-Object System.Collections.Generic.List[object]
    $policy = $Data.AuthenticationPolicy
    $methods = @($Data.AuthenticationMethods)
    $roles = @($Data.PrivilegedRoles)
    $adminUserIds = @($roles | ForEach-Object { $_.members } | ForEach-Object { $_.userId } | Select-Object -Unique)
    $phishingResistantTypes = @('fido2SecurityKey','passkey','windowsHelloForBusiness','certificateBasedAuthentication','smartCard')

    $adminStrong = @($adminUserIds | Where-Object {
        $uid = $_
        $methods | Where-Object { $_.userId -eq $uid -and ($_.methods.type | Where-Object { $_ -in $phishingResistantTypes }) }
    })

    if (-not $policy.fido2Enabled) {
        $findings.Add((New-EntraShieldFinding -Id 'ES-FIDO-001' -Title 'FIDO2/passkey authentication is not enabled' -Severity 'High' -Category 'FIDO2 Readiness' -Impact 'Users cannot register phishing-resistant credentials such as FIDO2 security keys or passkeys.' -Evidence 'Authentication policy indicates FIDO2/passkey is disabled.' -Recommendation 'Enable Passkey (FIDO2) in Microsoft Entra authentication methods policy and target a pilot group first.' -Reference 'https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-deploy-phishing-resistant-passwordless-authentication'))
    }

    if (-not $policy.temporaryAccessPassEnabled) {
        $findings.Add((New-EntraShieldFinding -Id 'ES-FIDO-002' -Title 'Temporary Access Pass is not enabled for secure onboarding' -Severity 'Medium' -Category 'FIDO2 Readiness' -Impact 'Users may need to rely on weaker legacy MFA methods to bootstrap phishing-resistant credentials.' -Evidence 'Temporary Access Pass readiness is disabled in the sample policy.' -Recommendation 'Enable Temporary Access Pass for controlled onboarding of passwordless and phishing-resistant credentials.' -Reference 'https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-deploy-phishing-resistant-passwordless-authentication'))
    }

    if (-not $policy.phishingResistantAuthenticationStrengthConfigured) {
        $findings.Add((New-EntraShieldFinding -Id 'ES-FIDO-003' -Title 'No phishing-resistant authentication strength configured' -Severity 'High' -Category 'FIDO2 Readiness' -Impact 'Conditional Access policies cannot consistently require phishing-resistant MFA for sensitive applications or privileged roles.' -Evidence 'No authentication strength policy for phishing-resistant methods was detected.' -Recommendation 'Create a Conditional Access authentication strength that includes FIDO2, passkeys, Windows Hello for Business, or certificate-based authentication.' -Reference 'https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-strengths'))
    }

    if ($adminUserIds.Count -gt 0 -and $adminStrong.Count -lt $adminUserIds.Count) {
        $missing = $adminUserIds.Count - $adminStrong.Count
        $findings.Add((New-EntraShieldFinding -Id 'ES-FIDO-004' -Title 'FIDO2/passkey adoption is incomplete for privileged users' -Severity 'Critical' -Category 'FIDO2 Readiness' -Impact 'Privileged users remain vulnerable to phishing-resistant MFA gaps.' -Evidence "$missing of $($adminUserIds.Count) privileged user(s) do not have a phishing-resistant method." -Recommendation 'Require at least two registered phishing-resistant credentials for each privileged user: one primary and one backup.' -Reference 'https://www.cisa.gov/sites/default/files/publications/fact-sheet-implementing-phishing-resistant-mfa-508c.pdf'))
    }

    $score = 100
    if (-not $policy.fido2Enabled) { $score -= 30 }
    if (-not $policy.temporaryAccessPassEnabled) { $score -= 15 }
    if (-not $policy.phishingResistantAuthenticationStrengthConfigured) { $score -= 25 }
    if ($adminUserIds.Count -gt 0) {
        $score -= [math]::Round((($adminUserIds.Count - $adminStrong.Count) / $adminUserIds.Count) * 30)
    }
    if ($score -lt 0) { $score = 0 }

    [pscustomobject]@{
        Metrics = [pscustomobject]@{
            Fido2Enabled = [bool]$policy.fido2Enabled
            TemporaryAccessPassEnabled = [bool]$policy.temporaryAccessPassEnabled
            PhishingResistantAuthenticationStrengthConfigured = [bool]$policy.phishingResistantAuthenticationStrengthConfigured
            PrivilegedUsersWithStrongAuth = $adminStrong.Count
            PrivilegedUsersTotal = $adminUserIds.Count
            Fido2ReadinessScore = $score
        }
        Findings = $findings
    }
}
