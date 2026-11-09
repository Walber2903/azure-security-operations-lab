Import-Module GroupPolicy

# ============================================================
# Lab 18 - Create and Link Server Security Baseline GPO
# ============================================================

$GPOName = "GPO-Servers-Security-Baseline"
$TargetOU = "OU=Servers,DC=corp,DC=secops,DC=test"

if (-not (Get-GPO -Name $GPOName -ErrorAction SilentlyContinue)) {
    New-GPO -Name $GPOName |
        Out-Null
}

$ExistingLink = Get-GPInheritance -Target $TargetOU |
    Select-Object -ExpandProperty GpoLinks |
    Where-Object DisplayName -eq $GPOName

if (-not $ExistingLink) {
    New-GPLink `
        -Name $GPOName `
        -Target $TargetOU `
        -LinkEnabled Yes |
        Out-Null
}

# Legal notice
Set-GPRegistryValue `
    -Name $GPOName `
    -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -ValueName "legalnoticecaption" `
    -Type String `
    -Value "Authorized Access Only"

Set-GPRegistryValue `
    -Name $GPOName `
    -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
    -ValueName "legalnoticetext" `
    -Type String `
    -Value "This system is part of the SecOps lab environment. Access is restricted to authorized users."

# PowerShell Script Block Logging
Set-GPRegistryValue `
    -Name $GPOName `
    -Key "HKLM\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" `
    -ValueName "EnableScriptBlockLogging" `
    -Type DWord `
    -Value 1

# PowerShell Module Logging
Set-GPRegistryValue `
    -Name $GPOName `
    -Key "HKLM\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging" `
    -ValueName "EnableModuleLogging" `
    -Type DWord `
    -Value 1

Write-Host "=== GPO DETAILS ==="
Get-GPO -Name $GPOName |
    Select-Object DisplayName,GpoStatus,CreationTime,ModificationTime

Write-Host "`n=== SERVERS OU GPO LINKS ==="
Get-GPInheritance -Target $TargetOU |
    Select-Object -ExpandProperty GpoLinks |
    Select-Object DisplayName,Enabled,Enforced
