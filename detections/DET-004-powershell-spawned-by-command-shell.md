# DET-004 — PowerShell Spawned by Command Shell

## Detection metadata

| Field | Value |
|---|---|
| Status | Enabled and validated in LAB11 |
| Platform | Microsoft Sentinel |
| Data source | Windows Security event log through Azure Monitor Agent and DCR |
| Log Analytics table | `Event` |
| Windows Event ID | `4688` — A new process was created |
| Severity | Medium |
| Query | [`kql/lab11/04-powershell-spawned-by-command-shell.kql`](../kql/lab11/04-powershell-spawned-by-command-shell.kql) |
| MITRE ATT&CK | Execution — T1059.001 Command and Scripting Interpreter: PowerShell |
| Lab evidence | [`labs/lab-11-detection-rule/README-lab-11.md`](../labs/lab-11-detection-rule/README-lab-11.md) |

## Objective

Detect `powershell.exe` launched by `cmd.exe` on a monitored Windows host. This process relationship can appear during interactive administration, scripts, remote execution, or adversary command execution and therefore requires contextual investigation.

## Detection logic

The query filters Security Event ID 4688, extracts the new process, creator process, and subject account from `RenderedDescription`, and retains events where:

- `NewProcessName` ends with `\powershell.exe`; and
- `ParentProcessName` ends with `\cmd.exe`.

The query returns the execution time, subject account, process paths, computer, and event ID.

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
| Account | Name | `SubjectAccount` |
| Host | HostName | `Computer` |

## Custom details

| Alert field | Query field |
|---|---|
| `ProcessName` | `NewProcessName` |
| `ParentProcess` | `ParentProcessName` |
| `ExecutionTime` | `TimeGenerated` |
| `WindowsEventID` | `EventID` |

## Validation

Azure VM Run Command launched a benign PowerShell command that printed the marker `LAB11-SuspiciousPowerShell` and returned Windows version information. Event ID 4688 reached Log Analytics, but the collected record did not contain the marker or a useful command line. The rule was therefore based on the process relationship actually observed: `cmd.exe` spawning `powershell.exe`.

The parser was initially tested over 24 hours and then validated again with the same 15-minute boundary used by the scheduled rule. A fresh controlled execution produced the expected alert and incident.

### Expected result

- Event ID 4688 shows PowerShell as the new process and Command Prompt as the creator process.
- The query returns the account, host, process paths, timestamp, and event ID.
- Sentinel creates a Medium-severity alert and incident.
- Process and parent-process values appear as custom details.

## Potential false positives

- Interactive administration and troubleshooting.
- Software installation or maintenance scripts.
- Endpoint-management and monitoring agents.
- Azure VM Run Command and other approved remote-administration tools.
- Logon scripts, scheduled tasks, or configuration-management workflows.

## Initial triage guidance

1. Confirm the account, host, process path, parent process, and execution time.
2. Review the full command line from enhanced audit, Sysmon, or EDR telemetry when available.
3. Identify whether the execution was interactive, scheduled, remotely initiated, or associated with an approved tool.
4. Search for encoded commands, execution-policy bypass, downloads, network connections, or suspicious child processes.
5. Review nearby logons, account changes, and privilege modifications.
6. Escalate unexplained PowerShell activity, particularly on critical hosts or under privileged accounts.

## Recommended response

- Isolate the endpoint if malicious execution is suspected.
- Terminate malicious processes only after preserving necessary evidence.
- Reset affected credentials and investigate related hosts or accounts.
- Collect PowerShell operational logs, command-line telemetry, and EDR evidence.
- Allowlist narrowly defined administrative workflows only after validation.

## Limitations and tuning

- The parent-child relationship alone is common and is not sufficient to establish malicious intent.
- The LAB11 Event ID 4688 data lacked the PowerShell command line and test marker.
- Production use should enable process command-line auditing and consider Sysmon or Microsoft Defender for Endpoint telemetry.
- Higher-fidelity logic should incorporate encoded commands, bypass flags, suspicious URLs, uncommon parents, unusual user context, and child-process behavior.
- The query contains a hard-coded lab-host filter that must be replaced with production scope.

## Change history

| Version | Date | Change |
|---|---|---|
| 1.0 | 2026-09-28 | Detection created and validated in LAB11 |
