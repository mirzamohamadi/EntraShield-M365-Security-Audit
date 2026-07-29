Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Import-Module ../src/EntraShield.psm1 -Force
Invoke-EntraShieldAudit -DemoMode -OutputPath ../reports/demo -OpenReport
