# Lab 09 — Evidence Register

| # | Evidence | Purpose | Sanitization |
| ---: | --- | --- | --- |
| 01 | `01-microsoft-sentinel-onboarding-and-free-trial.png` | Confirms Sentinel onboarding and trial activation. | No secret identifiers visible. |
| 02 | `02-sentinel-workspace-connected-to-defender-portal.png` | Confirms Defender portal connection and primary workspace. | No secret identifiers visible. |
| 03 | `03-sentinel-workspace-and-onboarding-cli-validation.png` | Confirms workspace properties and Sentinel onboarding state. | Commands avoid printing the workspace resource ID. |
| 04 | `04-azure-activity-solution-installed.png` | Confirms Content Hub solution installation. | Account email hidden. |
| 05 | `05-azure-activity-data-connector-before-configuration.png` | Records the connector baseline before configuration. | No secret identifiers visible. |
| 06 | `06-azure-activity-policy-assignment-review.png` | Records policy scope, parameters, remediation, and managed identity. | Subscription GUID hidden. |
| 07 | `07-azure-activity-policy-assignment-created.png` | Confirms assignment, role assignment, and remediation creation. | Subscription GUIDs hidden. |
| 08 | `08-azure-activity-policy-remediation-completed.png` | Confirms remediation completion for one resource. | No secret identifiers visible. |
| 09 | `09-azure-activity-diagnostic-setting-cli-validation.png` | Confirms diagnostic-setting destination. | Subscription GUID hidden. |
| 10 | `10-azure-activity-events-kql-query.png` | Confirms detailed event ingestion, including the controlled tag write. | Tenant/account text hidden; query excludes `Caller`. |
| 11 | `11-azure-activity-events-kql-summary.png` | Summarizes ingested event count and statuses. | Tenant/account text hidden. |
| 12 | `12-azure-activity-data-connector-connected.png` | Confirms connected status and data received. | No secret identifiers visible. |
| 13 | `13-azure-activity-policy-compliant.png` | Confirms 100% policy compliance. | Subscription GUIDs hidden. |

All evidence belongs in `labs/lab-09-microsoft-sentinel/screenshots/`.
