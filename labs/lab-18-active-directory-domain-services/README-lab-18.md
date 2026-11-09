# Lab 18 — Active Directory Domain Services, Security Administration, and Automation

## Overview

Lab 18 builds a small but realistic Microsoft Active Directory environment in Azure and administers it primarily through PowerShell and Azure VM Run Command.

The lab starts with a clean Windows Server deployment, promotes the first server to a domain controller, configures Active Directory-integrated DNS, joins a second Windows Server to the domain, creates an organizational structure, implements role-based security groups, applies a server security baseline through Group Policy, enables security telemetry, and introduces a Group Managed Service Account (gMSA).

The final environment is validated from both the domain controller and the member server with consolidated health-check scripts.

This lab intentionally focuses on **command-line administration, repeatability, validation, and troubleshooting**. Lab 19 will revisit many of the same concepts using native Windows graphical administration tools.

---

## Objectives

- Deploy a dedicated Windows Server domain controller.
- Configure the domain controller with a stable private IP.
- Install Active Directory Domain Services and DNS.
- Create a new forest and domain: `corp.secops.test`.
- Configure the Azure VNet to use the domain controller as its DNS server.
- Deploy and join a Windows Server member server to the domain.
- Create and organize Active Directory OUs.
- Create domain users and security groups.
- Implement role-based access using domain groups.
- Apply a security baseline to the Servers OU using Group Policy.
- Enable PowerShell Script Block Logging and Module Logging.
- Enable process creation auditing and command-line visibility.
- Validate Windows Security Event `4688`.
- Validate PowerShell Operational Event `4104`.
- Implement least-privilege local access.
- Create a KDS root key and a Group Managed Service Account.
- Install and validate the gMSA on the member server.
- Perform final domain controller and member server health checks.

---

## Environment

| Component | Configuration |
|---|---|
| Azure region | East US |
| Resource group | `rg-secops-eastus` |
| VNet | `vnet-secops-eus-01` |
| Server subnet | `snet-servers` — `10.40.1.0/24` |
| Management subnet | `snet-management` — `10.40.2.0/24` |
| Domain controller | `vm-dc-eus-01` |
| Domain controller IP | `10.40.1.4` |
| Member server | `vm-win-eus-01` |
| AD DNS domain | `corp.secops.test` |
| NetBIOS domain | `SECOPS` |
| Server GPO | `GPO-Servers-Security-Baseline` |
| gMSA | `svc-secops-hlth` |

> The RFC1918 addresses shown in this repository are private lab addresses and are not publicly routable.

---

## Architecture

```text
Azure Subscription
│
└── rg-secops-eastus
    │
    ├── vnet-secops-eus-01
    │   │
    │   ├── snet-servers (10.40.1.0/24)
    │   │   ├── vm-dc-eus-01
    │   │   │   ├── Active Directory Domain Services
    │   │   │   ├── DNS Server
    │   │   │   └── corp.secops.test
    │   │   │
    │   │   └── vm-win-eus-01
    │   │       └── Domain member server
    │   │
    │   └── snet-management (10.40.2.0/24)
    │
    └── nsg-secops-servers-eus
```

The Azure VNet uses `10.40.1.4` as its custom DNS server so domain members can discover Active Directory services through DNS.

---

# Part 1 — Azure Infrastructure Foundation

## Resource Group and Network

The East US lab environment was placed in a dedicated resource group and VNet.

The VNet was segmented into separate server and management subnets to preserve a clean network design and allow future expansion.

![Resource group](screenshots/01_resource_group_eastus_created.png)

![VNet and subnets](screenshots/02_vnet_and_subnets_eastus.png)

---

## Network Security Group

A dedicated Network Security Group was associated with the server subnet.

The initial configuration intentionally relied on Azure's default VNet rules rather than opening public inbound access.

![NSG rules](screenshots/04_nsg_default_security_rules.png)

![NSG subnet association](screenshots/05_nsg_associated_with_snet_servers.png)

This design keeps the lab servers private while allowing communication between resources inside the virtual network.

---

# Part 2 — Domain Controller Deployment

## Windows Server Deployment

The domain controller was deployed as a Windows Server 2022 Azure Edition VM using Trusted Launch, Secure Boot, and vTPM.

No public IP address or public inbound port was configured.

![DC review](screenshots/06_review_create_vm_dc_eastus.png)

![DC deployment complete](screenshots/07_vm_dc_eastus_deployment_complete.png)

---

## Static Private IP

The domain controller's Azure NIC was configured with a static private IP:

```text
10.40.1.4
```

A stable address is especially important for a domain controller that also provides DNS services.

![Static IP](screenshots/08_dc_private_ip_static.png)

---

## Pre-AD Baseline

Before installing Active Directory, the server identity, networking, time configuration, and Windows feature state were captured.

