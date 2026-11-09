Import-Module ActiveDirectory
Import-Module GroupPolicy

# ============================================================
# Lab 18 - Final Domain Controller Health Check
# ============================================================

Write-Host "============================================================"
Write-Host " LAB 18 - DOMAIN CONTROLLER FINAL HEALTH CHECK"
Write-Host "============================================================"

Write-Host "`n=== DOMAIN CONTROLLER IDENTITY ==="
$DC = Get-ADDomainController -Identity $env:COMPUTERNAME
Write-Host "Hostname:       $($DC.HostName)"
Write-Host "IPv4 Address:   $($DC.IPv4Address)"
Write-Host "Site:           $($DC.Site)"
Write-Host "Global Catalog: $($DC.IsGlobalCatalog)"

Write-Host "`n=== CORE SERVICES ==="
Get-Service DNS,NTDS,Netlogon |
    Select-Object Name,Status |
    Format-Table -AutoSize

Write-Host "`n=== DOMAIN INFORMATION ==="
$Domain = Get-ADDomain
$Forest = Get-ADForest
Write-Host "Domain:         $($Domain.DNSRoot)"
Write-Host "NetBIOS Name:   $($Domain.NetBIOSName)"
Write-Host "Domain Mode:    $($Domain.DomainMode)"
Write-Host "Forest:         $($Forest.Name)"
Write-Host "Forest Mode:    $($Forest.ForestMode)"

Write-Host "`n=== DNS VALIDATION ==="
Resolve-DnsName "corp.secops.test" -ErrorAction Stop |
    Where-Object IPAddress |
    Select-Object Name,Type,IPAddress |
    Format-Table -AutoSize

Write-Host "`n=== ORGANIZATIONAL UNITS ==="
Get-ADOrganizationalUnit `
    -Filter * `
    -SearchBase "DC=corp,DC=secops,DC=test" |
    Select-Object Name,DistinguishedName |
    Sort-Object Name |
    Format-Table -AutoSize

Write-Host "`n=== DOMAIN USERS ==="
Get-ADUser `
    -SearchBase "OU=Corp-Users,DC=corp,DC=secops,DC=test" `
    -Filter * `
    -Properties UserPrincipalName,Enabled |
    Select-Object Name,SamAccountName,UserPrincipalName,Enabled |
    Sort-Object SamAccountName |
    Format-Table -AutoSize

Write-Host "`n=== SECURITY GROUP MEMBERSHIP ==="
foreach ($Group in @("GG-SecOps-Admins","GG-SecOps-Analysts","GG-IT-Support")) {
    Write-Host "`n[$Group]"
    Get-ADGroupMember -Identity $Group |
        ForEach-Object {
            Write-Host " - $($_.Name) [$($_.SamAccountName)]"
        }
}

Write-Host "`n=== MEMBER SERVER LOCATION ==="
$Server = Get-ADComputer -Identity "vm-win-eus-01"
Write-Host "Name:     $($Server.Name)"
Write-Host "Location: $($Server.DistinguishedName)"

Write-Host "`n=== SERVER SECURITY BASELINE GPO ==="
$GPOName = "GPO-Servers-Security-Baseline"
$TargetOU = "OU=Servers,DC=corp,DC=secops,DC=test"

$GPO = Get-GPO -Name $GPOName
$Link = Get-GPInheritance -Target $TargetOU |
    Select-Object -ExpandProperty GpoLinks |
    Where-Object DisplayName -eq $GPOName

Write-Host "GPO:      $($GPO.DisplayName)"
Write-Host "Status:   $($GPO.GpoStatus)"
Write-Host "Linked:   $($Link.Enabled)"
Write-Host "Enforced: $($Link.Enforced)"

Write-Host "`n=== GROUP MANAGED SERVICE ACCOUNT ==="
$gMSA = Get-ADServiceAccount `
    -Identity "svc-secops-hlth" `
    -Properties DNSHostName,Enabled,PrincipalsAllowedToRetrieveManagedPassword

Write-Host "Name:     $($gMSA.Name)"
Write-Host "DNS Host: $($gMSA.DNSHostName)"
Write-Host "Enabled:  $($gMSA.Enabled)"
Write-Host "Location: $($gMSA.DistinguishedName)"

Write-Host "`nAuthorized hosts:"
foreach ($PrincipalDN in $gMSA.PrincipalsAllowedToRetrieveManagedPassword) {
    $Principal = Get-ADObject -Identity $PrincipalDN -Properties Name,ObjectClass
    Write-Host " - $($Principal.Name) [$($Principal.ObjectClass)]"
}

Write-Host "`n============================================================"
Write-Host " DOMAIN CONTROLLER HEALTH CHECK COMPLETE"
Write-Host "============================================================"
