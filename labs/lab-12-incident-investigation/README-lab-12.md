# LAB12 — Microsoft Sentinel Incident Triage and Correlation

This lab continues the detections built in LAB11 and focuses on the analyst workflow after Microsoft Sentinel creates an incident. Two incidents were investigated from initial triage through evidence correlation, classification, and closure.

> **Scope:** all activity occurred in a controlled Azure lab. A known test origin was treated as a hypothesis to prove with telemetry, not as a reason to skip the investigation.

## Objectives

- Apply a repeatable incident-triage workflow in Microsoft Sentinel.
- Review alert evidence, mapped entities, MITRE ATT&CK context, and custom details.
- Correlate Windows Security events from the `Event` table.
- Correlate endpoint timestamps with Azure control-plane activity in `AzureActivity`.
- Identify the actor, target, affected host, sequence, and authorization context.
- Record investigation tasks and comments, then close incidents with evidence-based classifications.

## Lab environment

| Component | Lab value |
|---|---|
| SIEM | Microsoft Sentinel |
| Workspace | `law-secops-cc-01` |
| Host | `vm-win-cac-01` |
| Endpoint telemetry | Windows Security events in `Event` |
| Control-plane telemetry | Azure Activity Log in `AzureActivity` |
| Collection | Azure Monitor Agent and Data Collection Rule |
| Source detections | LAB11 scheduled analytics rules |
| Controlled execution method | Azure CLI and Azure VM Run Command |

## Investigation workflow

1. Open the incident and validate title, severity, status, owner, entities, and alert evidence.
2. Assign the incident, change it to **Active**, and create an investigation task.
3. Use the alert timestamp as the pivot for endpoint correlation.
4. Inspect the raw Windows events and correlate security identifiers and logon IDs.
5. Query `AzureActivity` to identify the initiating Azure identity and operation.
6. Compare identities, host, operation, and timestamps across both data planes.
7. Document the reasoning, complete the task, classify the incident, and close it.

The reusable investigation queries are stored in [`kql/lab12/`](../../kql/lab12/). Detailed case records are stored in [`incidents/`](../../incidents/).

## Case 1 — PowerShell spawned by Command Prompt

### Initial evidence

The medium-severity incident was created from Event ID 4688. Its alert showed:

- new process: `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`;
- parent process: `C:\Windows\System32\cmd.exe`;
- host: `vm-win-cac-01`;
- execution time: `2026-09-28T21:14:09.0597176Z`;
- MITRE ATT&CK: Execution / T1059.001.

The incident was assigned, moved from **New** to **Active**, and given a task to validate the process chain, account context, and authorization.

![Initial PowerShell incident triage](screenshots/01-lab12-powershell-incident-initial-triage.png)

![Alert details and process evidence](screenshots/02-lab12-alert-details-and-process-evidence.png)

![Investigation task created](screenshots/03-lab12-investigation-task-created.png)

### Windows Security correlation

The alert timestamp became the pivot for a ±10-minute query across Event IDs 4624, 4625, 4672, 4688, 4720, 4732, and 4733. The first screenshot preserves the query itself; the next preserves its result. Together they show how the incident time was converted into a reproducible investigation window instead of treating the alert as an isolated row.

![Incident timeline correlation query](screenshots/04-lab12-incident-timeline-correlation-query.png)

![Correlated Security events timeline](screenshots/05-lab12-correlated-security-events-timeline.png)

A focused correlation of Events 4624, 4672, and 4688 showed Security ID `S-1-5-18`, Logon ID `0x3E7`, and the machine account `vm-win-cac-01$`. Event 4624 identified a successful LOCAL SYSTEM service logon with an elevated token; Event 4672 recorded special privileges for the same session. This explained the process security context but did not by itself establish whether the action was authorized.

![Logon and special-privilege correlation](screenshots/06-lab12-logon-and-special-privileges-correlation.png)

![Focused logon and process correlation](screenshots/07-lab12-focused-logon-process-correlation.png)

### Azure control-plane correlation

`AzureActivity` showed an Azure VM Run Command operation initiated by the authorized lab identity. It started at 21:13:55 UTC, the PowerShell process appeared at 21:14:09 UTC, and the operation completed at 21:14:16 UTC. The matching resource, operation, and timestamps connected the Azure action to the endpoint event.

![Azure Run Command correlation](screenshots/08-lab12-azure-run-command-control-plane-correlation.png)

### Disposition

No unexpected identity, host, persistence, lateral movement, or malicious follow-on activity was found. The task was completed and the reasoning recorded in the incident. It was closed as **Benign Positive**, reason **Suspicious but expected**.

![Investigation comment and task completed](screenshots/09-lab12-investigation-comment-and-task-completed.png)

![Benign-positive classification](screenshots/10-lab12-benign-positive-classification.png)

![Incident closed after investigation](screenshots/11-lab12-incident-closed-after-investigation.png)

The complete case record is available in [`INC-001`](../../incidents/INC-001-powershell-run-command-investigation.md).

## Case 2 — Account added to local Administrators

### Initial evidence

The high-severity incident originated from Event ID 4732 and identified the local `Administrators` group, the affected host, membership-change time, and target account SID. Because privileged membership changes can provide persistence and elevation, the investigation needed to establish the account lifecycle and the actor responsible.