![Pre-AD baseline](screenshots/09_dc_pre_ad_baseline.png)

This baseline creates a clear before/after comparison and confirms that AD DS and DNS were not already installed.

---

# Part 3 — Active Directory Domain Services and DNS

## Installing AD DS and DNS

The required Windows Server roles were installed through PowerShell:

- Active Directory Domain Services
- DNS Server
- AD DS management tools

![AD DS and DNS installed](screenshots/10_ad_ds_dns_roles_installed.png)

---

## Creating the Forest

The first server was promoted into a new forest:

```text
Domain:  corp.secops.test
NetBIOS: SECOPS
```

After promotion, the domain controller was validated by checking:

- domain membership;
- domain role;
- AD domain information;
- domain controller discovery;
- DNS, Netlogon, and NTDS services;
- SYSVOL and NETLOGON shares.

![DC promotion validation](screenshots/11_domain_controller_promotion_validation.png)

---

## Active Directory DNS Validation

DNS is a core dependency of Active Directory.

The lab validated:

- the domain DNS record;
- the domain controller record;
- LDAP SRV discovery;
- DNS, Netlogon, and NTDS service health.

![AD DNS validation](screenshots/12_ad_dns_resolution_validation.png)

The Azure VNet was then configured to use the domain controller as its custom DNS server.

![VNet custom DNS](screenshots/12_vnet_custom_dns_domain_controller.png)

This is important because Active Directory clients locate domain controllers through DNS SRV records rather than by simply knowing a server IP.

---

# Part 4 — Windows Domain Member

## Member Server Deployment

A second Windows Server VM was deployed into the same server subnet with no public IP.

![Member VM review](screenshots/13_review_create_windows_domain_member.png)

![Member VM deployment](screenshots/14_windows_domain_member_deployment_complete.png)

---

## Pre-Domain-Join Validation

Before attempting the domain join, the member server validated:

- its current workgroup/domain status;
- the configured DNS server;
- resolution of `corp.secops.test`;
- resolution of the domain controller;
- TCP connectivity to DNS port `53`;
- TCP connectivity to LDAP port `389`.

![Pre-domain-join validation](screenshots/15_windows_member_pre_domain_join_validation.png)

This prevents a common Active Directory troubleshooting mistake: attempting to join a domain before confirming DNS and LDAP connectivity.

---

## Domain Join and Secure Channel

After the domain join and restart, the member server confirmed:

- `PartOfDomain = True`;
- domain controller discovery;
- Active Directory site discovery;
- a healthy computer-account secure channel.

![Domain join validation](screenshots/16_windows_member_domain_join_validation.png)

---

# Part 5 — Active Directory Organizational Structure

## Organizational Units

The following OUs were created:

```text
corp.secops.test
│
├── Corp-Users
├── Groups
├── Servers
└── Service-Accounts
```

The built-in `Domain Controllers` OU remains managed separately.

![OU structure](screenshots/17_active_directory_organizational_units_created.png)

OUs are primarily administrative and policy boundaries. They do not automatically grant permissions simply because an object is placed inside them.

---

## Server Placement

The computer account for `vm-win-eus-01` was moved from the default `Computers` container into the `Servers` OU.

![Server moved to OU](screenshots/18_windows_member_moved_to_servers_ou.png)

This becomes important later because the server security baseline GPO is linked to this OU.

---

# Part 6 — Domain Users and Security Groups

## Domain Users

Three controlled lab identities were created:

| User | Account | Purpose |
|---|---|---|
| Alyce Johnson | `alyce` | SecOps administrator |
| Bob Smith | `bob` | SecOps analyst |
| Grace Lee | `grace` | IT support |

![Domain users](screenshots/19_active_directory_domain_users_enabled.png)

---

## Role-Based Security Groups

Three global security groups were used:

```text
GG-SecOps-Admins
GG-SecOps-Analysts
GG-IT-Support
```

The role mapping was:

```text
Alyce Johnson
└── GG-SecOps-Admins

Bob Smith
└── GG-SecOps-Analysts

Grace Lee
└── GG-IT-Support
```

The important concept is that permissions are assigned to **groups**, while users receive access through group membership.

This produces a cleaner and more scalable administrative model than granting permissions directly to individual users.

---

# Part 7 — Group Policy Security Baseline

## Servers OU Baseline

A Group Policy Object named:

```text
GPO-Servers-Security-Baseline
```

was created and linked to:

```text
OU=Servers,DC=corp,DC=secops,DC=test
```

![GPO details](screenshots/20_gpo_security_baseline_details.png)

The link was enabled but not forced with the `Enforced` option. This is expected: a normal enabled link is sufficient for this lab.

---

## Validating GPO Application

On the member server, Group Policy was refreshed and validated with `gpresult`.

The baseline applied successfully alongside the Default Domain Policy.

