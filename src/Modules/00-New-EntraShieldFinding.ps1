function New-EntraShieldFinding {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][ValidateSet('Critical','High','Medium','Low','Informational')][string]$Severity,
        [Parameter(Mandatory)][string]$Category,
        [Parameter(Mandatory)][string]$Impact,
        [Parameter(Mandatory)][string]$Recommendation,
        [string]$Evidence = '',
        [string]$Reference = ''
    )

    [pscustomobject]@{
        Id             = $Id
        Title          = $Title
        Severity       = $Severity
        Category       = $Category
        Impact         = $Impact
        Evidence       = $Evidence
        Recommendation = $Recommendation
        Reference      = $Reference
    }
}
