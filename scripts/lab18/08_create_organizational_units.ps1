Import-Module ActiveDirectory

# ============================================================
# Lab 18 - Create Organizational Units
# ============================================================

$DomainDN = "DC=corp,DC=secops,DC=test"

$OUs = @(
    "Corp-Users",
    "Servers",
    "Groups",
    "Service-Accounts"
)

foreach ($OU in $OUs) {
    $Existing = Get-ADOrganizationalUnit `
        -LDAPFilter "(ou=$OU)" `
        -SearchBase $DomainDN `
        -SearchScope OneLevel `
        -ErrorAction SilentlyContinue

    if (-not $Existing) {
        New-ADOrganizationalUnit `
            -Name $OU `
            -Path $DomainDN `
            -ProtectedFromAccidentalDeletion $true

        Write-Host "[CREATED] OU=$OU"
    }
    else {
        Write-Host "[EXISTS] OU=$OU"
    }
}

Write-Host "`n=== ORGANIZATIONAL UNITS ==="
Get-ADOrganizationalUnit `
    -Filter * `
    -SearchBase $DomainDN |
    Select-Object Name,DistinguishedName |
    Sort-Object Name
