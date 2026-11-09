# ============================================================
# Lab 18 - Join Member Server to Active Directory Domain
#
# IMPORTANT:
# Replace the placeholder account/password with a temporary
# authorized domain-join credential. Never commit real secrets.
# ============================================================

$Username = "SECOPS\REPLACE-WITH-AUTHORIZED-ACCOUNT"
$Password = ConvertTo-SecureString `
    "REPLACE-WITH-PASSWORD" `
    -AsPlainText `
    -Force

$Credential = New-Object `
    System.Management.Automation.PSCredential `
    ($Username,$Password)

Add-Computer `
    -DomainName "corp.secops.test" `
    -Credential $Credential `
    -Force

Write-Host "Restart the member server to complete the domain join."
