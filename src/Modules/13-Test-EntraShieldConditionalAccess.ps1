function Test-EntraShieldConditionalAccess {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Data)

    $findings = New-Object System.Collections.Generic.List[object]
    $policies = @($Data.ConditionalAccess)

    $required = @(
        @{ Id='ES-CA-001'; Name='Block legacy authentication'; Severity='High'; Key='blockLegacyAuthentication'; Recommendation='Create a Conditional Access policy that blocks legacy authentication clients.' },
        @{ Id='ES-CA-002'; Name='Require MFA for privileged roles'; Severity='High'; Key='requireMfaForAdmins'; Recommendation='Require MFA for all privileged directory roles.' },
        @{ Id='ES-CA-003'; Name='Require phishing-resistant MFA for privileged roles'; Severity='Critical'; Key='requirePhishingResistantForAdmins'; Recommendation='Require phishing-resistant authentication strength for admin portals and privileged roles.' },
        @{ Id='ES-CA-004'; Name='Block high-risk sign-ins'; Severity='High'; Key='blockHighRiskSignIns'; Recommendation='Use Identity Protection and Conditional Access to block or challenge high-risk sign-ins.' },
        @{ Id='ES-CA-005'; Name='Require compliant device for admin portals'; Severity='Medium'; Key='requireCompliantDeviceForAdmins'; Recommendation='Require compliant or hybrid joined devices for privileged admin portals where practical.' }
    )

    foreach ($r in $required) {
        $exists = $policies | Where-Object { $_.baselineKey -eq $r.Key -and $_.state -eq 'enabled' }
        if (-not $exists) {
            $findings.Add((New-EntraShieldFinding -Id $r.Id -Title "Missing Conditional Access baseline: $($r.Name)" -Severity $r.Severity -Category 'Conditional Access' -Impact 'Missing or disabled Conditional Access baselines can allow risky authentication paths and weaken Zero Trust enforcement.' -Evidence "No enabled policy found for baseline key: $($r.Key)." -Recommendation $r.Recommendation -Reference 'https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview'))
        }
    }

    [pscustomobject]@{
        Metrics = [pscustomobject]@{
            TotalPolicies = $policies.Count
            EnabledPolicies = @($policies | Where-Object { $_.state -eq 'enabled' }).Count
            MissingBaselinePolicies = $findings.Count
        }
        Findings = $findings
    }
}
