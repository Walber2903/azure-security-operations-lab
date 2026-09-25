# Architecture Decisions — Labs 00–08

| Decision | Rationale | Evidence source |
|---|---|---|
| Use Canada Central as the primary region | Keep related resources co-located and simplify the topology | Labs 00, 05, 06, and 08 |
| Separate core, compute, and monitoring resources | Improve lifecycle management, RBAC scoping, cost visibility, and troubleshooting | Labs 00, 03, 05, and 08 |
| Separate server and management subnets | Demonstrate workload segmentation and controlled administrative paths | Lab 05 |
| Use Azure Bastion instead of public inbound administration rules | Reduce direct exposure of RDP and SSH management ports | Lab 06 |
| Use group-based RBAC at resource-group scope | Apply least privilege and avoid unnecessary subscription-wide permissions | Lab 03 |
| Use Azure Policy for audit and deny controls | Validate both visibility and preventive governance | Lab 04 |
| Use Trusted Launch, Secure Boot, and vTPM | Strengthen guest boot integrity where supported | Labs 06 and 07 |
| Use a separate managed data disk | Practice storage lifecycle and persistent Linux mounting independently from the OS disk | Lab 07 |
| Scope the DCR to one Windows VM | Avoid onboarding unrelated systems and unnecessary ingestion | Lab 08 |
| Collect selected Windows events with XPath | Preserve useful telemetry while controlling noise and ingestion cost | Lab 08 |
| Retain Log Analytics data for 30 days | Provide sufficient lab investigation history without unnecessary retention | Lab 08 |

These decisions describe the lab implementation. Production use would require additional availability, identity, network, retention, backup, and organizational reviews.
