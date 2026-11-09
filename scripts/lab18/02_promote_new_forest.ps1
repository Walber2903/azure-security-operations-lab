# ============================================================
# Lab 18 - Promote First Domain Controller
#
# IMPORTANT:
# Replace the placeholder DSRM password before execution.
# Do not commit real passwords to GitHub.
# ============================================================

$DSRMPassword = ConvertTo-SecureString `
    "REPLACE-WITH-A-STRONG-DSRM-PASSWORD" `
    -AsPlainText `
    -Force

Install-ADDSForest `
    -DomainName "corp.secops.test" `
    -DomainNetbiosName "SECOPS" `
    -InstallDNS `
    -SafeModeAdministratorPassword $DSRMPassword `
    -Force
