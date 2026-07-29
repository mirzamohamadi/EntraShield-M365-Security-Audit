function Get-EntraShieldRemediationPhase {
    [CmdletBinding()]
    param([string]$Severity)

    switch ($Severity) {
        'Critical' { 'Phase 1 - First 7 days' }
        'High' { 'Phase 2 - Next 30 days' }
        'Medium' { 'Phase 3 - 60 days' }
        'Low' { 'Backlog / Continuous improvement' }
        default { 'Informational' }
    }
}

function New-EntraShieldRemediationPlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Findings,
        [string]$OutputPath = './reports',
        [string]$TenantName = 'Demo Tenant',
        [string]$PreparedBy = 'EntraShield',
        [string]$AssessmentMode = 'Demo Sample Data',
        [switch]$Sanitize
    )

    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }

    $generatedAt = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $planTenantName = if ($Sanitize) { 'Sanitized Tenant' } else { $TenantName }
    $planFindings = if ($Sanitize) { @($Findings | ForEach-Object { ConvertTo-EntraShieldSanitizedFinding $_ }) } else { @($Findings) }

    $severitySort = @{ Critical = 1; High = 2; Medium = 3; Low = 4; Informational = 5 }
    $orderedFindings = @($planFindings | Sort-Object @{Expression={ $severitySort[[string]$_.Severity] }}, Category, Id)

    $items = @($orderedFindings | ForEach-Object {
        [pscustomobject]@{
            Phase          = Get-EntraShieldRemediationPhase -Severity $_.Severity
            Id             = $_.Id
            Severity       = $_.Severity
            Category       = $_.Category
            Title          = $_.Title
            Evidence       = $_.Evidence
            Recommendation = $_.Recommendation
            Reference      = $_.Reference
        }
    })

    $mdPath = Join-Path $OutputPath 'remediation-plan.md'
    $jsonPath = Join-Path $OutputPath 'remediation-plan.json'

    $md = New-Object System.Text.StringBuilder
    [void]$md.AppendLine('# EntraShield Remediation Plan')
    [void]$md.AppendLine('')
    [void]$md.AppendLine("**Tenant:** $planTenantName  ")
    [void]$md.AppendLine("**Prepared by:** $PreparedBy  ")
    [void]$md.AppendLine("**Assessment mode:** $AssessmentMode  ")
    [void]$md.AppendLine("**Generated:** $generatedAt  ")
    [void]$md.AppendLine("**Sanitized:** $([bool]$Sanitize)")
    [void]$md.AppendLine('')
    [void]$md.AppendLine('> This plan is generated from EntraShield findings and should be reviewed by an administrator or security engineer before remediation.')
    [void]$md.AppendLine('')

    foreach ($phase in @('Phase 1 - First 7 days','Phase 2 - Next 30 days','Phase 3 - 60 days','Backlog / Continuous improvement','Informational')) {
        $phaseItems = @($items | Where-Object { $_.Phase -eq $phase })
        if ($phaseItems.Count -eq 0) { continue }

        [void]$md.AppendLine("## $phase")
        [void]$md.AppendLine('')

        foreach ($item in $phaseItems) {
            [void]$md.AppendLine("### $($item.Id): $($item.Title)")
            [void]$md.AppendLine('')
            [void]$md.AppendLine("- **Severity:** $($item.Severity)")
            [void]$md.AppendLine("- **Category:** $($item.Category)")
            if ($item.Evidence) { [void]$md.AppendLine("- **Evidence:** $($item.Evidence)") }
            [void]$md.AppendLine("- **Action:** $($item.Recommendation)")
            if ($item.Reference) { [void]$md.AppendLine("- **Reference:** $($item.Reference)") }
            [void]$md.AppendLine('')
        }
    }

    [void]$md.AppendLine('## Suggested 30-Day Execution Plan')
    [void]$md.AppendLine('')
    [void]$md.AppendLine('1. Fix all Critical findings affecting privileged users and authentication controls.')
    [void]$md.AppendLine('2. Remove weak fallback authentication methods for administrator accounts.')
    [void]$md.AppendLine('3. Review and reduce standing privileged role assignments.')
    [void]$md.AppendLine('4. Enable or enforce baseline Conditional Access policies in report-only mode first, then enforce after validation.')
    [void]$md.AppendLine('5. Review Exchange Online forwarding and suspicious inbox rules.')
    [void]$md.AppendLine('6. Review stale guest users and establish access reviews.')
    [void]$md.AppendLine('7. Improve SPF, DKIM, and DMARC posture for sending domains.')
    [void]$md.AppendLine('')

    $md.ToString() | Set-Content -Path $mdPath -Encoding UTF8

    [pscustomobject]@{
        TenantName     = $planTenantName
        PreparedBy     = $PreparedBy
        AssessmentMode = $AssessmentMode
        GeneratedAt    = $generatedAt
        Sanitized      = [bool]$Sanitize
        Items          = $items
    } | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonPath -Encoding UTF8

    [pscustomobject]@{
        Markdown = $mdPath
        Json = $jsonPath
        Items = $items.Count
    }
}
