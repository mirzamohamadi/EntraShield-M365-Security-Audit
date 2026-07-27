function Test-EntraShieldGuestUsers {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Data)

    $findings = New-Object System.Collections.Generic.List[object]
    $guests = @($Data.GuestUsers)
    $stale = @($guests | Where-Object { $_.lastSignInDaysAgo -gt 180 })
    $noOwner = @($guests | Where-Object { [string]::IsNullOrWhiteSpace($_.owner) })

    if ($stale.Count -gt 0) {
        $findings.Add((New-EntraShieldFinding -Id 'ES-GUEST-001' -Title 'Stale guest users detected' -Severity 'Medium' -Category 'Guest Access' -Impact 'Old guest accounts increase external collaboration risk and may retain access longer than required.' -Evidence "$($stale.Count) guest user(s) have not signed in for more than 180 days." -Recommendation 'Implement access reviews for guest users and remove stale external accounts.' -Reference 'https://learn.microsoft.com/en-us/entra/id-governance/create-access-review'))
    }

    if ($noOwner.Count -gt 0) {
        $findings.Add((New-EntraShieldFinding -Id 'ES-GUEST-002' -Title 'Guest users without clear owner' -Severity 'Low' -Category 'Guest Access' -Impact 'Guest accounts without business ownership are difficult to review and remove safely.' -Evidence "$($noOwner.Count) guest user(s) have no owner value in sample data." -Recommendation 'Assign business owners to external users or groups and run periodic access reviews.' -Reference 'https://learn.microsoft.com/en-us/entra/external-id/what-is-b2b'))
    }

    [pscustomobject]@{
        Metrics = [pscustomobject]@{
            GuestUsers = $guests.Count
            StaleGuestUsers = $stale.Count
            GuestsWithoutOwner = $noOwner.Count
        }
        Findings = $findings
    }
}
