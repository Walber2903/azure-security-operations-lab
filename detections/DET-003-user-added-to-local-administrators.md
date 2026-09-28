# DET-003 — User Added to Local Administrators

## Detection metadata

| Field | Value |
|---|---|
| Status | Enabled and validated in LAB11 |
| Platform | Microsoft Sentinel |
| Data source | Windows Security event log through Azure Monitor Agent and DCR |
| Log Analytics table | `Event` |
| Windows Event ID | `4732` — A member was added to a security-enabled local group |
| Severity | High |
| Query | [`kql/lab11/03-user-added-to-local-administrators.kql`](../kql/lab11/03-user-added-to-local-administrators.kql) |
| MITRE ATT&CK | Persistence, Privilege Escalation — T1098.007 Additional Local or Domain Groups |
| Lab evidence | [`labs/lab-11-detection-rule/README-lab-11.md`](../labs/lab-11-detection-rule/README-lab-11.md) |

## Objective

Detect an account being added to the local `Administrators` group. Unexpected membership changes can establish persistence or grant elevated control of a Windows host.

## Detection logic

The query filters Security Event ID 4732, extracts the member SID and target group from `RenderedDescription`, and retains only changes to the `Administrators` group. The SID is used because it was the reliable member identifier available in the lab telemetry.

## Sentinel rule configuration

| Setting | Configuration |
|---|---|
| Run query every | 5 minutes |
| Look up data from the last | 15 minutes |
| Alert threshold | Query results greater than 0 |
| Event grouping | Group all query results into a single alert |
| Suppression | Enabled for 30 minutes after alert generation |
| Incident creation | Enabled |
| Incident grouping | Enabled using mapped entities |

## Entity mapping

| Entity | Identifier | Query field |
|---|---|---|
| Account | Sid | `AccountSid` |
| Host | HostName | `Computer` |

## Custom details

| Alert field | Query field |
|---|---|
| `AccountSID` | `AccountSid` |
| `PrivilegedGroup` | `GroupName` |
| `MembershipChangeTime` | `TimeGenerated` |
| `WindowsEventID` | `EventID` |

## Validation

The synthetic account `lab11-persist` was removed from and added back to the local `Administrators` group through an authorized Azure VM Run Command test. This generated Event ID 4733 for removal and a fresh Event ID 4732 for addition. The 4732 record was confirmed inside the 15-minute rule window before Sentinel created the High-severity incident.

### Expected result

- Event ID 4732 identifies the added member SID and `Administrators` group.
- The query returns the SID, group, host, timestamp, and event ID.
- Sentinel creates a High-severity alert and incident.
- The incident maps the Account by SID and the affected Host by computer name.

## Potential false positives

- Approved help-desk or administrator privilege assignment.
- Endpoint-management, deployment, or configuration tools.
- Break-glass or emergency maintenance activity.
- Application installation requiring a local administrator account.
- Authorized security testing or laboratory activity.

## Initial triage guidance

1. Confirm the member SID, target group, host, and timestamp.
2. Resolve the SID to a friendly identity using endpoint or directory data.
3. Identify the actor that performed the membership change.
4. Verify a related change request, deployment, or approved administration task.
5. Review Event ID 4733, account creation events, logons, and process execution around the same time.
6. Search for the same SID being added to privileged groups on other hosts.
7. Escalate unexplained additions or changes involving newly created accounts.

## Recommended response

- Remove unauthorized privileged-group membership.
- Disable or contain the account if compromise is suspected.
- Investigate the initiating user, host, and process.
- Review other privilege assignments and lateral movement indicators.
- Preserve evidence and document the authorization decision.

## Limitations and tuning

- Event ID 4732 may provide only a SID, requiring identity enrichment.
- The parser depends on the English `RenderedDescription` layout.
- Group-name localization and renamed administrator groups require additional handling.
- Production logic should allowlist approved management tools and maintenance workflows without broadly suppressing privileged changes.

## Change history

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-09-28 | Detection created and validated in LAB11 |
