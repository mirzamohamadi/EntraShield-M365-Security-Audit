function Test-EntraShieldExchangeSecurity {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Data)

    $findings = New-Object System.Collections.Generic.List[object]
    $forwarding = @($Data.ExchangeForwarding)
    $external = @($forwarding | Where-Object { $_.forwardingType -eq 'External' })
    $suspiciousRules = @($forwarding | Where-Object { $_.ruleRisk -in @('High','Critical') })

    if ($external.Count -gt 0) {
        $findings.Add((New-EntraShieldFinding -Id 'ES-EXO-001' -Title 'External mailbox forwarding detected' -Severity 'High' -Category 'Exchange Security' -Impact 'External forwarding is commonly abused after mailbox compromise to exfiltrate email silently.' -Evidence "$($external.Count) mailbox(es) have external forwarding configured." -Recommendation 'Review all external forwarding rules. Disable unnecessary forwarding and alert on future changes.' -Reference 'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/outbound-spam-policies-external-email-forwarding'))
    }

    if ($suspiciousRules.Count -gt 0) {
        $findings.Add((New-EntraShieldFinding -Id 'ES-EXO-002' -Title 'Suspicious inbox rules detected' -Severity 'High' -Category 'Exchange Security' -Impact 'Malicious inbox rules can hide security alerts, financial emails, and evidence of compromise.' -Evidence "$($suspiciousRules.Count) suspicious inbox rule(s) detected in sample data." -Recommendation 'Review inbox rules that delete, hide, mark as read, or forward messages containing financial, security, or login keywords.' -Reference 'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/detect-and-remediate-outlook-rules-forms-attack'))
    }

    [pscustomobject]@{
        Metrics = [pscustomobject]@{
            ExternalForwardingRules = $external.Count
            SuspiciousInboxRules = $suspiciousRules.Count
        }
        Findings = $findings
    }
}
