# RCA — Controlled Windows Service Startup Failure (Lab 19)

**Case ID:** LAB19-SVC-001  
**Date:** November 23, 2026  
**System:** `vm-win-eus-01` (isolated lab member server)  
**Component:** `Lab19HealthSvc` / Windows Service Control Manager  
**Severity:** Informational — intentionally induced, not a production incident  
**Status:** Closed; temporary test artifact removed

## Incident statement

A newly created, manually started test service (`Lab19HealthSvc`) failed to enter the Running state. The failure was intentionally induced for Windows service diagnosis practice. PowerShell `Start-Service` produced a startup error and subsequent inspection confirmed the service remained `Stopped`.

## Evidence and observed timeline

| Sequence | Source | Observation |
|---|---|---|
| 1 | `sc.exe create` / CIM | Service created; path `C:\Windows\System32\svchost.exe`; Manual; Stopped |
| 2 | `services.msc` | Service registered but not running |
| 3 | PowerShell `Start-Service` | Startup failed; `CouldNotStartService` |
| 4 | System log, SCM **7045** | New service installation registered, with account `LocalSystem` |
| 5 | System log, SCM **7009** | 30,000-ms timeout waiting for the service to connect |
| 6 | System log, SCM **7000** | Service failed to start; screenshot contains Windows error code `%%1053` |
| 7 | `sc.exe delete` / final inspection | `DeleteService SUCCESS`, absent from follow-up query; five core services still Running |

Screenshots: [29](screenshots/lab19-29-service-configuration-inspection.png), [30](screenshots/lab19-30-service-properties-gui.png), [31](screenshots/lab19-31-service-start-failure.png), [32](screenshots/lab19-32-service-installation-event7045.png), [33](screenshots/lab19-33-service-timeout-event7009.png), [34](screenshots/lab19-34-service-failure-event7000.png), [35](screenshots/lab19-35-service-remediation-validation.png).

## Root-cause assessment

**Most likely cause (design-based):** The demonstration service pointed directly at `svchost.exe` but was not configured as a valid DLL-backed service with the relevant Service Control Manager contract and service DLL metadata. `svchost.exe` is not a drop-in replacement for an ordinary Windows service executable. Without valid service initialization and reporting, the SCM cannot observe the expected startup handshake within the timeout window.

**Corroborating signs:** The path and registration were visible in CIM/Services/7045, while 7009 and 7000 showed a timeout/startup failure, matching the behavior of a service that does not complete startup signaling. This is a **well-supported diagnosis**, not a debugger-proven trace of the exact code path. No binary debugging or service-DLL inspection was performed.

## Impact and scope

Only the temporary lab service was affected. No production workload was present, and no existing Windows service was modified to create the failure. Checks after cleanup showed `WinRM`, `EventLog`, `gpsvc`, `Dnscache`, and `W32Time` all running. The exercise did not establish application availability or uptime metrics.

## Resolution

1. Verified the service was stopped.
2. Removed its service registration using `sc.exe delete Lab19HealthSvc`.
3. Confirmed that the test service was not returned by a follow-up lookup.
4. Removed `C:\Lab19`.
5. Revalidated the running state of the five core services.

**Why not repair and run the test service?** The purpose was to demonstrate fault isolation and cleanup, not to deploy a new Windows service. A properly implemented service would require a compliant service executable or correct hosted-service DLL registration, neither of which was in this lab's scope.

## Lessons and prevention

- Differentiate `7045` (installation), `7009` (startup timeout), and `7000` (start failure); correlate times and service names rather than treating each as a separate incident.
- Check service `PathName`, account, start mode, SCM events, and actual service implementation before adjusting timeout values.
- Avoid increasing service timeout as a first response when a service binary is incorrectly defined.
- Make controlled changes reversible, keep a before/after evidence trail, and verify that critical dependent services remain healthy.

## Validation command set

```powershell
Get-CimInstance Win32_Service -Filter "Name='Lab19HealthSvc'" |
    Select-Object Name, DisplayName, State, StartMode, PathName
Get-WinEvent -FilterHashtable @{ LogName='System'; Id=7045,7009,7000 } -MaxEvents 50 |
    Where-Object Message -Match 'Lab19 Health Service|Lab19HealthSvc' |
    Select-Object TimeCreated, Id, Message
Get-Service -Name WinRM, EventLog, gpsvc, Dnscache, W32Time |
    Select-Object Name, Status
```

**Caveat:** The displayed Event Viewer errors were reproduced successfully in an intentionally flawed configuration; this exercise does not imply that an existing healthy service failed spontaneously.
