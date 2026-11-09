# ============================================================
# Lab 18 - Install AD DS and DNS Roles
# ============================================================

Install-WindowsFeature `
    AD-Domain-Services,DNS `
    -IncludeManagementTools

Write-Host "`n=== ROLE VALIDATION ==="
Get-WindowsFeature AD-Domain-Services,DNS
