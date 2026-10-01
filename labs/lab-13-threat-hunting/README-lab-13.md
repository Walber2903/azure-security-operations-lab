# Lab 13 — Microsoft Sentinel Threat Hunting

## Objective

Build and document a hypothesis-driven threat hunt in Microsoft Sentinel using Windows process-creation telemetry. The hunt focuses on PowerShell and CMD execution, parent-child process relationships, account/host context, command-line visibility, and the validation of a telemetry gap discovered during investigation.

This lab continues the detection and incident-investigation work from the previous labs, but changes the analyst workflow from **alert-driven investigation** to **proactive hunting**.

## Threat-hunting hypothesis

> Windows command-line interpreters, particularly PowerShell and CMD, may be executed in suspicious contexts without necessarily crossing an existing analytics-rule threshold.

The investigation therefore asks:

- Which accounts are launching PowerShell or CMD?
- Which parent processes are responsible for those executions?
- Is the full command line available for investigation?
- Can the observed activity be explained by expected system or lab behavior?
- Is the collected telemetry sufficient to support future investigations?

## Environment

- Microsoft Sentinel
- Log Analytics workspace
- Windows VM: `vm-win-cac-01`
- Windows Security Event ID `4688` — process creation
- Kusto Query Language (KQL)
- Microsoft Sentinel Hunts and Bookmarks
- MITRE ATT&CK: **Execution / T1059 — Command and Scripting Interpreter**

## Investigation workflow

### 1. Review the Sentinel hunting surface

The lab started by reviewing the available Microsoft Sentinel hunting content and identifying queries relevant to the telemetry currently available in the workspace.

![Sentinel Hunting overview](screenshots/01_sentinel_hunting_overview.png)

![Available hunting queries](screenshots/02_sentinel_hunting_queries.png)

### 2. Create a custom command-interpreter hunting query

A custom query was created around Windows Event ID `4688`. XML fields from `EventData` were parsed so the hunt could expose the account, SID, new process, parent process, process IDs, and command line.

The query focuses on `powershell.exe` and `cmd.exe`, maps the host and account entities, and aligns the hunt with the MITRE ATT&CK **Execution** tactic and **T1059** technique.

![Custom hunting query configuration](screenshots/03_custom_hunting_query_configuration.png)

![Custom hunting query created](screenshots/04_custom_hunting_query_created.png)

The reusable query is available at [`kql/lab13/01_command_interpreter_execution.kql`](../../kql/lab13/01_command_interpreter_execution.kql).

### 3. Validate results and pivot on process ancestry

The initial hunt returned multiple PowerShell and CMD executions. Rather than treating interpreter execution itself as malicious, the investigation pivoted into execution context and parent-child process relationships.

![Command interpreter hunt validation](screenshots/05_command_interpreter_hunt_validation.png)

A summary query grouped executions by account, parent process, and whether command-line arguments were available.

![Process parent summary](screenshots/06_process_parent_summary.png)

A deeper PowerShell pivot highlighted parent processes such as `CompatTelRunner.exe`, supporting further contextual investigation rather than immediate escalation.

![PowerShell parent-process pivot](screenshots/07_powershell_compattelrunner_pivot.png)

Reusable queries:

- [`02_process_parent_summary.kql`](../../kql/lab13/02_process_parent_summary.kql)
- [`03_powershell_parent_process_pivot.kql`](../../kql/lab13/03_powershell_parent_process_pivot.kql)

### 4. Identify a telemetry gap

During the hunt, PowerShell process creation was visible, but command-line arguments were missing from some Event ID `4688` records. This was an important finding because process names alone provide significantly less context during triage.

![Process creation command-line gap](screenshots/08_process_creation_commandline_gap.png)

The Windows process-creation command-line auditing setting was then enabled.

![Command-line auditing enabled](screenshots/09_commandline_auditing_enabled.png)

### 5. Validate the telemetry improvement

A controlled PowerShell execution containing the marker `LAB13-HUNT-TEST` was generated after the auditing change. The resulting Event ID `4688` record successfully included the complete command line.

![Command-line telemetry validation](screenshots/10_commandline_telemetry_validation.png)

A before/after query confirmed that the dataset now contained process executions with command-line telemetry available.

![Command-line visibility before and after](screenshots/11_commandline_visibility_before_after.png)

The controlled-event query is stored in [`04_controlled_validation_event.kql`](../../kql/lab13/04_controlled_validation_event.kql).

### 6. Create a hypothesis-driven Sentinel Hunt

The investigation was formalized as a Microsoft Sentinel Hunt named:

**Windows Command-Line Interpreter Threat Hunt**

The hunt documented the hypothesis, investigation scope, telemetry gap, and the improvement made during the investigation.

![Threat hunt configuration](screenshots/12_threat_hunt_configuration.png)

