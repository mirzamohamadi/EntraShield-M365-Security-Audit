function New-EntraShieldScore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Findings
    )

    $weights = [ordered]@{
        'Authentication'          = 25
        'FIDO2 Readiness'         = 15
        'Privileged Access'       = 20
        'Conditional Access'      = 15
        'Exchange Security'       = 10
        'Guest Access'            = 5
        'Domain Email Security'   = 10
    }

    $severityPenaltyRatio = @{
        Critical      = 0.60
        High          = 0.35
        Medium        = 0.15
        Low           = 0.05
        Informational = 0.00
    }

    # Use a normal PowerShell array for Windows PowerShell 5.1 compatibility.
    # Some PS 5.1 environments can throw "Argument types do not match" when returning/enumerating Generic List[object].
    $categoryScores = @()
    $overall = 0.0

    foreach ($category in $weights.Keys) {
        $weight = [double]$weights[$category]
        $categoryFindings = @($Findings | Where-Object { $_.Category -eq $category })
        $penalty = 0.0

        foreach ($finding in $categoryFindings) {
            $ratio = $severityPenaltyRatio[$finding.Severity]
            if ($null -eq $ratio) { $ratio = 0.10 }
            $penalty += ($weight * [double]$ratio)
        }

        if ($penalty -gt $weight) { $penalty = $weight }
        $score = [math]::Round(($weight - $penalty), 1)
        if ($score -lt 0) { $score = 0 }

        $categoryScores += [pscustomobject]@{
            Category = $category
            Weight = $weight
            Score = $score
            Lost = [math]::Round($penalty, 1)
            Findings = $categoryFindings.Count
            Critical = @($categoryFindings | Where-Object Severity -eq 'Critical').Count
            High = @($categoryFindings | Where-Object Severity -eq 'High').Count
            Medium = @($categoryFindings | Where-Object Severity -eq 'Medium').Count
            Low = @($categoryFindings | Where-Object Severity -eq 'Low').Count
        }

        $overall += $score
    }

    $unknownFindings = @($Findings | Where-Object { $_.Category -notin $weights.Keys })
    if ($unknownFindings.Count -gt 0) {
        $unknownPenalty = 0.0
        foreach ($finding in $unknownFindings) {
            switch ($finding.Severity) {
                'Critical' { $unknownPenalty += 5 }
                'High' { $unknownPenalty += 3 }
                'Medium' { $unknownPenalty += 1 }
                'Low' { $unknownPenalty += 0.5 }
            }
        }
        $overall -= $unknownPenalty
    }

    $overall = [math]::Round($overall, 0)
    if ($overall -lt 0) { $overall = 0 }
    if ($overall -gt 100) { $overall = 100 }

    $rating = if ($overall -ge 85) { 'Strong' }
        elseif ($overall -ge 70) { 'Good' }
        elseif ($overall -ge 50) { 'Needs Improvement' }
        else { 'High Risk' }

    return [pscustomobject]@{
        OverallScore = [int]$overall
        Rating = $rating
        CategoryScores = @($categoryScores)
        UnknownFindings = $unknownFindings.Count
    }
}
