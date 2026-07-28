function Get-EntraShieldAuthenticationPolicy {
    [CmdletBinding()]
    param(
        [object[]]$ConditionalAccessPolicies = @()
    )

    Write-Verbose 'Collecting authentication method policy from Microsoft Graph...'

    $result = [ordered]@{
        fido2Enabled = $false
        temporaryAccessPassEnabled = $false
        phishingResistantAuthenticationStrengthConfigured = $false
        registrationCampaignTarget = 'Unknown'
        smsEnabled = $false
        voiceEnabled = $false
    }

    try {
        $configs = Invoke-EntraShieldGraphRequest -Uri 'policies/authenticationMethodsPolicy/authenticationMethodConfigurations' -ApiVersion 'v1.0'

        foreach ($config in @($configs)) {
            $id = [string]$config.id
            $state = [string]$config.state
            $isEnabled = $state -eq 'enabled'

            if ($id -match '(?i)fido2|passkey') { $result.fido2Enabled = $isEnabled }
            if ($id -match '(?i)temporaryAccessPass') { $result.temporaryAccessPassEnabled = $isEnabled }
            if ($id -match '(?i)sms') { $result.smsEnabled = $isEnabled }
            if ($id -match '(?i)voice') { $result.voiceEnabled = $isEnabled }
        }
    }
    catch {
        Write-Warning "Could not read authentication method policy. Error: $($_.Exception.Message)"
    }

    try {
        $authStrengthPolicies = Invoke-EntraShieldGraphRequest -Uri 'identity/conditionalAccess/authenticationStrength/policies' -ApiVersion 'v1.0'
        $phishingStrength = $authStrengthPolicies | Where-Object { $_.displayName -match '(?i)phishing.?resistant' }
        if ($phishingStrength) {
            $result.phishingResistantAuthenticationStrengthConfigured = $true
        }
    }
    catch {
        # Fallback: inspect Conditional Access policies for an authenticationStrength object.
        $strengthInUse = $ConditionalAccessPolicies | Where-Object { $_.rawAuthenticationStrengthDisplayName -match '(?i)phishing.?resistant' }
        if ($strengthInUse) {
            $result.phishingResistantAuthenticationStrengthConfigured = $true
        }
    }

    [pscustomobject]$result
}
