Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Import-Module ../src/EntraShield.psm1 -Force
Connect-EntraShield
Connect-EntraShieldExchange
Invoke-EntraShieldAudit -Live -IncludeExchangeOnline -ContinueOnCollectorError -NoProgress -MailboxLimit 10 -OutputPath ../reports/live-exchange -OpenReport
