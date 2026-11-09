Import-Module ActiveDirectory

# ============================================================
# Lab 18 - Create and Enable Domain Users
#
# The same temporary lab password is shown as a placeholder.
# Replace it locally and do not commit a real credential.
# ============================================================

$UserOU = "OU=Corp-Users,DC=corp,DC=secops,DC=test"
$TemporaryPassword = ConvertTo-SecureString `
    "REPLACE-WITH-TEMPORARY-LAB-PASSWORD" `
    -AsPlainText `
    -Force

$Users = @(
    @{Name="Alyce Johnson"; Sam="alyce"; UPN="alyce@corp.secops.test"},
    @{Name="Bob Smith";     Sam="bob";   UPN="bob@corp.secops.test"},
    @{Name="Grace Lee";     Sam="grace"; UPN="grace@corp.secops.test"}
)

foreach ($User in $Users) {
    $Existing = Get-ADUser `
        -Filter "SamAccountName -eq '$($User.Sam)'" `
        -ErrorAction SilentlyContinue

    if (-not $Existing) {
        New-ADUser `
            -Name $User.Name `
            -SamAccountName $User.Sam `
            -UserPrincipalName $User.UPN `
            -Path $UserOU `
            -AccountPassword $TemporaryPassword `
            -Enabled $true `
            -ChangePasswordAtLogon $false

        Write-Host "[CREATED] $($User.Sam)"
    }
    else {
        Enable-ADAccount -Identity $User.Sam
        Write-Host "[EXISTS/ENABLED] $($User.Sam)"
    }
}

Write-Host "`n=== CORP USERS STATUS ==="
Get-ADUser `
    -SearchBase $UserOU `
    -Filter * `
    -Properties UserPrincipalName,Enabled,PasswordLastSet |
    Select-Object Name,SamAccountName,UserPrincipalName,Enabled,PasswordLastSet |
    Sort-Object SamAccountName
