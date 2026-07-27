function Test-EntraShieldDomainEmailSecurity {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Data)

    $findings = New-Object System.Collections.Generic.List[object]
    $domains = @($Data.Domains)

    $missingSpf = @($domains | Where-Object { -not $_.spfPresent })
    $missingDkim = @($domains | Where-Object { -not $_.dkimEnabled })
    $weakDmarc = @($domains | Where-Object { $_.dmarcPolicy -in @('none','missing','') })

    if ($missingSpf.Count -gt 0) {
        $findings.Add((New-EntraShieldFinding -Id 'ES-DNS-001' -Title 'SPF record missing for one or more domains' -Severity 'Medium' -Category 'Domain Email Security' -Impact 'Missing SPF makes domain spoofing easier and weakens email authentication.' -Evidence "$($missingSpf.Count) domain(s) are missing SPF." -Recommendation 'Publish an SPF record that includes authorized mail senders and avoid excessive DNS lookups.' -Reference 'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/email-authentication-spf-configure'))
    }

    if ($missingDkim.Count -gt 0) {
        $findings.Add((New-EntraShieldFinding -Id 'ES-DNS-002' -Title 'DKIM is not enabled for one or more domains' -Severity 'Medium' -Category 'Domain Email Security' -Impact 'Without DKIM, recipients have weaker assurance that messages were authorized by the domain owner.' -Evidence "$($missingDkim.Count) domain(s) do not have DKIM enabled." -Recommendation 'Enable DKIM signing for all accepted domains used to send email.' -Reference 'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/email-authentication-dkim-configure'))
    }

    if ($weakDmarc.Count -gt 0) {
        $findings.Add((New-EntraShieldFinding -Id 'ES-DNS-003' -Title 'DMARC policy is missing or set to none' -Severity 'Medium' -Category 'Domain Email Security' -Impact 'A weak DMARC policy limits protection against spoofing and business email compromise.' -Evidence "$($weakDmarc.Count) domain(s) have DMARC policy missing or set to none." -Recommendation 'Move DMARC from monitoring mode to quarantine or reject after validating legitimate senders.' -Reference 'https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/email-authentication-dmarc-configure'))
    }

    [pscustomobject]@{
        Metrics = [pscustomobject]@{
            Domains = $domains.Count
            MissingSpf = $missingSpf.Count
            MissingDkim = $missingDkim.Count
            WeakDmarc = $weakDmarc.Count
        }
        Findings = $findings
    }
}
