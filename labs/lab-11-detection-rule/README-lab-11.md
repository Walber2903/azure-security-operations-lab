# LAB11 — Microsoft Sentinel Scheduled Analytics Rules

This hands-on project documents the complete path from generating controlled Windows activity in Azure to investigating the resulting incidents in Microsoft Sentinel. Four Windows Security use cases were implemented as scheduled analytics rules, validated in Log Analytics, and reviewed through their alerts, entities, timelines, MITRE ATT&CK mappings, and custom details.

> **Scope:** this is a controlled learning environment created for Microsoft Sentinel and KQL practice. It demonstrates hands-on implementation and troubleshooting, not production administration experience.

## Project summary

The lab began with Windows Security events already being collected from an Azure VM through Azure Monitor Agent and a Data Collection Rule. The work then followed the same cycle for each detection:

1. Create a safe, observable action on the Windows VM.
2. Confirm that Windows generated the expected event ID.
3. Find the event in the Log Analytics `Event` table.
4. Develop and test the KQL detection.
5. Create a scheduled analytics rule in Microsoft Sentinel.
6. Configure frequency, lookback, threshold, grouping, suppression, entities, and custom details.
7. Wait for ingestion and rule execution.
8. Open the resulting incident and validate its investigative context.

The recorded validation session ran for approximately **2 hours and 25 minutes**, from the first failed-logon alert validation to the final PowerShell incident. This excludes the earlier deployment of the workspace, agent, Data Collection Rule, and Windows audit configuration.

## Architecture and data flow

```mermaid
flowchart LR
    A[Controlled activity<br/>Azure Windows VM] --> B[Windows Security log]
    B --> C[Azure Monitor Agent<br/>and DCR]
    C --> D[Log Analytics<br/>Event table]
    D --> E[Sentinel scheduled<br/>analytics rule]
    E --> F[Alert and incident]
    F --> G[Entities, timeline,<br/>MITRE and custom details]
```

| Component | Lab value |
|---|---|
| SIEM | Microsoft Sentinel |
| Workspace | `law-secops-cc-01` |
| Monitored host | `vm-win-cac-01` |
| Operating system | Windows Server 2022 Datacenter Azure Edition |
| Log source | Windows Security event log |
| Query table | `Event` |
| Collection | Azure Monitor Agent and Data Collection Rule |
| Rule frequency | Every 5 minutes |
| Rule lookback | Previous 15 minutes |
| Test execution | Azure CLI and Azure VM Run Command |

## Detection coverage

| Rule | Event | Severity | Detection intent | MITRE ATT&CK |
|---|---:|---|---|---|
| Multiple Failed Windows Logons | 4625 | Medium | Five or more failed logons for the same account and host | Credential Access / T1110 |
| Local User Account Created | 4720 | Medium | Creation of a local Windows account | Persistence / T1136.001 |
| User Added to Local Administrators | 4732 | High | Addition of an account to the local Administrators group | Persistence and Privilege Escalation |
| PowerShell Spawned by Command Shell | 4688 | Medium | `cmd.exe` launches `powershell.exe` | Execution / T1059.001 |

The final reusable queries are stored in [`queries/`](queries/). They are kept separate so they can be copied, tested, and versioned independently.

## How the activity was generated safely

No malicious payload, external target, or exploitation technique was used. Activity was limited to the dedicated lab VM and generated through **Azure VM Run Command**, invoked from Azure Cloud Shell with `az vm run-command invoke`. Azure delivered short PowerShell scripts to the VM, and Windows produced the corresponding native Security events.

| Scenario | Controlled action | Expected evidence |
|---|---|---|
| Failed logons | Repeated authentication attempts using an intentionally incorrect password | Event ID 4625 |
| Account creation | `New-LocalUser` created the synthetic account `lab11-persist` | Event ID 4720 |
| Privileged-group membership | The synthetic account was removed from and added back to local `Administrators` | Event IDs 4733 and 4732 |
| Process execution | A benign PowerShell command returned basic Windows version information | Event ID 4688 showing `cmd.exe` → `powershell.exe` |

The account and marker existed only for the lab. Removing and re-adding the account to `Administrators` intentionally generated a fresh 4732 record inside the analytics rule's 15-minute window after the rule was corrected.

## Investigation 1 — Multiple failed Windows logons

