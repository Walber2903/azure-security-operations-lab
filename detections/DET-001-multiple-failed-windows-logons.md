# DET-001 — Multiple Failed Windows Logons

## Detection metadata

| Field | Value |
|---|---|
| Status | Enabled and validated in LAB11 |
| Platform | Microsoft Sentinel |
| Data source | Windows Security event log through Azure Monitor Agent and DCR |
| Log Analytics table | `Event` |
| Windows Event ID | `4625` — An account failed to log on |
| Severity | Medium |
| Query | [`kql/lab11/01-multiple-failed-windows-logons.kql`](../kql/lab11/01-multiple-failed-windows-logons.kql) |
| MITRE ATT&CK | Credential Access — T1110 Brute Force |
| Lab evidence | [`labs/lab-11-detection-rule/README-lab-11.md`](../labs/lab-11-detection-rule/README-lab-11.md) |

## Objective

Detect repeated failed Windows authentication attempts against the same account and host. Multiple failures in a short period may indicate password guessing, brute force, misuse of stale credentials, or a misconfigured service.

## Detection logic

The query filters Security Event ID 4625 on the monitored Windows host, extracts the failed account from `RenderedDescription`, and groups the records by account and computer. A result is returned when at least five failures occur within the rule lookback window.

The aggregation also produces:

- `FailedLogons` — number of failures;
- `FirstSeen` — first failure in the window;
- `LastSeen` — most recent failure in the window.

## Sentinel rule configuration

| Setting | Configuration |
|---|---|
| Run query every | 5 minutes |
| Look up data from the last | 15 minutes |
| Alert threshold | Query results greater than 0 |
| Event grouping | Group all query results into a single alert |
| Suppression | Enabled for 20 minutes after alert generation |
| Incident creation | Enabled |
| Incident grouping | Enabled using mapped entities |

## Entity mapping

| Entity | Identifier | Query field |
|---|---|---|
| Account | Name | `Account` |
| Host | HostName | `Computer` |

## Custom details

| Alert field | Query field |
|---|---|
| `FailedLogonCount` | `FailedLogons` |
| `FirstObserved` | `FirstSeen` |
| `LastObserved` | `LastSeen` |

## Validation

A controlled test generated five failed authentication events for the same synthetic account and lab VM. The KQL query returned one aggregated result with `FailedLogons = 5`. The scheduled rule subsequently created a Sentinel alert and incident containing the Account and Host entities.

### Expected result

- At least five Event ID 4625 records exist inside 15 minutes.
- The query returns the affected account, computer, count, and timestamps.
- Sentinel generates a Medium-severity alert.
- The incident exposes the mapped Account and Host entities.

## Potential false positives

- A user repeatedly entering an incorrect password.
- Stored credentials remaining after a password change.
- Scheduled tasks, services, scripts, mapped drives, or applications using an expired password.
- Vulnerability scanners or approved authentication testing.
- Temporary synchronization or authentication problems.

## Initial triage guidance

1. Confirm the account, host, count, and event timestamps.
2. Review surrounding successful logons, especially Event ID 4624.
3. Determine whether failures originated from an expected user, service, or administration workflow.
4. Check for similar failures involving other accounts or hosts.
5. Review account lockout events and identity-provider telemetry when available.
6. Escalate if failures are unexplained, distributed, followed by a successful logon, or associated with a privileged account.

## Recommended response

- Contact the account owner when appropriate.
- Reset or rotate credentials if compromise is suspected.
- Disable or restrict the account when risk warrants containment.
- Investigate the source host and related authentication activity.
- Correct stale service or application credentials when the activity is benign.

## Limitations and tuning

- The LAB11 query contains a hard-coded lab host filter and must be adapted before reuse.
- Event ID 4625 alone does not prove malicious activity.
- Production tuning should consider account type, source address, logon type, host criticality, normal failure volume, and privileged-account status.
- Overlapping lookback windows may return the same events more than once; grouping and suppression should match the SOC workflow.

## Change history

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-09-28 | Detection created and validated in LAB11 |