![GPO applied](screenshots/21_gpo_security_baseline_applied.png)

![GPResult validation](screenshots/22_gpresult_detailed_validation.png)

The lab also configured an interactive logon notice:

```text
Authorized Access Only
```

and a security message identifying the system as part of the controlled SecOps lab.

---

# Part 8 — PowerShell and Process Telemetry

## PowerShell Logging

The server baseline enabled:

- PowerShell Script Block Logging;
- PowerShell Module Logging.

![PowerShell logging](screenshots/23_powershell_logging_policy_validation.png)

PowerShell Operational Event ID `4104` was then validated.

![Event 4104](screenshots/24_powershell_4104_event_validation.png)

Event `4104` provides valuable script-block telemetry for detection engineering and incident investigation.

---

## Process Creation Auditing

Process creation auditing was enabled so Windows Security Event ID `4688` could be used for process execution visibility.

Command-line inclusion was also enabled.

Controlled commands were generated to create known telemetry:

```text
whoami
Get-Date
hostname
```

![Process audit configuration](screenshots/25_process_creation_audit_configuration.png)

![Controlled activity](screenshots/26_controlled_process_creation_activity.png)

![Event 4688](screenshots/27_process_creation_4688_validation.png)

This connects traditional Windows administration directly to SOC telemetry and threat detection.

---

# Part 9 — Role-Based Local Access and Least Privilege

## SecOps Administrators

The Active Directory group:

```text
SECOPS\GG-SecOps-Admins
```

was added to the member server's local `Administrators` group.

![Local administrators](screenshots/28_local_administrators_validation.png)

Alyce was separately validated as a member of the SecOps administrator group.

![Admin validation](screenshots/29_role_based_admin_validation.png)

The resulting privilege chain is:

```text
Alyce
  ↓
GG-SecOps-Admins
  ↓
Local Administrators
  ↓
Administrative privileges
```

---

## IT Support

`GG-IT-Support` was added to:

```text
Remote Desktop Users
```

but was intentionally not granted local administrator rights.

![IT support RDP access](screenshots/30_it_support_rdp_access_validation.png)

This demonstrates a practical least-privilege model:

```text
Grace
  ↓
GG-IT-Support
  ↓
Remote Desktop Users
  ↓
Remote access without local administrator rights
```

---

## SecOps Analysts

`GG-SecOps-Analysts` received neither local administrator nor Remote Desktop membership.

![Analyst least privilege](screenshots/31_secops_analyst_least_privilege_validation.png)

The analyst role therefore remains a standard non-privileged identity unless additional permissions are explicitly assigned.

---

# Part 10 — Group Managed Service Account

## Why gMSA?

A Group Managed Service Account allows Windows services or scheduled workloads to use a domain identity without administrators manually managing the account password.

Active Directory and the Key Distribution Service manage the account password lifecycle.

---

## KDS Root Key

The environment initially had no KDS root key.

![KDS initial state](screenshots/32_kds_root_key_initial_state.png)

A KDS root key was then created for the lab.

![KDS key created](screenshots/33_kds_root_key_creation.png)

Because this is a single-domain-controller lab, a backdated effective time was used for immediate testing. That shortcut should not be treated as the normal production deployment process for a multi-DC environment.

---

## gMSA Troubleshooting

An initial gMSA attempt exposed an important Active Directory compatibility constraint:

> The `sAMAccountName` attribute has a 15-character legacy limit.

The original service account name exceeded this constraint.

![Initial gMSA error](screenshots/34_gmsa_creation_initial_error.png)

The corrected name was:

```text
svc-secops-hlth
```

Further validation confirmed that the account existed in the `Service-Accounts` OU and that `vm-win-eus-01` was authorized to retrieve its managed password.

![gMSA existence](screenshots/36_gmsa_existence_validation.png)

![Authorized host](screenshots/37_gmsa_authorized_host_validation.png)

---

## Installing the gMSA on the Member Server

The first member-server attempt revealed another realistic dependency:

```text
Import-Module ActiveDirectory
```

failed because the Active Directory PowerShell module was not installed on the member server.

This also meant that:

```text
Install-ADServiceAccount
Test-ADServiceAccount
```

were unavailable.

![Initial member gMSA error](screenshots/38_gmsa_member_install_initial_error.png)

The fix was to install:

```powershell
Install-WindowsFeature RSAT-AD-PowerShell
```

After installing the module, the gMSA was successfully installed and tested.

![gMSA operational](screenshots/40_gmsa_member_operational_validation.png)

The final result:

```text
Test-ADServiceAccount result: True
```

---

# Part 11 — Final Health Checks

## Domain Controller

The final DC health check confirmed:

- correct domain controller identity;
- Global Catalog role;
- DNS, Netlogon, and NTDS running;
- domain and forest health;
- DNS resolution;
- OU structure;
- domain users;
- security group membership;
- member-server OU placement;
- GPO linkage;
- gMSA state and authorized host.