![Administrator membership initial triage](screenshots/12-lab12-administrator-membership-initial-triage.png)

![Administrator membership alert evidence](screenshots/13-lab12-administrator-membership-alert-evidence.png)

The incident was assigned, made **Active**, and given a task to validate Event ID 4732, correlate the SID with account creation, identify the actor, and determine authorization.

![Administrator investigation started](screenshots/14-lab12-administrator-incident-investigation-started.png)

### Account lifecycle correlation

The first query connected Event ID 4720 to 4732 and confirmed that the same synthetic account was created and later granted local administrator membership.

![Account creation to privilege correlation](screenshots/15-lab12-account-creation-to-privilege-correlation.png)

The investigation then expanded to Event IDs 4720, 4732, and 4733. It reconstructed the complete sequence: `lab11-persist` was created, added to `Administrators`, removed, and added again. The repeated target SID tied the events to one account rather than several unrelated changes.

![Privileged account membership lifecycle](screenshots/16-lab12-privileged-account-membership-lifecycle.png)

Parsing the Subject sections identified `vm-win-cac-01$`, `S-1-5-18`, and Logon ID `0x3E7` as the execution context. This showed what Windows recorded locally, but the Azure identity still had to be established from control-plane evidence.

![Privilege-change actor identification](screenshots/17-lab12-privileged-account-change-actor-identification.png)

### Azure control-plane correlation

The `AzureActivity` query found VM Run Command operations whose start and completion records aligned with the creation and group-membership events. This correlation explained the SYSTEM/machine-account context on Windows and linked the activity to the authorized lab identity that initiated the Azure operation.

![Privileged account Azure correlation](screenshots/18-lab12-privileged-account-azure-control-plane-correlation.png)

### Disposition

The detection correctly identified a high-risk privilege change, while the combined endpoint and Azure evidence demonstrated that the activity belonged to the controlled validation. The task was completed and the incident was closed as **Benign Positive**, reason **Suspicious but expected**.

![Privileged-account investigation completed](screenshots/19-lab12-privileged-account-investigation-completed.png)

![Privileged-account incident closed](screenshots/20-lab12-privileged-account-incident-closed.png)

The complete case record is available in [`INC-002`](../../incidents/INC-002-privileged-local-account-investigation.md).

## Findings

| Question | Finding |
|---|---|
| Did the analytics rules work? | Yes. Both incidents represented the intended Windows activity. |
| Was SYSTEM context automatically benign? | No. It became meaningful only after logon-session and Azure control-plane correlation. |
| Who initiated the actions? | The authorized lab identity through Azure VM Run Command. |
| Why did Windows show a machine/SYSTEM actor? | Run Command delivered the action to the guest and it executed under the VM agent's privileged context. |
| Was malicious follow-on activity observed? | No evidence was found in the investigated scope. |
| Final classification | Benign Positive — Suspicious but expected. |

## Lessons learned

- An alert is the beginning of the investigation, not the conclusion.
- Matching `S-1-5-18` or `0x3E7` explains Windows execution context but does not identify the human or cloud identity that initiated it.
- Endpoint and Azure control-plane telemetry answer different parts of the same question.
- Timestamp correlation is strongest when combined with resource, operation, identity, and event details.
- Event IDs 4720, 4732, and 4733 are more useful together because they reveal the account lifecycle.
- Tasks, comments, ownership, status, classification, and closure justification make the investigation reproducible for another analyst.
- A controlled test may still produce a true detection. **Benign Positive** means the rule correctly detected suspicious-looking but authorized activity; it is not a false positive caused by faulty logic.

## Production improvements

- Add identity enrichment for local SIDs and machine accounts.
- Enable richer process command-line and PowerShell telemetry.
- Include Sysmon or Microsoft Defender for Endpoint evidence when available.
- Correlate Run Command with approved change records and administrative allowlists.
- Search for network activity, child processes, persistence, and lateral movement before closure.
- Replace fixed timestamps and lab resource filters with incident parameters or hunting functions.
- Define investigation service levels and evidence requirements for each severity.

## Repository structure

```text
.
├── incidents/
│   ├── INC-001-powershell-run-command-investigation.md
│   └── INC-002-privileged-local-account-investigation.md
├── kql/
│   └── lab12/
│       ├── 01-powershell-security-event-correlation.kql
│       ├── 02-powershell-azure-activity-correlation.kql
│       ├── 03-privileged-account-lifecycle.kql
│       ├── 04-privileged-account-actor-identification.kql
│       └── 05-privileged-account-azure-activity-correlation.kql
└── labs/
    └── lab-12-incident-triage/
        ├── README-lab-12.md
        └── screenshots/
```

## Sanitization and future cleanup

Before public release, screenshots must mask personal email addresses, complete SIDs, incident URLs, alert IDs, correlation IDs, subscription IDs, and tenant-specific identifiers. Synthetic lab names may remain when needed to explain the evidence.

Azure resource cleanup was intentionally deferred because the environment may support future projects. When the lab is no longer needed, cleanup should be documented as a separate cost-control and decommissioning activity.
