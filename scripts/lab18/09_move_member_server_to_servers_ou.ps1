Import-Module ActiveDirectory

# ============================================================
# Lab 18 - Move Domain Member Computer into Servers OU
# ============================================================

$ComputerName = "vm-win-eus-01"
$TargetOU = "OU=Servers,DC=corp,DC=secops,DC=test"

$Computer = Get-ADComputer -Identity $ComputerName

Write-Host "=== CURRENT LOCATION ==="
Write-Host $Computer.DistinguishedName

Move-ADObject `
    -Identity $Computer.DistinguishedName `
    -TargetPath $TargetOU

Write-Host "`n=== NEW LOCATION ==="
Get-ADComputer -Identity $ComputerName |
    Select-Object Name,DistinguishedName