![DC health check](screenshots/41_domain_controller_final_health_check.png)

---

## Member Server

The final member-server health check confirmed:

- successful domain membership;
- domain controller discovery;
- healthy secure channel;
- DNS pointed at the DC;
- successful domain resolution;
- server GPO applied;
- Script Block Logging enabled;
- Module Logging enabled;
- process creation auditing enabled;
- command-line auditing enabled;
- role-based local groups correctly configured;
- recent Event `4104` telemetry;
- recent Event `4688` telemetry;
- operational gMSA.

![Member health check](screenshots/42_member_server_final_health_check.png)

---

# Final State

The completed environment provides a compact Active Directory security administration lab:

```text
corp.secops.test
│
├── Domain Controllers
│   └── vm-dc-eus-01
│
├── Corp-Users
│   ├── Alyce Johnson
│   ├── Bob Smith
│   └── Grace Lee
│
├── Groups
│   ├── GG-SecOps-Admins
│   ├── GG-SecOps-Analysts
│   └── GG-IT-Support
│
├── Servers
│   └── vm-win-eus-01
│       └── GPO-Servers-Security-Baseline
│
└── Service-Accounts
    └── svc-secops-hlth
```

Role-based access:

```text
Alyce
→ GG-SecOps-Admins
→ Local Administrators

Grace
→ GG-IT-Support
→ Remote Desktop Users

Bob
→ GG-SecOps-Analysts
→ No privileged local membership
```

---

# Security Concepts Demonstrated

This lab connects multiple Windows infrastructure and security concepts:

- Active Directory Domain Services
- Active Directory-integrated DNS
- DNS-based domain controller discovery
- Domain joins and secure channels
- Organizational Units
- Global security groups
- Group-based authorization
- Least privilege
- Group Policy
- Windows auditing
- PowerShell logging
- Event IDs `4104` and `4688`
- KDS
- Group Managed Service Accounts
- Managed service identities
- Administrative validation and health checks
- Azure private networking
- Infrastructure troubleshooting

---

# Troubleshooting Lessons

Several issues in this lab were intentionally preserved as technical lessons.

### Active Directory depends on DNS

Domain discovery and domain joins were only attempted after validating DNS and LDAP connectivity.

### Run Command is non-interactive

Azure Run Command is useful for automation, but commands that normally prompt for credentials or passwords must be supplied through non-interactive script logic.

Secrets should never be stored in the repository.

### OU placement and permissions are separate concepts

Moving a user or computer into an OU does not automatically grant privileges.

OUs provide organization and Group Policy scope.

Security groups provide authorization.

### Group Policy does not need to be Enforced to work

The server GPO was linked and enabled with:

```text
Enforced: False
```

and still applied successfully.

### Legacy limits still matter

The first gMSA name exceeded the 15-character `sAMAccountName` limit.

The corrected account name was shortened to:

```text
svc-secops-hlth
```

### Member servers require the AD PowerShell tools for gMSA administration

`Install-ADServiceAccount` and `Test-ADServiceAccount` were unavailable until `RSAT-AD-PowerShell` was installed.

---

# Scripts

The `scripts/` directory contains reusable PowerShell examples for each major phase:

```text
00_pre_ad_baseline.ps1
01_install_ad_ds_dns.ps1
02_promote_new_forest.ps1
03_validate_domain_controller.ps1
04_validate_ad_dns.ps1
05_validate_member_before_domain_join.ps1
06_join_member_server_to_domain.ps1
07_validate_domain_membership.ps1
08_create_organizational_units.ps1
09_move_member_server_to_servers_ou.ps1
10_create_domain_users.ps1
11_create_security_groups_and_memberships.ps1
12_create_server_security_gpo.ps1
13_validate_gpo_on_member.ps1
14_validate_powershell_logging.ps1
15_enable_and_validate_process_creation_auditing.ps1
16_configure_role_based_local_access.ps1
17_validate_role_based_access.ps1
18_create_kds_root_key.ps1
19_create_gmsa.ps1
20_install_and_validate_gmsa_on_member.ps1
21_final_dc_health_check.ps1
22_final_member_server_health_check.ps1
```

Passwords and other credentials are intentionally represented by placeholders.

---

# Next Lab

**Lab 19** will extend this environment using the native Windows Server graphical administration tools.

The goal is to connect the PowerShell-based administration demonstrated here with the GUI equivalents, including:

- Server Manager;
- Active Directory Users and Computers;
- Group Policy Management;
- DNS Manager;
- Computer Management;
- Event Viewer.

Lab 19 will also expand the Active Directory structure with additional OUs and object-management tasks to demonstrate hierarchy, privilege assignment, and day-to-day administration from both the automation and GUI perspectives.
