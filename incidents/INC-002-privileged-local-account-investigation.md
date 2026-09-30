# INC-002 — Privileged Local Account Investigation

## Summary

| Field | Value |
|---|---|
| Sentinel incident | LAB11 - User Added to Local Administrators |
| Severity | High |
| Detection | Event ID 4732: member added to local `Administrators` |
| Host | `vm-win-cac-01` |
| Target account | `lab11-persist` |
| Disposition | Benign Positive |
| Classification reason | Suspicious but expected |

## Investigation question

Was a privileged local account created or modified without authorization, and which identity performed the changes?

## Evidence and analysis

The investigation reconstructed the account lifecycle rather than evaluating the 4732 alert in isolation:

| UTC time | Event ID | Activity |
|---|---:|---|
| 20:05:41 | 4720 | Local account `lab11-persist` created |
| 20:20:14 | 4732 | Account added to local `Administrators` |
| 20:47:04 | 4733 | Account removed from local `Administrators` |
| 20:47:04 | 4732 | Account added again to local `Administrators` |

The events referenced the same target SID. Parsing the Subject section identified `vm-win-cac-01$`, Security ID `S-1-5-18`, and Logon ID `0x3E7`, showing that the changes were executed under LOCAL SYSTEM on the monitored VM.

`AzureActivity` showed corresponding Microsoft Compute Run Command operations initiated by the authorized lab identity. Start, acceptance, and success records aligned with the account creation and membership-change timestamps. This control-plane evidence explained why the endpoint recorded the machine/SYSTEM context rather than the human Azure identity.

No unauthorized Azure identity, unexpected host, lateral movement, or malicious follow-on activity was found.

## Conclusion

The high-severity detection correctly identified a security-relevant privilege change. The evidence demonstrated that it was an authorized lab action, so the incident was closed as **Benign Positive — Suspicious but expected**.

## Closure justification

> Authorized local account creation and Administrators group membership changes performed through Azure VM Run Command during a controlled Sentinel detection validation exercise.

## Production lesson

Event ID 4732 often exposes the member reliably as a SID. Production investigations should enrich that SID, validate the actor, correlate preceding account creation and subsequent logons, and verify the change against approved administration records.
