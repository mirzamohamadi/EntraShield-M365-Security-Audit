Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Import-Module ../src/EntraShield.psm1 -Force
Connect-EntraShield
Invoke-EntraShieldAudit -Live -ContinueOnCollectorError -NoProgress -OutputPath ../reports/live-graph -OpenReport
