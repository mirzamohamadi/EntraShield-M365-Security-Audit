BeforeAll {
    $script:ProjectRoot = Split-Path -Parent $PSScriptRoot
    $script:ModulePath = Join-Path $script:ProjectRoot 'src/EntraShield.psm1'
    Import-Module $script:ModulePath -Force
}

Describe 'EntraShield module import' {
    It 'Imports the module successfully' {
        Get-Module EntraShield | Should -Not -BeNullOrEmpty
    }

    It 'Exports core commands' {
        Get-Command Invoke-EntraShieldAudit -ErrorAction Stop | Should -Not -BeNullOrEmpty
        Get-Command Import-EntraShieldSampleData -ErrorAction Stop | Should -Not -BeNullOrEmpty
        Get-Command New-EntraShieldScore -ErrorAction Stop | Should -Not -BeNullOrEmpty
        Get-Command New-EntraShieldRemediationPlan -ErrorAction Stop | Should -Not -BeNullOrEmpty
        Get-Command ConvertTo-EntraShieldSanitizedText -ErrorAction Stop | Should -Not -BeNullOrEmpty
        Get-Command Test-EntraShieldEnvironment -ErrorAction Stop | Should -Not -BeNullOrEmpty
    }
}

Describe 'Sample data' {
    It 'Loads sample data' {
        $data = Import-EntraShieldSampleData -SampleDataPath (Join-Path $script:ProjectRoot 'tests/sample-data')
        $data.Users.Count | Should -BeGreaterThan 0
        $data.PrivilegedRoles.Count | Should -BeGreaterThan 0
        $data.AuthenticationMethods.Count | Should -BeGreaterThan 0
    }
}

Describe 'Demo audit' {
    It 'Generates report outputs in demo mode' {
        $out = Join-Path $script:ProjectRoot 'reports/generated-test'
        if (Test-Path $out) { Remove-Item $out -Recurse -Force }

        $result = Invoke-EntraShieldAudit -DemoMode -GenerateRemediationPlan -OutputPath $out

        Test-Path $result.Markdown | Should -BeTrue
        Test-Path $result.Html | Should -BeTrue
        Test-Path $result.Json | Should -BeTrue
        Test-Path $result.RemediationMarkdown | Should -BeTrue
        Test-Path $result.RemediationJson | Should -BeTrue
        $result.Score | Should -BeGreaterOrEqual 0
        $result.Score | Should -BeLessOrEqual 100
    }
}

Describe 'Sanitized export' {
    It 'Masks common sensitive values' {
        $text = 'admin@contoso.com signed in from 10.10.10.5 with object 11111111-2222-3333-4444-555555555555'
        $sanitized = ConvertTo-EntraShieldSanitizedText $text
        $sanitized | Should -Not -Match 'admin@contoso.com'
        $sanitized | Should -Not -Match '10.10.10.5'
        $sanitized | Should -Not -Match '11111111-2222-3333-4444-555555555555'
        $sanitized | Should -Match 'user@example.com'
    }
}

Describe 'Scoring model' {
    It 'Calculates a bounded score' {
        $findings = @(
            New-EntraShieldFinding -Id 'T-001' -Title 'Test critical' -Severity Critical -Category Authentication -Impact 'Impact' -Recommendation 'Fix'
            New-EntraShieldFinding -Id 'T-002' -Title 'Test high' -Severity High -Category 'Privileged Access' -Impact 'Impact' -Recommendation 'Fix'
        )

        $score = New-EntraShieldScore -Findings $findings
        $score.OverallScore | Should -BeGreaterOrEqual 0
        $score.OverallScore | Should -BeLessOrEqual 100
        $score.CategoryScores.Count | Should -BeGreaterThan 0
    }
}
