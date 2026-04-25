# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Network Requirements](#network-requirements)
3. [Wazuh Manager Configuration](#wazuh-manager-configuration)
4. [Wazuh Agent Configuration](#wazuh-agent-configuration)
    - [Linux Setup](#linux-setup)
    - [Windows Setup](#windows-setup)
5. [Browser Extension Path Mappings](#browser-extension-path-mappings)
6. [Honeypot Artifact Generation](#honeypot-artifact-generation)
7. [Containerized Deployment](#containerized-deployment)
8. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.

### Hardware Recommendations (Wazuh Manager)
For SMB environments, we recommend running the Wazuh Manager on:
- **Raspberry Pi 4 (8GB RAM)** or **Raspberry Pi 5**.
- High-endurance microSD card or USB 3.0 SSD for storage.

### Endpoint Requirements
#### Linux
- **Python:** 3.10+ (required for running the `honeypot-deployer` CLI).
- **Packages:** `auditd` (essential for `whodata` FIM support and user attribution).
- **Permissions:** Root/sudo access for installing audit rules and modifying Wazuh configuration.

#### Windows
- **Operating System:** Windows 10/11 or Windows Server 2016+.
- **PowerShell:** 5.1 or higher.
- **Sysmon:** Recommended for enhanced process-level visibility.
- **Permissions:** Administrator privileges for modifying Wazuh configuration and deploying artifacts.

---

## Network Requirements

The following ports must be open between the Wazuh Agents and the Wazuh Manager:

| Port | Protocol | Description |
|------|----------|-------------|
| 1514 | TCP/UDP  | Agent event communication (Secure Messaging) |
| 1515 | TCP      | Agent enrollment |

If you are using Wazuh Active Response or remote commands, ensure bidirectional connectivity on port 1514.

---

## Wazuh Manager Configuration

Before deploying agents, the Wazuh Manager must be configured to recognize honeypot-specific logs and trigger alerts.

### 1. Install Decoders
Copy the custom decoders to your Wazuh Manager:
```bash
cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/
```

### 2. Install Rules
Copy the custom rules to your Wazuh Manager:
```bash
cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/
```

### 3. (Optional) Active Response
To automatically capture forensic data when a honeypot is accessed:
```bash
cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
```
Configure the active response in your `ossec.conf` on the manager.

### 4. Restart Wazuh Manager
```bash
systemctl restart wazuh-manager
```

---

## Wazuh Agent Configuration

### Linux Setup

#### 1. Install Auditd
`auditd` is required for high-fidelity "whodata" monitoring, which tracks *who* accessed a file.
```bash
sudo apt update && sudo apt install auditd -y
```

#### 2. Configure FIM
Add the honeypot monitoring paths to `/var/ossec/etc/ossec.conf` inside the `<syscheck>` block.

For multi-user systems, you can use wildcards in the configuration:
```xml
<directories check_all="yes" whodata="yes" realtime="yes" report_changes="yes">/home/*/.bitcoin</directories>
```

You can use the template at `wazuh/agent-config/ossec-honeypot-fim.conf` or generate a custom one based on your manifest:
```bash
honeypot-deployer wazuh-config --manifest ./path/to/manifest.json --os linux
```

#### 3. Install Audit Rules
```bash
cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
sudo auditctl -R /etc/audit/rules.d/honeypot.rules
```

### Windows Setup

#### 1. Install Sysmon (Recommended)
Download and install [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon) with a configuration that includes the rules in `wazuh/agent-config/honeypot-sysmon.xml`.

#### 2. Configure FIM
Edit `C:\Program Files (x86)\ossec-agent\ossec.conf` and add the honeypot directories to the `<syscheck>` section.

---

## Browser Extension Path Mappings

Infostealers target specific directories where browser extensions store their local data. Deploying honeypot artifacts to these locations maximizes the chance of detection.

### Common Extension IDs
- **MetaMask:** `nkbihfbeogaeaoehlefnkodbefgpgknn`
- **Phantom:** `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- **TronLink:** `ibnejdfjmmkpcnlpebklmnkoeoihofec`
- **Coinbase Wallet:** `hnfanknocfeofbddgcijnmhnfnkdnaad`
- **Binance Wallet:** `cadiboklkpojfamcoggejbbdjcoiljjk`

### Linux Paths
- **Chrome:** `~/.config/google-chrome/Default/Local Extension Settings/<ID>`
- **Brave:** `~/.config/BraveSoftware/Brave-Browser/Default/Local Extension Settings/<ID>`
- **Edge:** `~/.config/microsoft-edge/Default/Local Extension Settings/<ID>`
- **Firefox:** `~/.mozilla/firefox/*.default*/storage/default/moz-extension+++<ID>`

### Windows Paths
- **Chrome:** `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\<ID>`
- **Brave:** `%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Local Extension Settings\<ID>`
- **Edge:** `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Local Extension Settings\<ID>`
- **Firefox:** `%APPDATA%\Mozilla\Firefox\Profiles\*.default*\storage\default\moz-extension+++<ID>`

---

## Honeypot Artifact Generation

There are two ways to deploy honeypot artifacts: using the `honeypot-deployer` CLI (recommended) or using standalone deployment scripts.

### Option A: Using the CLI (Recommended)
The CLI generates unique, randomized artifacts and tracks them in an encrypted manifest for high-fidelity monitoring and on-chain correlation.

```bash
# 1. Install the tool
pip install .

# 2. Generate artifacts
honeypot-deployer generate --output ./my-artifacts

# 3. View the generated manifest
honeypot-deployer show --manifest ./my-artifacts/manifest.json
```

### Option B: Standalone Scripts
For quick deployments without installing the Python package, you can use the provided shell and PowerShell scripts. These create a standard set of honeyfiles.

**Linux:**
```bash
chmod +x deploy.sh
./deploy.sh
```

**Windows:**
```powershell
.\deploy.ps1
```

---

## Containerized Deployment

If you are running the Wazuh Agent inside a Docker container, ensure the following:

1. **Volume Mounting:** Mount the host's honeypot paths into the container.
2. **Auditd Support:** The container must have access to the host's audit system. Run the container with:
   ```bash
   docker run --cap-add=AUDIT_CONTROL --pid=host ...
   ```
3. **Environment Variables:** Set the `NODE_NAME` to distinguish between multiple containerized agents.

---

## Deployment Verification

1. **Verify Artifacts:** Run the health check command:
   ```bash
   honeypot-deployer health-check --manifest ./my-artifacts/manifest.json
   ```
2. **Trigger a Test Alert:**
   On a Linux agent: `cat ~/.bitcoin/wallet.dat`
   On a Windows agent: `type %APPDATA%\Bitcoin\wallet.dat`
3. **Check Wazuh Dashboard:** Confirm that a Level 12 (or higher) alert appears in the security events.
