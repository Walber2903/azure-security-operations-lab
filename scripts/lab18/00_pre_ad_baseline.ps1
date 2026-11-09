# ============================================================
# Lab 18 - Domain Controller Pre-AD Baseline
#
# Purpose:
# Capture the Windows Server identity, network configuration,
# time configuration, and AD DS / DNS installation state before
# converting the server into a domain controller.
# ============================================================

Write-Host "=== COMPUTER ==="
Get-CimInstance Win32_ComputerSystem |
    Select-Object Name,Domain,PartOfDomain,DomainRole

Write-Host "`n=== NETWORK ==="
Get-NetIPConfiguration |
    Format-List InterfaceAlias,IPv4Address,IPv4DefaultGateway,DNSServer

Write-Host "`n=== IP DETAILS ==="
ipconfig /all

Write-Host "`n=== TIME ==="
Get-Date
Get-TimeZone

Write-Host "`n=== AD DS STATUS ==="
Get-WindowsFeature AD-Domain-Services,DNS
