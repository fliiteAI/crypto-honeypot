# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Wazuh Manager Configuration](#wazuh-manager-configuration)
3. [Wazuh Agent Configuration](#wazuh-agent-configuration)
    - [Linux Setup](#linux-setup)
    - [Windows Setup](#windows-setup)
    - [Containerized Deployment (Docker)](#containerized-deployment-docker)
4. [Browser Extension Path Mappings](#browser-extension-path-mappings)
5. [Honeypot Artifact Generation](#honeypot-artifact-generation)
6. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.

### Hardware Recommendations
For SMB environments, a **Raspberry Pi 4 (8GB)** or **Raspberry Pi 5** is highly recommended for running the Wazuh Manager. It provides a cost-effective, dedicated security appliance.

### Network Requirements
Ensure the following ports are open on the Wazuh Manager for agent communication:
- **1514 (TCP/UDP):** Agent event communication.
- **1515 (TCP):** Agent enrollment.

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
To automatically capture forensic data when a honeypot is accessed, the Wazuh Active Response feature can be used. The provided script performs a forensic snapshot (listing processes, network connections, and open files) when a honeypot rule triggers.

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
Add the honeypot monitoring paths to `/var/ossec/etc/ossec.conf` inside the `<syscheck>` block. Use wildcards to monitor all user directories:
```xml
<syscheck>
  <directories check_all="yes" report_changes="yes" realtime="yes" whodata="yes">/home/*/.bitcoin</directories>
  <directories check_all="yes" report_changes="yes" realtime="yes" whodata="yes">/home/*/.ethereum</directories>
  <!-- Add other paths as needed -->
</syscheck>
```
Alternatively, generate a configuration snippet:
```bash
honeypot-deployer wazuh-config --manifest ./path/to/manifest.json --os linux
```

#### 3. Install Audit Rules
Audit rules allow for high-fidelity read-access detection.
```bash
cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
sudo auditctl -R /etc/audit/rules.d/honeypot.rules
```

### Windows Setup

#### 1. Install Sysmon (Recommended)
Download and install [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon) with a configuration that includes the rules in `wazuh/agent-config/honeypot-sysmon.xml`. This provides visibility into which process accessed the honeyfiles.

#### 2. Configure FIM
Edit `C:\Program Files (x86)\ossec-agent\ossec.conf` and add the honeypot directories to the `<syscheck>` section.

### Containerized Deployment (Docker)

To run a Wazuh Agent within a Docker container while maintaining high-fidelity monitoring capabilities:

1. **Elevated Privileges:** The container must be run with `--cap-add=AUDIT_CONTROL` and `--pid=host` to allow `auditd` monitoring to work correctly.
2. **Identification:** Pass the `NODE_NAME` environment variable to uniquely identify the containerized agent in the Wazuh Manager.
3. **Volume Mounts:** Mount the directories containing honeypot artifacts as volumes into the container so the agent can monitor them.

```bash
docker run -d --name wazuh-agent \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -e WAZUH_MANAGER="192.168.1.100" \
  -e NODE_NAME="prod-web-server-docker" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /etc/audit:/etc/audit \
  wazuh/wazuh-agent:latest
```

---

## Browser Extension Path Mappings

Infostealer malware targets specific directories for browser extension wallets. The honeypot deploys decoys in these locations.

### Chrome, Edge, and Brave (Chromium-based)
These browsers store extension data in `Local Extension Settings` within the user's profile.

| OS | Base Path Template |
|----|--------------------|
| **Linux** | `~/.config/<browser>/Default/Local Extension Settings/<extension_id>` |
| **Windows** | `%LOCALAPPDATA%\<browser>\User Data\Default\Local Extension Settings\<extension_id>` |

**Common Extension IDs:**
- **MetaMask:** `nkbihfbeogaeaoehlefnkodbefgpgknn`
- **Phantom:** `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- **Coinbase Wallet:** `hnfanknocfeofbddgcijnmhnfnkdnaad`
- **TronLink:** `ibnejdfjmmkpcnlpebklmnkoeoihofec`
- **Binance Wallet:** `cadiboklkpojfamcoggejbbdjcoiljjk`

### Firefox
Firefox uses IndexedDB for extension storage, and the paths include a unique profile string.

| OS | Base Path Template |
|----|--------------------|
| **Linux** | `~/.mozilla/firefox/*.default*/storage/default/moz-extension+++<uuid>^userContextId=<id>` |
| **Windows** | `%APPDATA%\Mozilla\Firefox\Profiles\*.default*\storage\default\moz-extension+++<uuid>^userContextId=<id>` |

*Note: Honeypot decoys for Firefox utilize the `moz-extension+++` naming convention to appear authentic.*

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

### Manifest Security
The `manifest.json` contains the private keys for the generated honeypots. **Always keep this file secure.** Use the `--encrypt-manifest` flag (enabled by default) to protect it with a password.

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
