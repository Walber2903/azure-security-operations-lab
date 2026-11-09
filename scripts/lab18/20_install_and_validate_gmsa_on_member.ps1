# ============================================================
# Lab 18 - Install and Validate gMSA on Member Server
#
# The ActiveDirectory cmdlets are part of the AD PowerShell
# tools, so install RSAT-AD-PowerShell first if necessary.
# ============================================================

$ServiceAccountName = "svc-secops-hlth"

Write-Host "=== ACTIVE DIRECTORY POWERSHELL TOOLS ==="

$Feature = Get-WindowsFeature RSAT-AD-PowerShell

if (-not $Feature.Installed) {
    Install-WindowsFeature RSAT-AD-PowerShell |
        Out-Null
    Write-Host "[INSTALLED] RSAT-AD-PowerShell"
}
else {
    Write-Host "[EXISTS] RSAT-AD-PowerShell"
}

Import-Module ActiveDirectory -ErrorAction Stop

Write-Host "`n=== INSTALL gMSA ==="
Install-ADServiceAccount `
    -Identity $ServiceAccountName `
    -ErrorAction Stop

Write-Host "[INSTALLED] $ServiceAccountName"

Write-Host "`n=== TEST gMSA ==="
$Result = Test-ADServiceAccount `
    -Identity $ServiceAccountName

Write-Host "Test-ADServiceAccount result: $Result"

if ($Result) {
    Write-Host "[VALIDATED] gMSA is operational on vm-win-eus-01"
}
else {
    Write-Host "[FAILED] gMSA validation failed"
}
