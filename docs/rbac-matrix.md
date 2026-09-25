# Azure RBAC and Administrative Scope Matrix

This matrix consolidates the access-control work validated in Labs 02 and 03.

| Principal or scope | Role or relationship | Scope | Status | Security purpose |
|---|---|---|---|---|
| Grace Manager | Manager of Alice Analyst and Bob Analyst | Microsoft Entra ID | Implemented | Demonstrate identity relationships |
| `SG-SecOps-Readers` | Reader | Compute resource group | Implemented | Read-only visibility without resource modification |
| `SG-SecOps-Analysts` | Virtual Machine Contributor | Compute resource group | Implemented | VM administration without broad subscription control |
| `AU-Security-Lab` | Contains Alice, Bob, and Grace | Administrative Unit | Implemented | Demonstrate scoped identity organization |
| Ian IT | User Administrator | Administrative Unit | Evaluated, not assigned | Entra ID P1/P2 was unavailable; least privilege was preserved |

## Roles compared

| Role | View resources | Manage VMs | Manage all resources | Assign Azure roles |
|---|:---:|:---:|:---:|:---:|
| Reader | Yes | No | No | No |
| Virtual Machine Contributor | Yes | Yes | No | No |
| Contributor | Yes | Yes | Yes | No |
| Owner | Yes | Yes | Yes | Yes |
| User Access Administrator | Limited by assignment | No | No | Yes |

The lab used group-based assignments at resource-group scope to reduce direct user assignments and avoid permissions broader than required.
