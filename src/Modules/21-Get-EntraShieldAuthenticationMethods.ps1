function Convert-EntraShieldAuthenticationMethodType {
    [CmdletBinding()]
    param([Parameter(Mandatory)]$Method)

    $odataType = $Method.'@odata.type'

    switch -Regex ($odataType) {
        'fido2AuthenticationMethod' { return 'fido2SecurityKey' }
        'microsoftAuthenticatorAuthenticationMethod' { return 'microsoftAuthenticator' }
        'softwareOathAuthenticationMethod' { return 'softwareOath' }
        'windowsHelloForBusinessAuthenticationMethod' { return 'windowsHelloForBusiness' }
        'temporaryAccessPassAuthenticationMethod' { return 'temporaryAccessPass' }
        'emailAuthenticationMethod' { return 'emailOtp' }
        'passwordAuthenticationMethod' { return 'password' }
        'phoneAuthenticationMethod' {
            if ($Method.phoneType -match '(?i)office') { return 'voice' }
            return 'sms'
        }
        default { return ($odataType -replace '#microsoft.graph\.', '') }
    }
}

function Get-EntraShieldAuthenticationMethods {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Users,
        [switch]$ContinueOnError,
        [switch]$NoProgress
    )

    Write-Verbose 'Collecting user authentication methods from Microsoft Graph...'

    $results = New-Object System.Collections.Generic.List[object]
    $index = 0
    $total = @($Users).Count

    foreach ($user in @($Users)) {
        $index++
        if (-not $NoProgress) {
            Write-Progress -Activity 'Collecting authentication methods' -Status "$($index) of $($total): $($user.userPrincipalName)" -PercentComplete (($index / [math]::Max($total,1)) * 100)
        }

        try {
            $escapedUserId = [uri]::EscapeDataString($user.id)
            $rawMethods = Invoke-EntraShieldGraphRequest -Uri "users/$escapedUserId/authentication/methods" -ApiVersion 'v1.0'

            $mappedMethods = @($rawMethods | ForEach-Object {
                [pscustomobject]@{
                    type        = Convert-EntraShieldAuthenticationMethodType -Method $_
                    odataType   = $_.'@odata.type'
                    id          = $_.id
                    displayName = $_.displayName
                }
            })

            $results.Add([pscustomobject]@{
                userId            = $user.id
                userPrincipalName = $user.userPrincipalName
                methods           = $mappedMethods
            })
        }
        catch {
            $message = "Failed to read authentication methods for $($user.userPrincipalName). Required permission: UserAuthenticationMethod.Read.All. Error: $($_.Exception.Message)"
            if ($ContinueOnError) {
                Write-Warning $message
                $results.Add([pscustomobject]@{
                    userId            = $user.id
                    userPrincipalName = $user.userPrincipalName
                    methods           = @()
                    error             = $message
                })
            }
            else {
                throw $message
            }
        }
    }

    if (-not $NoProgress) {
        Write-Progress -Activity 'Collecting authentication methods' -Completed
    }
    return @($results)
}
