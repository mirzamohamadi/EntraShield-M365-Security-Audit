function Convert-EntraShieldRecipientToSmtpAddress {
    [CmdletBinding()]
    param([Parameter(ValueFromPipeline)]$Recipient)

    process {
        if ($null -eq $Recipient) { return }

        $candidateValues = @()

        foreach ($propertyName in @('PrimarySmtpAddress','WindowsEmailAddress','Address','SmtpAddress','ExternalEmailAddress','Name')) {
            if ($Recipient.PSObject.Properties.Name -contains $propertyName -and $Recipient.$propertyName) {
                $candidateValues += [string]$Recipient.$propertyName
            }
        }

        if (-not $candidateValues) {
            $candidateValues += [string]$Recipient
        }

        foreach ($value in $candidateValues) {
            if ([string]::IsNullOrWhiteSpace($value)) { continue }
            $matches = [regex]::Matches($value, '[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}', 'IgnoreCase')
            foreach ($match in $matches) {
                $match.Value.ToLowerInvariant()
            }
        }
    }
}

function Test-EntraShieldExternalSmtpAddress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$SmtpAddress,
        [string[]]$AcceptedDomains = @()
    )

    if ($SmtpAddress -notmatch '@') { return $false }

    $domain = ($SmtpAddress.Split('@')[-1]).ToLowerInvariant().Trim()
    $accepted = @($AcceptedDomains | Where-Object { $_ } | ForEach-Object { $_.ToLowerInvariant().Trim() })

    if (-not $accepted -or $accepted.Count -eq 0) {
        return $true
    }

    return ($domain -notin $accepted)
}

function Get-EntraShieldRuleRisk {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Rule,
        [string[]]$ExternalTargets = @()
    )

    $name = [string]$Rule.Name
    $risk = 'Low'
    $reasons = New-Object System.Collections.Generic.List[string]

    if ($ExternalTargets.Count -gt 0) {
        $risk = 'High'
        $reasons.Add('forwards-or-redirects-to-external-recipient')
    }

    if ($Rule.DeleteMessage -eq $true) {
        $risk = 'High'
        $reasons.Add('deletes-message')
    }

    if ($Rule.MarkAsRead -eq $true) {
        if ($risk -eq 'Low') { $risk = 'Medium' }
        $reasons.Add('marks-message-as-read')
    }

    $keywords = @()
    foreach ($prop in @('SubjectContainsWords','BodyContainsWords','SubjectOrBodyContainsWords')) {
        if ($Rule.PSObject.Properties.Name -contains $prop -and $Rule.$prop) {
            $keywords += @($Rule.$prop)
        }
    }

    $keywordText = ($keywords -join ' ').ToLowerInvariant()
    if ($keywordText -match 'invoice|payment|wire|bank|mfa|password|security|alert|admin|payroll|credential|verify') {
        if ($risk -eq 'Low') { $risk = 'Medium' }
        $reasons.Add('sensitive-keywords')
    }

    if ($name -match '(?i)rss|hidden|temp|test|delete|read|archive') {
        if ($risk -eq 'Low') { $risk = 'Medium' }
        $reasons.Add('suspicious-rule-name')
    }

    [pscustomobject]@{
        Risk    = $risk
        Reasons = @($reasons)
    }
}

