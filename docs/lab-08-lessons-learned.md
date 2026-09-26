# Lessons Learned — Labs 00–08

## Governance and identity

- Least privilege depends on both role selection and assignment scope.
- Group-based RBAC is easier to manage than repeated direct assignments.
- Licensing constraints are architectural facts; Entra P1/P2 features must not be presented as completed when unavailable.
- Azure Policy audit and deny effects serve different purposes and should be tested independently.

## Networking and compute

- Segmentation should be validated with both NSG associations and real connectivity tests.
- Azure reserves five addresses in each subnet, which affects usable capacity.
- Bastion enables administration without exposing RDP or SSH through public inbound rules.
- VM SKU availability and subscription quota are separate constraints.
- `Stopped` and `Stopped (deallocated)` are operationally and financially different.

## Storage and administration

- A managed disk should be validated in Azure and inside the guest OS.
- Persistent Linux mounts should use a filesystem UUID because device names can change after restart.
- Azure Run Command provides an out-of-band diagnostic method when interactive access is unnecessary or unavailable.

## Monitoring and analytics

- A successful AMA extension deployment does not prove data ingestion.
- DCR validation requires provisioning state, VM association, agent health, and expected records.
- Narrow XPath filters reduce noise and cost while preserving relevant telemetry.
- Controlled event generation makes the collection pipeline repeatable and testable.
- KQL summaries make raw event IDs easier to interpret during triage.

## Documentation

- Evidence is stronger when it shows both configuration and validation.
- Screenshots should be sanitized, chronological, and tied to an outcome.
- Planned capabilities must remain separate from implemented capabilities.
- Shared documents reduce duplication across lab READMEs.
