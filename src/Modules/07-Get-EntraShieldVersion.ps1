function Get-EntraShieldVersion {
    [CmdletBinding()]
    param()

    $moduleRoot = $script:EntraShieldRoot
    if (-not $moduleRoot) {
        $moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    }

    $manifestPath = Join-Path $moduleRoot 'EntraShield.psd1'
    $version = 'Unknown'
    $description = 'Microsoft 365 and Microsoft Entra ID security audit toolkit.'

    if (Test-Path $manifestPath) {
        try {
            $manifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop
            $version = $manifest.Version.ToString()
            $description = $manifest.Description
        }
        catch {
            Write-Warning "Could not read module manifest: $($_.Exception.Message)"
        }
    }

    [pscustomobject]@{
        Name              = 'EntraShield'
        Version           = $version
        Description       = $description
        ModuleRoot        = $moduleRoot
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()
    }
}
