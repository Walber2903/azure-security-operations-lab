# Cost Governance and Resource Lifecycle

Cost controls were introduced before compute and monitoring deployment and remained part of every later lab.

| Control | Configuration | Status |
|---|---|---|
| Monthly budget | US$175 | Implemented in Lab 00 |
| Budget notifications | 50%, 75%, 90%, and 100% of actual cost | Implemented in Lab 00 |
| Resource tags | `Environment`, `Project`, and lifecycle tags where applicable | Used throughout the labs |
| VM lifecycle | Start only for testing and deallocate after validation | Validated in Labs 06–08 |
| Log retention | 30 days | Configured in Lab 08 |
| Selective telemetry | Narrow Windows XPath filters | Configured in Lab 08 |
| Deployment sizing | Small B-series VMs and a 4 GiB Standard SSD data disk | Used for lab workloads |

## Operational distinction

Stopping a VM inside the guest leaves the Azure allocation in place and compute billing can continue. `az vm deallocate` releases the compute allocation. Managed disks, public IP resources, Log Analytics ingestion, and retained data may still incur charges independently.

## Review checklist

- Confirm unused VMs are `VM deallocated`.
- Review Cost Analysis after compute or monitoring changes.
- Check Log Analytics ingestion before increasing collection scope.
- Keep retention appropriate for the lab objective.
- Remove short-lived test resources after capturing evidence.
- Preserve resources intentionally required by the next lab.
