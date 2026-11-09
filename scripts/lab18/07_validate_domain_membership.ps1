# ============================================================
# Lab 18 - Validate Member Server Domain Membership
# ============================================================

Write-Host "=== DOMAIN MEMBERSHIP ==="
Get-CimInstance Win32_ComputerSystem |
    Select-Object Name,Domain,PartOfDomain

Write-Host "`n=== DOMAIN CONTROLLER DISCOVERY ==="
nltest /dsgetdc:corp.secops.test

Write-Host "`n=== SECURE CHANNEL ==="
Test-ComputerSecureChannel -Verbose
