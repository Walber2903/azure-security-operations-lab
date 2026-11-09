# ============================================================
# Lab 18 - Validate Active Directory DNS
# ============================================================

Write-Host "=== DNS CLIENT ==="
Get-DnsClientServerAddress -AddressFamily IPv4

Write-Host "`n=== DOMAIN DNS ==="
Resolve-DnsName corp.secops.test

Write-Host "`n=== LDAP SRV ==="
Resolve-DnsName _ldap._tcp.dc._msdcs.corp.secops.test -Type SRV

Write-Host "`n=== SERVICES ==="
Get-Service DNS,NTDS,Netlogon |
    Select-Object Name,Status
