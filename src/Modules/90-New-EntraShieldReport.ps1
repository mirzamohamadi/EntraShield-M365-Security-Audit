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
    $findingsArray = @($Findings)
    $critical = @($findingsArray | Where-Object Severity -eq 'Critical').Count
    $high = @($findingsArray | Where-Object Severity -eq 'High').Count
    $medium = @($findingsArray | Where-Object Severity -eq 'Medium').Count
    $low = @($findingsArray | Where-Object Severity -eq 'Low').Count
    $informational = @($findingsArray | Where-Object Severity -eq 'Informational').Count

    $scoreModel = New-EntraShieldScore -Findings $findingsArray
    $score = $scoreModel.OverallScore
    $rating = $scoreModel.Rating

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
        Informational = $informational
        TotalFindings = $findingsArray.Count
        CategoryScores = $scoreModel.CategoryScores
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
    [void]$md.AppendLine("| Informational | $informational |")
    [void]$md.AppendLine('')
    [void]$md.AppendLine('## Category Scores')
    [void]$md.AppendLine('')
    [void]$md.AppendLine('| Category | Score | Weight | Findings | Critical | High | Medium | Low |')
    [void]$md.AppendLine('|---|---:|---:|---:|---:|---:|---:|---:|')
    foreach ($c in $scoreModel.CategoryScores) {
        [void]$md.AppendLine("| $($c.Category) | $($c.Score) | $($c.Weight) | $($c.Findings) | $($c.Critical) | $($c.High) | $($c.Medium) | $($c.Low) |")
    }
    [void]$md.AppendLine('')
    [void]$md.AppendLine('## Top Recommendations')
    [void]$md.AppendLine('')
    $topFindings = @($findingsArray | Sort-Object @{Expression={ switch ($_.Severity) { 'Critical' { 1 } 'High' { 2 } 'Medium' { 3 } 'Low' { 4 } default { 5 } } }}, Category, Id | Select-Object -First 10)
    foreach ($f in $topFindings) {
        [void]$md.AppendLine("- **[$($f.Severity)] $($f.Title):** $($f.Recommendation)")
    }
    [void]$md.AppendLine('')
    [void]$md.AppendLine('## Findings')
    [void]$md.AppendLine('')

    foreach ($f in $findingsArray) {
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

    function ConvertTo-EntraShieldHtmlText {
        param([AllowNull()][object]$Value)
        if ($null -eq $Value) { return '' }
        return [System.Net.WebUtility]::HtmlEncode([string]$Value)
    }

    $categoryRows = ($scoreModel.CategoryScores | ForEach-Object {
        $pct = if ($_.Weight -gt 0) { [math]::Round(($_.Score / $_.Weight) * 100, 0) } else { 0 }
        "<tr><td>$([System.Net.WebUtility]::HtmlEncode($_.Category))</td><td><strong>$($_.Score)/$($_.Weight)</strong></td><td><div class='bar'><span style='width:$pct%'></span></div></td><td>$($_.Findings)</td><td>$($_.Critical)</td><td>$($_.High)</td><td>$($_.Medium)</td><td>$($_.Low)</td></tr>"
    }) -join "`n"

    $topRecommendationRows = ($topFindings | ForEach-Object {
        $sevClass = $_.Severity.ToLowerInvariant()
        "<li><span class='sev $sevClass'>$($_.Severity)</span> <strong>$(ConvertTo-EntraShieldHtmlText $_.Title)</strong><br><span>$(ConvertTo-EntraShieldHtmlText $_.Recommendation)</span></li>"
    }) -join "`n"

    $findingRows = ($findingsArray | Sort-Object @{Expression={ switch ($_.Severity) { 'Critical' { 1 } 'High' { 2 } 'Medium' { 3 } 'Low' { 4 } default { 5 } } }}, Category, Id | ForEach-Object {
        $sevClass = $_.Severity.ToLowerInvariant()
        "<tr><td><code>$(ConvertTo-EntraShieldHtmlText $_.Id)</code></td><td><span class='sev $sevClass'>$($_.Severity)</span></td><td>$(ConvertTo-EntraShieldHtmlText $_.Category)</td><td>$(ConvertTo-EntraShieldHtmlText $_.Title)</td><td>$(ConvertTo-EntraShieldHtmlText $_.Evidence)</td><td>$(ConvertTo-EntraShieldHtmlText $_.Recommendation)</td></tr>"
    }) -join "`n"

    $html = @"
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>EntraShield Security Audit Report</title>
<style>
:root{--bg:#f6f8fb;--ink:#172033;--muted:#64748b;--blue:#2554d9;--card:#fff;--line:#e5eaf3}*{box-sizing:border-box}body{font-family:Segoe UI,Arial,sans-serif;background:var(--bg);color:var(--ink);margin:0;padding:0}.wrap{max-width:1280px;margin:0 auto;padding:32px}.hero{background:linear-gradient(135deg,#172033,#2554d9);color:#fff;border-radius:22px;padding:30px;margin-bottom:22px;box-shadow:0 14px 36px rgba(20,30,55,.18)}.hero h1{margin:0 0 8px;font-size:34px}.hero p{color:#dbeafe}.score{font-size:60px;font-weight:850;letter-spacing:-1px}.rating{display:inline-block;background:#eef3ff;color:#1d4ed8;padding:8px 12px;border-radius:999px;font-weight:800}.cards{display:grid;grid-template-columns:repeat(5,1fr);gap:14px;margin:20px 0}.card{background:var(--card);border-radius:18px;padding:18px;box-shadow:0 8px 24px rgba(20,30,55,.08)}.card .n{font-size:32px;font-weight:800}.muted{color:var(--muted)}.panel{background:#fff;border-radius:18px;padding:20px;margin:18px 0;box-shadow:0 8px 24px rgba(20,30,55,.08)}table{width:100%;border-collapse:collapse;background:#fff;border-radius:16px;overflow:hidden;box-shadow:0 8px 24px rgba(20,30,55,.08)}th,td{text-align:left;padding:12px;border-bottom:1px solid var(--line);vertical-align:top;font-size:14px}th{background:#f0f4ff}.sev{padding:5px 9px;border-radius:999px;font-weight:800;font-size:12px;white-space:nowrap}.critical{background:#fee2e2;color:#991b1b}.high{background:#ffedd5;color:#9a3412}.medium{background:#fef9c3;color:#854d0e}.low{background:#dcfce7;color:#166534}.informational{background:#e0f2fe;color:#075985}.bar{height:10px;background:#e5e7eb;border-radius:999px;overflow:hidden;min-width:120px}.bar span{display:block;height:100%;background:linear-gradient(90deg,#38bdf8,#2563eb);border-radius:999px}.recommendations{margin:0;padding-left:20px}.recommendations li{margin:12px 0;line-height:1.45}.footer{color:#69758a;font-size:13px;margin-top:22px}@media(max-width:980px){.cards{grid-template-columns:1fr 1fr}.score{font-size:44px}.wrap{padding:18px}table{font-size:12px}}
</style>
</head>
<body><div class="wrap">
<section class="hero">
<h1>EntraShield Security Audit Report</h1>
<p>Tenant: <strong>$(ConvertTo-EntraShieldHtmlText $TenantName)</strong> · Mode: <strong>$(ConvertTo-EntraShieldHtmlText $AssessmentMode)</strong> · Prepared by: <strong>$(ConvertTo-EntraShieldHtmlText $PreparedBy)</strong> · Generated: <strong>$generatedAt</strong></p>
<div class="score">$score/100</div>
<span class="rating">$rating</span>
</section>
<section class="cards">
<div class="card"><div class="n">$critical</div><div>Critical</div></div>
<div class="card"><div class="n">$high</div><div>High</div></div>
<div class="card"><div class="n">$medium</div><div>Medium</div></div>
<div class="card"><div class="n">$low</div><div>Low</div></div>
<div class="card"><div class="n">$($findingsArray.Count)</div><div>Total Findings</div></div>
</section>
<section class="panel">
<h2>Category Scores</h2>
<table><thead><tr><th>Category</th><th>Score</th><th>Progress</th><th>Findings</th><th>Critical</th><th>High</th><th>Medium</th><th>Low</th></tr></thead><tbody>
$categoryRows
</tbody></table>
</section>
<section class="panel">
<h2>Top Recommendations</h2>
<ol class="recommendations">
$topRecommendationRows
</ol>
</section>
<h2>Findings</h2>
<table>
<thead><tr><th>ID</th><th>Severity</th><th>Category</th><th>Title</th><th>Evidence</th><th>Recommendation</th></tr></thead>
<tbody>
$findingRows
</tbody>
</table>
<p class="footer">Generated by EntraShield. This report is intended for security review and should be validated before remediation. Sanitize real tenant data before sharing publicly.</p>
</div></body></html>
"@

    $html | Set-Content -Path $htmlPath -Encoding UTF8

    [pscustomobject]@{
        Summary = $summary
        Findings = $findingsArray
    } | ConvertTo-Json -Depth 12 | Set-Content -Path $jsonPath -Encoding UTF8

    [pscustomobject]@{
        Markdown = $mdPath
        Html = $htmlPath
        Json = $jsonPath
        Score = $score
        Rating = $rating
    }
}
