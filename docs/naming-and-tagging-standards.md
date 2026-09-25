# Naming and Tagging Standards

## Naming pattern

```text
<resource-type>-<workload>-<environment-or-function>-<region>-<instance>
```

Existing resource names are preserved even where early labs used a slightly different variation of the convention.

| Resource | Example |
|---|---|
| Resource group | `rg-secops-compute-canadacentral` |
| Virtual network | `vnet-secops-cc-01` |
| Subnet | `snet-management` |
| Network Security Group | `nsg-secops-servers` |
| Virtual machine | `vm-win-cac-01` |
| Managed disk | `disk-linux-mgmt-data-01` |
| Log Analytics workspace | `law-secops-cc-01` |
| Data Collection Rule | `dcr-windows-security-events` |

## Baseline tags

| Tag | Purpose | Example |
|---|---|---|
| `Environment` | Distinguishes lab resources | `Lab` |
| `Project` | Associates resources with the portfolio | `Azure-SecOps-Lab` |
| `Owner` | Identifies the responsible owner when required | Sanitized in public evidence |
| `CostCenter` | Supports cost classification when required | Lab-specific value |
| `Expiry` | Identifies a planned review or cleanup date | ISO date |

Tags provide operational context but are not security boundaries and must not contain credentials, secrets, or sensitive personal information.
