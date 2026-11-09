# ============================================================
# Lab 18 - Validate Least-Privilege Role Mapping
# ============================================================

$AdminGroup   = "SECOPS\GG-SecOps-Admins"
$ITGroup      = "SECOPS\GG-IT-Support"
$AnalystGroup = "SECOPS\GG-SecOps-Analysts"

Write-Host "=== SECOPS ADMIN CHECK ==="
if (Get-LocalGroupMember "Administrators" |
    Where-Object Name -eq $AdminGroup) {
    Write-Host "[VALIDATED] GG-SecOps-Admins has local administrator access"
}

Write-Host "`n=== IT SUPPORT CHECK ==="
$RDPAccess = Get-LocalGroupMember "Remote Desktop Users" |
    Where-Object Name -eq $ITGroup

$ITAdmin = Get-LocalGroupMember "Administrators" |
    Where-Object Name -eq $ITGroup

if ($RDPAccess) {
    Write-Host "[VALIDATED] GG-IT-Support has Remote Desktop access"
}
if (-not $ITAdmin) {
    Write-Host "[VALIDATED] GG-IT-Support is NOT a local administrator"
}

Write-Host "`n=== ANALYST CHECK ==="
$AnalystRDP = Get-LocalGroupMember "Remote Desktop Users" |
    Where-Object Name -eq $AnalystGroup

$AnalystAdmin = Get-LocalGroupMember "Administrators" |
    Where-Object Name -eq $AnalystGroup

if (-not $AnalystRDP) {
    Write-Host "[VALIDATED] GG-SecOps-Analysts does NOT have Remote Desktop access"
}
if (-not $AnalystAdmin) {
    Write-Host "[VALIDATED] GG-SecOps-Analysts is NOT a local administrator"
}
