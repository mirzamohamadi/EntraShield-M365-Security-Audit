@{
    RootModule = 'EntraShield.psm1'
    ModuleVersion = '0.8.0'
    GUID = 'b0b4a0f7-1d1d-4b29-96c0-000000000001'
    Author = 'EntraShield Contributors'
    CompanyName = 'Community'
    Copyright = '(c) 2026 EntraShield Contributors. All rights reserved.'
    Description = 'Microsoft 365 and Microsoft Entra ID Zero Trust security audit toolkit.'
    PowerShellVersion = '7.0'
    FunctionsToExport = @('*')
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('Microsoft365','EntraID','CyberSecurity','ZeroTrust','FIDO2','PowerShell','MFA')
            LicenseUri = 'https://opensource.org/licenses/MIT'
            ProjectUri = 'https://github.com/example/EntraShield'
            ReleaseNotes = 'Initial demo-first MVP release.'
        }
    }
}
