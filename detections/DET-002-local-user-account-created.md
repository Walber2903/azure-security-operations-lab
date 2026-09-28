# DET-002 — Local User Account Created

## Detection metadata

| Field | Value |
|---|---|
| Status | Enabled and validated in LAB11 |
| Platform | Microsoft Sentinel |
| Data source | Windows Security event log through Azure Monitor Agent and DCR |
| Log Analytics table | `Event` |
| Windows Event ID | `4720` — A user account was created |
| Severity | Medium |
| Query | [`kql/lab11/02-local-user-account-created.kql`](../kql/lab11/02-local-user-account-created.kql) |
| MITRE ATT&CK | Persistence — T1136.001 Create Account: Local Account |
| Lab evidence | [`labs/lab-11-detection-rule/README-lab-11.md`](../labs/lab-11-detection-rule/README-lab-11.md) |

## Objective

Detect the creation of a local Windows account on a monitored host. Unexpected local accounts can provide persistent access that is independent of centralized identity controls.

## Detection logic

The query filters Security Event ID 4720 and extracts the new account name from the `New Account` section of `RenderedDescription`. Empty extraction results are removed, and each valid result returns the creation timestamp, account, host, and event ID.

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
| Account | Name | `TargetAccount` |
| Host | HostName | `Computer` |

## Custom details

| Alert field | Query field |
|---|---|
| `CreatedAccount` | `TargetAccount` |
| `CreationTime` | `TimeGenerated` |
| `WindowsEventID` | `EventID` |

## Validation

Azure VM Run Command executed a controlled PowerShell script using `New-LocalUser` to create the synthetic account `lab11-persist`. An initial name exceeded the Windows local-account length limit and failed; the shorter test name succeeded. Event ID 4720 was confirmed in Log Analytics before the rule-generated incident was reviewed.

### Expected result

- Event ID 4720 appears for the newly created account.
- The query returns `TargetAccount`, `Computer`, `TimeGenerated`, and `EventID`.
- Sentinel generates a Medium-severity alert and incident.
- Account and Host entities match the controlled activity.

## Potential false positives

- Approved local administrator or service-account provisioning.
- Operating-system deployment or imaging workflows.
- Configuration-management and endpoint-management tools.
- Application installation that creates a local service account.
- Authorized troubleshooting or laboratory activity.

## Initial triage guidance

1. Confirm the new account, host, and creation time.
2. Identify the subject account or process responsible for the creation using the raw event and related process telemetry.
3. Check whether the account follows naming, ownership, and approval standards.
4. Review subsequent group-membership changes, logons, password changes, and process execution.
5. Determine whether the host is managed through an approved provisioning tool.
6. Escalate unexplained or unauthorized accounts, especially on critical systems.

## Recommended response

- Disable or remove an unauthorized account.
- Preserve relevant Windows and endpoint evidence before remediation.
- Reset credentials and review privileges when compromise is suspected.
- Investigate the creating user, process, and any subsequent activity.
- Document and allowlist approved automated provisioning where appropriate.

## Limitations and tuning

- The LAB11 query is scoped to a single lab host.
- The parser depends on the English `RenderedDescription` layout.
- Production detection should enrich the creating subject, account SID, domain, and endpoint criticality.
- Organizations with frequent authorized local-account creation should use allowlists or approved change data.

## Change history

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-09-28 | Detection created and validated in LAB11 |
