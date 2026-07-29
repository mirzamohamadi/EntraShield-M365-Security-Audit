Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Import-Module ../src/EntraShield.psm1 -Force
Invoke-EntraShieldAudit -DemoMode -Sanitize -GenerateRemediationPlan -OutputPath ../reports/sanitized-demo -OpenReport
