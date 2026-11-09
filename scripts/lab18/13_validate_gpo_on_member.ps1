# ============================================================
# Lab 18 - Validate Server Security Baseline on Member Server
# ============================================================

Write-Host "=== GROUP POLICY UPDATE ==="
gpupdate /force

Write-Host "`n=== LEGAL NOTICE CAPTION ==="
Get-ItemPropertyValue `
    -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "legalnoticecaption"

Write-Host "`n=== LEGAL NOTICE TEXT ==="
Get-ItemPropertyValue `
    -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -Name "legalnoticetext"

Write-Host "`n=== APPLIED COMPUTER GPOS ==="
gpresult /Scope Computer /R
