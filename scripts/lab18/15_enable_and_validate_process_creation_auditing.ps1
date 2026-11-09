# ============================================================
# Lab 18 - Enable and Validate Process Creation Auditing
#
# This configures Security Event 4688 visibility and includes
# command-line arguments in process creation events.
# ============================================================

Write-Host "=== ENABLE PROCESS CREATION AUDITING ==="
auditpol /set /subcategory:"Process Creation" /success:enable

New-Item `
    -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" `
    -Force |
    Out-Null

New-ItemProperty `
    -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" `
    -Name "ProcessCreationIncludeCmdLine_Enabled" `
    -PropertyType DWord `
    -Value 1 `
    -Force |
    Out-Null

Write-Host "`n=== GENERATE CONTROLLED PROCESS ACTIVITY ==="
cmd.exe /c "whoami"
powershell.exe -NoProfile -Command "Get-Date"
hostname.exe

Write-Host "`n=== PROCESS CREATION POLICY ==="
auditpol /get /subcategory:"Process Creation"

Write-Host "`n=== RECENT EVENT 4688 ==="
Get-WinEvent `
    -FilterHashtable @{
        LogName   = "Security"
        Id        = 4688
        StartTime = (Get-Date).AddMinutes(-15)
    } `
    -ErrorAction SilentlyContinue |
    Select-Object -First 10 TimeCreated,Id,Message
