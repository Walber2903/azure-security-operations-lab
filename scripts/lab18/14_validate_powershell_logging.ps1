# ============================================================
# Lab 18 - Validate PowerShell Security Logging
# ============================================================

Write-Host "=== SCRIPT BLOCK LOGGING ==="
Get-ItemProperty `
    "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"

Write-Host "`n=== MODULE LOGGING ==="
Get-ItemProperty `
    "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging"

Write-Host "`n=== RECENT EVENT 4104 ==="
Get-WinEvent `
    -FilterHashtable @{
        LogName   = "Microsoft-Windows-PowerShell/Operational"
        Id        = 4104
        StartTime = (Get-Date).AddMinutes(-15)
    } `
    -ErrorAction SilentlyContinue |
    Select-Object -First 10 TimeCreated,Id,Message
