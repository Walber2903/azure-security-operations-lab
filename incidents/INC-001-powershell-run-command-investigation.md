# INC-001 — PowerShell Run Command Investigation

## Summary

| Field | Value |
|---|---|
| Sentinel incident | LAB11 - PowerShell Spawned by Command Shell |
| Severity | Medium |
| Detection | Event ID 4688: `cmd.exe` spawned `powershell.exe` |
| Host | `vm-win-cac-01` |
| Disposition | Benign Positive |
| Classification reason | Suspicious but expected |

## Investigation question

Was the PowerShell process an unauthorized execution or an approved administrative action delivered through Azure?

## Evidence and analysis

The alert showed `C:\Windows\System32\cmd.exe` creating `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe` at `2026-09-28T21:14:09.0597176Z`.

Windows Security correlation identified Event IDs 4624, 4672, and 4688 in the same period. The creator was `vm-win-cac-01$` under Security ID `S-1-5-18` and Logon ID `0x3E7`. The matching 4624 and 4672 events established a LOCAL SYSTEM service session with an elevated token and assigned special privileges. These records explained the security context; they did not independently prove malicious privilege escalation.

The Azure control-plane query found a `Microsoft.Compute` virtual-machine Run Command operation initiated by the authorized lab identity. The operation began at 21:13:55 UTC, the process event occurred at 21:14:09 UTC, and the operation completed successfully at 21:14:16 UTC. The matching host, operation, identity, and timestamps connected the endpoint evidence to the authorized Azure action.

No unexpected identity, lateral movement, persistence, or malicious follow-on activity was identified.

## Conclusion

The analytics rule detected the intended process relationship correctly. The activity was authorized and generated during a controlled detection-validation exercise, so the incident was closed as **Benign Positive — Suspicious but expected**.

## Closure justification

> Authorized PowerShell execution generated through Azure VM Run Command during a controlled Sentinel detection validation exercise.

## Production lesson

`cmd.exe` spawning PowerShell is useful investigative context but can be noisy. Production triage should add command-line auditing, PowerShell logs, Sysmon or Defender for Endpoint telemetry, network behavior, and administrative allowlists.