function Get-EntraShieldExchangeForwarding {
    [CmdletBinding()]
    param(
        [string[]]$AcceptedDomains = @(),
        [int]$MailboxLimit = 0,
        [switch]$SkipInboxRules,
        [switch]$ContinueOnError
    )

    if (-not (Get-Command Get-EXOMailbox -ErrorAction SilentlyContinue)) {
        throw 'Exchange Online cmdlets are not available. Run Connect-EntraShieldExchange first.'
    }

    Write-Verbose 'Collecting Exchange Online mailbox forwarding and inbox rules...'

    if (-not $AcceptedDomains -or $AcceptedDomains.Count -eq 0) {
        try {
            if (Get-Command Get-AcceptedDomain -ErrorAction SilentlyContinue) {
                $AcceptedDomains = @((Get-AcceptedDomain -ErrorAction Stop).DomainName | ForEach-Object { [string]$_ })
            }
        }
        catch {
            Write-Warning "Could not collect accepted domains from Exchange Online: $($_.Exception.Message)"
        }
    }

    $mailboxParams = @{
        ResultSize = 'Unlimited'
        Properties = @('ForwardingSmtpAddress','ForwardingAddress','DeliverToMailboxAndForward','RecipientTypeDetails','PrimarySmtpAddress','UserPrincipalName','DisplayName')
    }

    $mailboxes = @(Get-EXOMailbox @mailboxParams)
    if ($MailboxLimit -gt 0) {
        $mailboxes = @($mailboxes | Select-Object -First $MailboxLimit)
    }

    $results = New-Object System.Collections.Generic.List[object]
    $index = 0
    $total = $mailboxes.Count

    foreach ($mailbox in $mailboxes) {
        $index++
        $mailboxId = if ($mailbox.UserPrincipalName) { $mailbox.UserPrincipalName } else { [string]$mailbox.PrimarySmtpAddress }
        Write-Progress -Activity 'Collecting Exchange Online forwarding' -Status "$($index) of $($total): $mailboxId" -PercentComplete (($index / [math]::Max($total,1)) * 100)

        try {
            $forwardingTargets = @()

            if ($mailbox.ForwardingSmtpAddress) {
                $forwardingTargets += Convert-EntraShieldRecipientToSmtpAddress -Recipient $mailbox.ForwardingSmtpAddress
            }

            if ($mailbox.ForwardingAddress) {
                $forwardingTargets += Convert-EntraShieldRecipientToSmtpAddress -Recipient $mailbox.ForwardingAddress
            }

            $forwardingTargets = @($forwardingTargets | Select-Object -Unique)
            $externalForwardingTargets = @($forwardingTargets | Where-Object { Test-EntraShieldExternalSmtpAddress -SmtpAddress $_ -AcceptedDomains $AcceptedDomains })

            if ($externalForwardingTargets.Count -gt 0) {
                $results.Add([pscustomobject]@{
                    mailbox        = $mailboxId
                    displayName    = $mailbox.DisplayName
                    source         = 'MailboxForwarding'
                    forwardingType = 'External'
                    target         = ($externalForwardingTargets -join '; ')
                    ruleName       = 'Mailbox-level forwarding'
                    ruleRisk       = 'High'
                    details        = 'Mailbox has external forwarding configured.'
                })
            }
            elseif ($forwardingTargets.Count -gt 0) {
                $results.Add([pscustomobject]@{
                    mailbox        = $mailboxId
                    displayName    = $mailbox.DisplayName
                    source         = 'MailboxForwarding'
                    forwardingType = 'Internal'
                    target         = ($forwardingTargets -join '; ')
                    ruleName       = 'Mailbox-level forwarding'
                    ruleRisk       = 'Low'
                    details        = 'Mailbox has internal forwarding configured.'
                })
            }

            if (-not $SkipInboxRules -and (Get-Command Get-InboxRule -ErrorAction SilentlyContinue)) {
                $rules = @(Get-InboxRule -Mailbox $mailboxId -ErrorAction Stop)

                foreach ($rule in $rules) {
                    if ($rule.Enabled -eq $false) { continue }

                    $targets = @()
                    foreach ($prop in @('ForwardTo','ForwardAsAttachmentTo','RedirectTo')) {
                        if ($rule.PSObject.Properties.Name -contains $prop -and $rule.$prop) {
                            foreach ($recipient in @($rule.$prop)) {
                                $targets += Convert-EntraShieldRecipientToSmtpAddress -Recipient $recipient
                            }
                        }
                    }

                    $targets = @($targets | Select-Object -Unique)
                    $externalTargets = @($targets | Where-Object { Test-EntraShieldExternalSmtpAddress -SmtpAddress $_ -AcceptedDomains $AcceptedDomains })
                    $riskInfo = Get-EntraShieldRuleRisk -Rule $rule -ExternalTargets $externalTargets

                    if ($externalTargets.Count -gt 0 -or $riskInfo.Risk -in @('Medium','High','Critical')) {
                        $forwardingType = if ($externalTargets.Count -gt 0) { 'External' } elseif ($targets.Count -gt 0) { 'Internal' } else { 'None' }
                        $target = if ($targets.Count -gt 0) { ($targets -join '; ') } else { '' }

                        $results.Add([pscustomobject]@{
                            mailbox        = $mailboxId
                            displayName    = $mailbox.DisplayName
                            source         = 'InboxRule'
                            forwardingType = $forwardingType
                            target         = $target
                            ruleName       = $rule.Name
                            ruleRisk       = $riskInfo.Risk
                            details        = ($riskInfo.Reasons -join ', ')
                        })
                    }
                }
            }
        }
        catch {
            $message = "Failed to inspect Exchange mailbox $mailboxId. Error: $($_.Exception.Message)"
            if ($ContinueOnError) {
                Write-Warning $message
            }
            else {
                throw $message
            }
        }
    }

    Write-Progress -Activity 'Collecting Exchange Online forwarding' -Completed
    return @($results)
}
