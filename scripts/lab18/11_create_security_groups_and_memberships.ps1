Import-Module ActiveDirectory

# ============================================================
# Lab 18 - Create Role-Based Security Groups and Memberships
# ============================================================

$GroupsOU = "OU=Groups,DC=corp,DC=secops,DC=test"

$Groups = @(
    @{
        Name="GG-SecOps-Admins"
        Description="Global security group for SecOps administrators"
    },
    @{
        Name="GG-SecOps-Analysts"
        Description="Global security group for SecOps analysts"
    },
    @{
        Name="GG-IT-Support"
        Description="Global security group for IT support personnel"
    }
)

foreach ($Group in $Groups) {
    if (-not (Get-ADGroup -Filter "Name -eq '$($Group.Name)'" -ErrorAction SilentlyContinue)) {
        New-ADGroup `
            -Name $Group.Name `
            -SamAccountName $Group.Name `
            -GroupScope Global `
            -GroupCategory Security `
            -Path $GroupsOU `
            -Description $Group.Description
    }
}

# Role mapping
Add-ADGroupMember -Identity "GG-SecOps-Admins"   -Members "alyce"
Add-ADGroupMember -Identity "GG-SecOps-Analysts" -Members "bob"
Add-ADGroupMember -Identity "GG-IT-Support"       -Members "grace"

Write-Host "=== GROUP MEMBERSHIP VALIDATION ==="

foreach ($Group in @("GG-SecOps-Admins","GG-SecOps-Analysts","GG-IT-Support")) {
    Write-Host "`n=== $Group ==="
    foreach ($Member in (Get-ADGroupMember -Identity $Group)) {
        Write-Host ("Name: {0}" -f $Member.Name)
        Write-Host ("SamAccountName: {0}" -f $Member.SamAccountName)
        Write-Host ("ObjectClass: {0}" -f $Member.ObjectClass)
        Write-Host "---"
    }
}
