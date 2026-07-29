param(
    [switch]$IncludeExchangeOnline,
    [switch]$IncludePester,
    [switch]$Force
)

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

function Install-RequiredModule {
    param(
        [Parameter(Mandatory)][string]$Name
    )

    $existing = Get-Module $Name -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
    if ($existing -and -not $Force) {
        Write-Host "$Name is already installed: $($existing.Version)" -ForegroundColor Green
        return
    }

    Write-Host "Installing $Name..." -ForegroundColor Cyan
    Install-Module $Name -Scope CurrentUser -Force:$Force -SkipPublisherCheck
}

try {
    Set-PSRepository PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue
}
catch {
    Write-Warning "Could not set PSGallery as trusted: $($_.Exception.Message)"
}

Install-RequiredModule -Name 'Microsoft.Graph'

if ($IncludeExchangeOnline) {
    Install-RequiredModule -Name 'ExchangeOnlineManagement'
}

if ($IncludePester) {
    Install-RequiredModule -Name 'Pester'
}

Write-Host 'Prerequisite installation completed.' -ForegroundColor Green
