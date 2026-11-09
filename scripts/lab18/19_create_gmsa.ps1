Import-Module ActiveDirectory

# ============================================================
# Lab 18 - Create Group Managed Service Account
#
# Note:
# The gMSA name is intentionally <= 15 characters because the
# legacy sAMAccountName attribute is limited to 15 characters.
# ============================================================

$ServiceAccountName = "svc-secops-hlth"
$ServiceAccountsOU  = "OU=Service-Accounts,DC=corp,DC=secops,DC=test"
$AuthorizedComputer = Get-ADComputer -Identity "vm-win-eus-01"

$ExistingAccount = Get-ADServiceAccount `
    -Identity $ServiceAccountName `
    -ErrorAction SilentlyContinue

if (-not $ExistingAccount) {
    New-ADServiceAccount `
        -Name $ServiceAccountName `
        -DNSHostName "$ServiceAccountName.corp.secops.test" `
        -Path $ServiceAccountsOU `
        -PrincipalsAllowedToRetrieveManagedPassword $AuthorizedComputer `
        -Description "Managed service account for SecOps health monitoring"

    Write-Host "[CREATED] $ServiceAccountName"
}
else {
    Write-Host "[EXISTS] $ServiceAccountName"
}

Write-Host "`n=== GROUP MANAGED SERVICE ACCOUNT ==="
$Account = Get-ADServiceAccount `
    -Identity $ServiceAccountName `
    -Properties DNSHostName,Enabled,PrincipalsAllowedToRetrieveManagedPassword

Write-Host "Name:     $($Account.Name)"
Write-Host "DNS Host: $($Account.DNSHostName)"
Write-Host "Enabled:  $($Account.Enabled)"
Write-Host "Location: $($Account.DistinguishedName)"

Write-Host "`n=== AUTHORIZED HOSTS ==="
foreach ($PrincipalDN in $Account.PrincipalsAllowedToRetrieveManagedPassword) {
    $Principal = Get-ADObject -Identity $PrincipalDN -Properties Name,ObjectClass
    Write-Host "Name:        $($Principal.Name)"
    Write-Host "ObjectClass: $($Principal.ObjectClass)"
}