### Detection logic

The first query filters Security Event ID 4625, extracts the failed account from `RenderedDescription`, and aggregates by account and computer. Only groups with at least five failures are returned. It also calculates the first and last observation timestamps.

The rule was configured to:

- run every 5 minutes;
- inspect the previous 15 minutes;
- alert when the query returned more than zero rows;
- map Account and Host entities;
- expose `FailedLogons`, `FirstSeen`, and `LastSeen` as custom details;
- group matching activity into an incident;
- suppress execution for 20 minutes after an alert.

### Validation and investigation

The KQL result confirmed exactly five failures for the same account and VM. After the scheduled rule executed, Sentinel created the incident and exposed the mapped account and host. A second alert was later associated with the same incident, demonstrating how overlapping query windows and incident grouping appear in the timeline.

![Scheduled analytics rule enabled](screenshots/01-lab11-scheduled-analytics-rule-enabled.png)

![Incident created with mapped entities](screenshots/02-lab11-incident-created-with-mapped-entities.png)

![Five failed logons within the rule window](screenshots/03-lab11-five-failed-logons-within-rule-window.png)

![Multiple alerts grouped in one incident](screenshots/04-lab11-alert-grouping-within-single-incident.png)

![Alert entities and MITRE ATT&CK mapping](screenshots/05-lab11-alert-details-entities-and-mitre.png)

![Alert custom details](screenshots/06-lab11-alert-custom-details-validation.png)

![Final rule configuration](screenshots/07-lab11-analytics-rule-final-configuration.png)

## Investigation 2 — Local user account creation

### Controlled execution

Azure VM Run Command executed a short PowerShell script on the VM. The first synthetic username exceeded the Windows local-account name limit, which caused `New-LocalUser` to fail. The test was corrected to use `lab11-persist`, and the command then completed successfully.

This troubleshooting step mattered: a successful Azure Run Command status alone did not prove that the intended Windows action occurred. The Security event was independently verified in Log Analytics before relying on the analytics rule.

### Detection and incident validation

The rule filters Event ID 4720 and extracts the new account from the `New Account` section of `RenderedDescription`. It maps the account and host, then adds the created account, creation time, and Windows event ID as custom details. The incident confirmed the synthetic account, monitored host, Persistence tactic, and T1136.001 technique.

![Local account creation event](screenshots/08-lab11-local-account-creation-event.png)

![Local account creation rule configuration](screenshots/09-lab11-local-account-creation-rule-configuration.png)

![Local account creation incident](screenshots/10-lab11-local-account-creation-incident.png)

## Investigation 3 — User added to local Administrators

### Query correction and fresh-event generation

The initial parsing attempted to use a friendly account name from Event ID 4732. In this dataset, the reliable member identifier was the SID. The query and entity mapping were corrected to use `AccountSid`, while the group name was extracted separately and restricted to `Administrators`.

After saving the corrected rule, the existing event was outside the effective detection window. The test account was safely removed from and added back to `Administrators`, producing a 4733 removal event followed by a fresh 4732 addition event. The 4732 record was confirmed in Log Analytics before waiting for Sentinel to run the rule.

### Incident validation

The resulting high-severity incident showed the host entity, Account entity mapped by SID, the `Administrators` group, membership-change timestamp, and Event ID 4732. Persistence and Privilege Escalation were both visible in the incident.

![Administrator membership events](screenshots/11-lab11-administrator-membership-events.png)

![Administrator membership incident](screenshots/12-lab11-administrator-membership-incident.png)

![Administrator membership rule configuration](screenshots/13-lab11-administrator-membership-rule-configuration.png)

## Investigation 4 — PowerShell spawned by Command Prompt

### Controlled execution

A benign PowerShell test was launched through Azure VM Run Command. The script printed the marker `LAB11-SuspiciousPowerShell` and returned the Windows product name and version. Its purpose was only to create observable process activity on the lab host.

The original assumption was that the marker or full command line would be available inside Event ID 4688. The event reached Log Analytics, but its `RenderedDescription` did not contain the marker or a useful command-line field. Instead of claiming the original detection worked, the investigation pivoted to the process relationship actually present in the telemetry:

```text
C:\Windows\System32\cmd.exe
└── C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
```

### Detection and incident validation

