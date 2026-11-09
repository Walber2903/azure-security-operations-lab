# ============================================================
# Lab 18 - Validate Member Server Before Domain Join
# ============================================================

Write-Host "=== COMPUTER ==="
Get-CimInstance Win32_ComputerSystem |
    Select-Object Name,Domain,PartOfDomain

Write-Host "`n=== DNS CLIENT ==="
Get-DnsClientServerAddress -AddressFamily IPv4

Write-Host "`n=== DOMAIN DNS ==="
Resolve-DnsName corp.secops.test

Write-Host "`n=== DC DNS ==="
Resolve-DnsName vm-dc-eus-01.corp.secops.test

Write-Host "`n=== DNS CONNECTIVITY ==="
Test-NetConnection 10.40.1.4 -Port 53

Write-Host "`n=== LDAP CONNECTIVITY ==="
Test-NetConnection 10.40.1.4 -Port 389
