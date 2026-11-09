Import-Module ActiveDirectory

# ============================================================
# Lab 18 - Create KDS Root Key for gMSA
#
# Production note:
# Microsoft recommends allowing replication time before using a
# newly created KDS root key in a multi-DC production domain.
#
# Lab note:
# The backdated effective time is used only for this controlled,
# single-domain-controller lab.
# ============================================================

Write-Host "=== KDS ROOT KEY STATUS ==="

$ExistingKey = Get-KdsRootKey -ErrorAction SilentlyContinue

if ($ExistingKey) {
    Write-Host "[FOUND] A KDS root key already exists"
}
else {
    Write-Host "[NOT FOUND] Creating KDS root key for the lab"

    Add-KdsRootKey `
        -EffectiveTime ((Get-Date).AddHours(-10))

    Write-Host "[CREATED] KDS root key for the lab environment"
}
