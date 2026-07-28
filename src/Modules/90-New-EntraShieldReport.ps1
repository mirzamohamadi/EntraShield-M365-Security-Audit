function New-EntraShieldReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Findings,
        [Parameter(Mandatory)]$Metrics,
        [string]$OutputPath = './reports',
        [string]$TenantName = 'Demo Tenant',
        [string]$PreparedBy = 'EntraShield',
        [string]$AssessmentMode = 'Demo Sample Data'
    )

    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }

    $generatedAt = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $critical = @($Findings | Where-Object Severity -eq 'Critical').Count
    $high = @($Findings | Where-Object Severity -eq 'High').Count
    $medium = @($Findings | Where-Object Severity -eq 'Medium').Count
    $low = @($Findings | Where-Object Severity -eq 'Low').Count

    $score = 100
    $score -= ($critical * 12)
    $score -= ($high * 7)
    $score -= ($medium * 3)
    $score -= ($low * 1)
    if ($score -lt 0) { $score = 0 }

    $rating = if ($score -ge 85) { 'Strong' } elseif ($score -ge 70) { 'Good' } elseif ($score -ge 50) { 'Needs Improvement' } else { 'High Risk' }

    $summary = [pscustomobject]@{
        TenantName = $TenantName
        PreparedBy = $PreparedBy
        AssessmentMode = $AssessmentMode
        GeneratedAt = $generatedAt
        Score = $score
        Rating = $rating
        Critical = $critical
        High = $high
        Medium = $medium
        Low = $low
        TotalFindings = @($Findings).Count
        Metrics = $Metrics
    }

    $mdPath = Join-Path $OutputPath 'entra-shield-report.md'
    $htmlPath = Join-Path $OutputPath 'entra-shield-report.html'
    $jsonPath = Join-Path $OutputPath 'entra-shield-findings.json'

    $md = New-Object System.Text.StringBuilder
    [void]$md.AppendLine('# EntraShield Security Audit Report')
    [void]$md.AppendLine('')
    [void]$md.AppendLine("**Tenant:** $TenantName  ")
    [void]$md.AppendLine("**Prepared by:** $PreparedBy  ")
    [void]$md.AppendLine("**Assessment mode:** $AssessmentMode  ")
    [void]$md.AppendLine("**Generated:** $generatedAt  ")
    [void]$md.AppendLine("**Overall Score:** $score/100  ")
    [void]$md.AppendLine("**Rating:** $rating")
    [void]$md.AppendLine('')
    [void]$md.AppendLine('## Executive Summary')
    [void]$md.AppendLine('')
    [void]$md.AppendLine('| Severity | Count |')
    [void]$md.AppendLine('|---|---:|')
    [void]$md.AppendLine("| Critical | $critical |")
    [void]$md.AppendLine("| High | $high |")
    [void]$md.AppendLine("| Medium | $medium |")
    [void]$md.AppendLine("| Low | $low |")
    [void]$md.AppendLine('')
    [void]$md.AppendLine('## Findings')
    [void]$md.AppendLine('')

    foreach ($f in $Findings) {
        [void]$md.AppendLine("### $($f.Id): $($f.Title)")
        [void]$md.AppendLine('')
        [void]$md.AppendLine("- **Severity:** $($f.Severity)")
        [void]$md.AppendLine("- **Category:** $($f.Category)")
        [void]$md.AppendLine("- **Impact:** $($f.Impact)")
        [void]$md.AppendLine("- **Evidence:** $($f.Evidence)")
        [void]$md.AppendLine("- **Recommendation:** $($f.Recommendation)")
        if ($f.Reference) { [void]$md.AppendLine("- **Reference:** $($f.Reference)") }
        [void]$md.AppendLine('')
    }

    $md.ToString() | Set-Content -Path $mdPath -Encoding UTF8

    $rows = ($Findings | ForEach-Object {
        $sevClass = $_.Severity.ToLowerInvariant()
        "<tr><td><code>$($_.Id)</code></td><td><span class='sev $sevClass'>$($_.Severity)</span></td><td>$($_.Category)</td><td>$($_.Title)</td><td>$($_.Recommendation)</td></tr>"
    }) -join "`n"

    $html = @"
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>EntraShield Security Audit Report</title>
<style>
body{font-family:Segoe UI,Arial,sans-serif;background:#f6f8fb;color:#172033;margin:0;padding:0}.wrap{max-width:1180px;margin:0 auto;padding:32px}.hero{background:linear-gradient(135deg,#172033,#2554d9);color:#fff;border-radius:18px;padding:28px;margin-bottom:22px}.hero h1{margin:0 0 8px}.cards{display:grid;grid-template-columns:repeat(5,1fr);gap:14px;margin:20px 0}.card{background:#fff;border-radius:16px;padding:18px;box-shadow:0 8px 24px rgba(20,30,55,.08)}.card .n{font-size:30px;font-weight:700}.score{font-size:52px;font-weight:800}.rating{display:inline-block;background:#eef3ff;color:#1d4ed8;padding:8px 12px;border-radius:999px;font-weight:700}table{width:100%;border-collapse:collapse;background:#fff;border-radius:16px;overflow:hidden;box-shadow:0 8px 24px rgba(20,30,55,.08)}th,td{text-align:left;padding:12px;border-bottom:1px solid #eef1f7;vertical-align:top}th{background:#f0f4ff}.sev{padding:5px 9px;border-radius:999px;font-weight:700;font-size:12px}.critical{background:#fee2e2;color:#991b1b}.high{background:#ffedd5;color:#9a3412}.medium{background:#fef9c3;color:#854d0e}.low{background:#dcfce7;color:#166534}.informational{background:#e0f2fe;color:#075985}.footer{color:#69758a;font-size:13px;margin-top:22px}@media(max-width:900px){.cards{grid-template-columns:1fr 1fr}.score{font-size:40px}}</style>
</head>
<body><div class="wrap">
<section class="hero">
<h1>EntraShield Security Audit Report</h1>
<p>Tenant: <strong>$TenantName</strong> · Mode: <strong>$AssessmentMode</strong> · Prepared by: <strong>$PreparedBy</strong> · Generated: <strong>$generatedAt</strong></p>
<div class="score">$score/100</div>
<span class="rating">$rating</span>
</section>
<section class="cards">
<div class="card"><div class="n">$critical</div><div>Critical</div></div>
<div class="card"><div class="n">$high</div><div>High</div></div>
<div class="card"><div class="n">$medium</div><div>Medium</div></div>
<div class="card"><div class="n">$low</div><div>Low</div></div>
<div class="card"><div class="n">$($Findings.Count)</div><div>Total Findings</div></div>
</section>
<h2>Findings</h2>
<table>
<thead><tr><th>ID</th><th>Severity</th><th>Category</th><th>Title</th><th>Recommendation</th></tr></thead>
<tbody>
$rows
</tbody>
</table>
<p class="footer">Generated by EntraShield. This report is intended for security review and should be validated before remediation.</p>
</div></body></html>
"@

    $html | Set-Content -Path $htmlPath -Encoding UTF8

    [pscustomobject]@{
        Summary = $summary
        Findings = $Findings
    } | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonPath -Encoding UTF8

    [pscustomobject]@{
        Markdown = $mdPath
        Html = $htmlPath
        Json = $jsonPath
        Score = $score
        Rating = $rating
    }
}
