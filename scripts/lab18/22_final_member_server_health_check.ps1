# ============================================================
# Lab 18 - Final Member Server Health Check
# ============================================================

Write-Host "============================================================"
Write-Host " LAB 18 - MEMBER SERVER FINAL HEALTH CHECK"
Write-Host "============================================================"

Write-Host "`n=== DOMAIN MEMBERSHIP ==="
$System = Get-CimInstance Win32_ComputerSystem
Write-Host "Computer:      $($System.Name)"
Write-Host "Domain:        $($System.Domain)"
Write-Host "Domain Joined: $($System.PartOfDomain)"

Write-Host "`n=== DOMAIN CONTROLLER DISCOVERY ==="
nltest /dsgetdc:corp.secops.test

Write-Host "`n=== SECURE CHANNEL ==="
Write-Host "Secure Channel: $(Test-ComputerSecureChannel)"

Write-Host "`n=== DNS CLIENT CONFIGURATION ==="
Get-DnsClientServerAddress -AddressFamily IPv4 |
    Where-Object { $_.ServerAddresses.Count -gt 0 } |
    Select-Object InterfaceAlias,ServerAddresses |
    Format-Table -AutoSize

Write-Host "`n=== DOMAIN DNS RESOLUTION ==="
Resolve-DnsName corp.secops.test |
    Select-Object Name,Type,IPAddress |
    Format-Table -AutoSize

Write-Host "`n=== APPLIED GROUP POLICY ==="
gpresult /Scope Computer /R

Write-Host "`n=== POWERSHELL LOGGING ==="
$ScriptBlock = Get-ItemPropertyValue `
    -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" `
    -Name "EnableScriptBlockLogging" `
    -ErrorAction SilentlyContinue

$ModuleLogging = Get-ItemPropertyValue `
    -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging" `
    -Name "EnableModuleLogging" `
    -ErrorAction SilentlyContinue

Write-Host "Script Block Logging: $ScriptBlock"
Write-Host "Module Logging:       $ModuleLogging"

Write-Host "`n=== PROCESS CREATION AUDITING ==="
auditpol /get /subcategory:"Process Creation"

$CommandLineLogging = Get-ItemPropertyValue `
    -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" `
    -Name "ProcessCreationIncludeCmdLine_Enabled" `
    -ErrorAction SilentlyContinue

Write-Host "Command Line Logging: $CommandLineLogging"

Write-Host "`n=== LOCAL ADMINISTRATORS ==="
Get-LocalGroupMember "Administrators" |
    Select-Object Name,ObjectClass,PrincipalSource |
    Format-Table -AutoSize

Write-Host "`n=== REMOTE DESKTOP USERS ==="
Get-LocalGroupMember "Remote Desktop Users" |
    Select-Object Name,ObjectClass,PrincipalSource |
    Format-Table -AutoSize

Write-Host "`n=== POWERSHELL EVENT 4104 ==="
$PS4104 = Get-WinEvent `
    -FilterHashtable @{
        LogName   = "Microsoft-Windows-PowerShell/Operational"
        Id        = 4104
        StartTime = (Get-Date).AddHours(-2)
    } `
    -ErrorAction SilentlyContinue |
    Select-Object -First 5

Write-Host "Recent Event 4104 count: $($PS4104.Count)"

Write-Host "`n=== SECURITY EVENT 4688 ==="
$Events4688 = Get-WinEvent `
    -FilterHashtable @{
        LogName   = "Security"
        Id        = 4688
        StartTime = (Get-Date).AddHours(-2)
    } `
    -ErrorAction SilentlyContinue |
    Select-Object -First 5

Write-Host "Recent Event 4688 count: $($Events4688.Count)"

Write-Host "`n=== gMSA VALIDATION ==="
Import-Module ActiveDirectory -ErrorAction Stop
$gMSAResult = Test-ADServiceAccount -Identity "svc-secops-hlth"
Write-Host "svc-secops-hlth operational: $gMSAResult"

Write-Host "`n============================================================"
Write-Host " MEMBER SERVER HEALTH CHECK COMPLETE"
Write-Host "============================================================"