The final query extracts `NewProcessName`, `ParentProcessName`, and `SubjectAccount`, then requires PowerShell to be the new process and Command Prompt to be the parent. KQL was first tested over 24 hours to troubleshoot parsing, then rerun with a 15-minute boundary to reproduce the scheduled rule's behavior. After a fresh controlled execution, the result appeared inside that window and Sentinel created the incident.

The incident confirmed:

- Event ID 4688;
- PowerShell as the new process;
- `cmd.exe` as the parent process;
- the monitored host and subject account entities;
- the Execution tactic and PowerShell technique;
- process paths and execution time as custom details.

![PowerShell process creation event](screenshots/14-lab11-powershell-process-creation-event.png)

![PowerShell detection query validation](screenshots/15-lab11-powershell-detection-query-validation.png)

![PowerShell detection within the 15-minute rule window](screenshots/16-lab11-powershell-detection-within-rule-window.png)

![PowerShell spawned by command shell incident](screenshots/17-lab11-powershell-command-shell-incident.png)

## What was validated in the Sentinel interface

The lab was not considered complete when a KQL query merely returned data. Each use case was followed through the relevant Sentinel views:

- **Logs:** raw-event availability, field parsing, time range, and final query output;
- **Analytics:** enabled-rule status and final configuration review;
- **Set rule logic:** KQL, entity mapping, custom details, query schedule, threshold, event grouping, and suppression;
- **Review + create:** end-to-end validation before saving the rule;
- **Incidents:** severity, status, alert count, creation time, and associated analytics rule;
- **Incident overview:** timeline, grouped alerts, mapped entities, similar incidents, and investigation context;
- **Alert details:** MITRE ATT&CK classification, process or account attributes, Windows event ID, and custom details.

## Troubleshooting lessons

| Observation | Cause | Resolution |
|---|---|---|
| Account-creation command reported an error | Initial username exceeded the local Windows name limit | Used `lab11-persist` and confirmed Event ID 4720 |
| `CreatedAccounts` could not be resolved | Only part of a multi-statement KQL query was evaluated | Ran the complete query, including `let CreatedAccounts = ...` |
| Correct KQL returned no rows | Matching event was outside the rule's effective time window | Generated a fresh controlled event and validated the same 15-minute boundary |
| Friendly member name was unreliable in 4732 | Event exposed the member consistently as a SID | Parsed and mapped `AccountSid` instead |
| PowerShell marker was absent from 4688 | Command-line auditing was unavailable in the collected record | Used the observed parent-child process relationship |
| Similar 4688 events were plentiful over 24 hours | `cmd.exe` launching PowerShell can be legitimate and common | Restricted validation to the rule window and documented production noise |

## Production considerations

This lab proved the mechanics of collection, KQL detection, rule configuration, and incident investigation. The rules should not be copied into production without further engineering:

- Remove the hard-coded host filter or replace it with an approved asset scope or watchlist.
- Tune failed-logon thresholds by account type, source, host criticality, and normal authentication volume.
- Enrich SIDs with identity data and distinguish expected administrators from unexpected privilege changes.
- Enable process command-line auditing and consider Sysmon or Microsoft Defender for Endpoint telemetry.
- Improve PowerShell detection with encoded-command, bypass, download, suspicious-child-process, and allowlist logic.
- Review ingestion delay, execution delay, grouping, reopening behavior, and suppression against the SOC workflow.
- Convert mature rules to infrastructure as code and maintain test cases and version history.
- Add automation rules or playbooks only after alert quality and response ownership are defined.

## Key outcomes

- Built four scheduled Sentinel detections using native Windows Security telemetry.
- Practiced KQL extraction from semi-structured `RenderedDescription` data.
- Validated the difference between interactive time range and scheduled-rule lookback.
- Mapped Account and Host entities using both friendly names and SIDs.
- Added analyst-ready custom details to incidents.
- Observed alert grouping, suppression, duplicate-window behavior, and incident timelines.
- Troubleshot command execution, KQL scope, parsing, time-window, and telemetry limitations.
- Followed every detection from controlled activity to a reviewable Sentinel incident.

## Sanitization

Incident URLs, system alert identifiers, and the complete local-account SID were removed from the public evidence. Lab resource names and synthetic account names were intentionally retained because they are required to understand the detection flow. No credentials, real user identities, production tenant information, or malicious payloads are included.
