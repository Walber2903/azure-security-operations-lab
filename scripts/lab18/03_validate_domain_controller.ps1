Import-Module ActiveDirectory

# ============================================================
# Lab 18 - Validate Domain Controller Promotion
# ============================================================

Write-Host "=== COMPUTER / DOMAIN ==="
Get-CimInstance Win32_ComputerSystem |
    Select-Object Name,Domain,PartOfDomain,DomainRole

Write-Host "`n=== AD DOMAIN ==="
Get-ADDomain |
    Select-Object DNSRoot,NetBIOSName,DomainMode

Write-Host "`n=== DOMAIN CONTROLLER ==="
Get-ADDomainController |
    Select-Object HostName,IPv4Address,Site,IsGlobalCatalog

Write-Host "`n=== SERVICES ==="
Get-Service NTDS,DNS,Netlogon |
    Select-Object Name,Status

Write-Host "`n=== SHARES ==="
Get-SmbShare -Name SYSVOL,NETLOGON
