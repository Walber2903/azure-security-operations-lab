# Lab 09 — Lessons Learned

## 1. Solution installation and data connection are separate

Installing Azure Activity from Content Hub deploys reusable Sentinel content, but telemetry is not ingested until the data connector pipeline is configured.

## 2. Azure Activity is subscription-level telemetry

The policy assignment was scoped to the subscription because the Activity Log records Azure control-plane operations at that level. A resource-group-only scope would not represent the intended collection boundary.

## 3. Policy operations are asynchronous

Assignment creation, policy evaluation, remediation, diagnostic-setting deployment, compliance calculation, connector health, and data arrival do not update simultaneously. Each stage needs its own validation.

## 4. Validate the pipeline at multiple layers

The strongest validation combined:

1. Policy assignment and remediation status.
2. CLI confirmation of the subscription diagnostic setting.
3. Records in the `AzureActivity` table.
4. Connected state and recent log timestamp on the connector.
5. Final 100% policy compliance.

## 5. Controlled events improve evidence quality

Adding a harmless validation tag generated a recognizable `MICROSOFT.RESOURCES/TAGS/WRITE` event. This provided clearer proof than waiting for unrelated background operations.

## 6. Public KQL evidence should minimize identifiers

The public query projected operational fields and intentionally excluded `Caller`, correlation identifiers, and subscription identifiers. This preserved analytical value while reducing exposure.