![Threat hunt created](screenshots/13_threat_hunt_created.png)

### 7. Link and execute the hunting query

The custom command-interpreter query was linked to the Hunt and executed against the Windows telemetry.

![Hunt query linked](screenshots/14_hunt_query_linked.png)

![Hunt query execution results](screenshots/15_hunt_query_execution_results.png)

The controlled PowerShell execution was then isolated as supporting evidence.

![Controlled PowerShell event](screenshots/16_controlled_powershell_event.png)

### 8. Preserve evidence with a Sentinel Bookmark

The controlled validation event was saved as a hunting bookmark. Event time and entities were mapped so the evidence retained useful investigation context.

Mapped entities:

- **Host:** `vm-win-cac-01`
- **Account:** `secopsadmin`

The bookmark was tagged for command-line telemetry and controlled validation.

![Controlled validation bookmark configuration](screenshots/17_controlled_validation_bookmark_configuration.png)

![Hunt bookmark with entities](screenshots/18_hunt_bookmark_with_entities.png)

### 9. Close the hunt

The original hypothesis of suspicious command-interpreter activity was **not validated**. The reviewed activity did not provide evidence of malicious command execution.

The hunt nevertheless produced a useful defensive finding: a telemetry visibility gap was discovered and corrected. Full process command-line collection was enabled and validated, improving the quality of future threat hunting and incident investigation.

The Hunt was therefore closed with the hypothesis marked **Invalidated**, with no incident escalation required.

![Hunt conclusion](screenshots/19_hunt_conclusion_closed_invalidated.png)

## Findings

| Finding | Assessment |
|---|---|
| Multiple PowerShell and CMD executions were present | Required contextual investigation; interpreter execution alone was not treated as malicious |
| Parent-child process relationships were available | Useful for distinguishing expected and unusual execution paths |
| Some Event ID 4688 records lacked command-line arguments | Telemetry gap identified |
| Process command-line auditing was enabled | Visibility improvement implemented |
| `LAB13-HUNT-TEST` was captured with its full command line | Telemetry improvement successfully validated |
| Host and account entities were mapped in the bookmark | Investigation context preserved |
| Evidence of malicious command execution | Not identified during this hunt |
| Hunt outcome | Hypothesis invalidated; no incident escalation required |

## Why the hunt still mattered

A threat hunt does not need to end with a confirmed compromise to be useful. In this case, the hunt improved the environment itself.

The investigation moved through a realistic security-operations cycle:

**Hypothesis → Hunt → Pivot → Telemetry gap → Configuration improvement → Controlled validation → Evidence preservation → Conclusion**

The most important outcome was not an alert. It was better visibility for the next investigation.

## Skills practiced

- Microsoft Sentinel Threat Hunting
- Hypothesis-driven investigation
- KQL development and XML field extraction
- Windows Security Event ID 4688 analysis
- PowerShell and CMD process analysis
- Parent-child process investigation
- Windows command-line auditing
- Telemetry-gap identification
- Controlled security validation
- Sentinel entity mapping
- Sentinel Bookmarks
- MITRE ATT&CK mapping (`Execution`, `T1059`)
- Hunt documentation and closure

## Repository artifacts

```text
labs/lab-13-threat-hunting/
├── README-lab-13.md
└── screenshots/
    ├── 01_sentinel_hunting_overview.png
    ├── 02_sentinel_hunting_queries.png
    ├── 03_custom_hunting_query_configuration.png
    ├── 04_custom_hunting_query_created.png
    ├── 05_command_interpreter_hunt_validation.png
    ├── 06_process_parent_summary.png
    ├── 07_powershell_compattelrunner_pivot.png
    ├── 08_process_creation_commandline_gap.png
    ├── 09_commandline_auditing_enabled.png
    ├── 10_commandline_telemetry_validation.png
    ├── 11_commandline_visibility_before_after.png
    ├── 12_threat_hunt_configuration.png
    ├── 13_threat_hunt_created.png
    ├── 14_hunt_query_linked.png
    ├── 15_hunt_query_execution_results.png
    ├── 16_controlled_powershell_event.png
    ├── 17_controlled_validation_bookmark_configuration.png
    ├── 18_hunt_bookmark_with_entities.png
    └── 19_hunt_conclusion_closed_invalidated.png

kql/lab13/
├── 01_command_interpreter_execution.kql
├── 02_process_parent_summary.kql
├── 03_powershell_parent_process_pivot.kql
└── 04_controlled_validation_event.kql
```

## Key takeaway

The strongest result of this lab was the transition from simply querying logs to running a complete threat-hunting lifecycle. The hunt tested a hypothesis, investigated process ancestry, exposed an observability weakness, corrected it, validated the change with controlled telemetry, preserved evidence in a bookmark, and documented a defensible conclusion.
