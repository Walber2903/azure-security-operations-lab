# ============================================================
# Lab 18 - Configure Role-Based Local Access
#
# SecOps Admins:
#   local Administrators
#
# IT Support:
#   Remote Desktop Users only
#
# SecOps Analysts:
#   no privileged local group membership
# ============================================================

Write-Host "=== ADD SECOPS ADMIN GROUP ==="
Add-LocalGroupMember `
    -Group "Administrators" `
    -Member "SECOPS\GG-SecOps-Admins" `
    -ErrorAction SilentlyContinue

Write-Host "=== ADD IT SUPPORT RDP GROUP ==="
Add-LocalGroupMember `
    -Group "Remote Desktop Users" `
    -Member "SECOPS\GG-IT-Support" `
    -ErrorAction SilentlyContinue

Write-Host "`n=== LOCAL ADMINISTRATORS ==="
Get-LocalGroupMember "Administrators" |
    Select-Object Name,ObjectClass,PrincipalSource

Write-Host "`n=== REMOTE DESKTOP USERS ==="
Get-LocalGroupMember "Remote Desktop Users" |
    Select-Object Name,ObjectClass,PrincipalSource
