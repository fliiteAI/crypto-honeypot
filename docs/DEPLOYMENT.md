# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Wazuh Manager Configuration](#wazuh-manager-configuration)
3. [Wazuh Agent Configuration](#wazuh-agent-configuration)
    - [Linux Setup](#linux-setup)
    - [Windows Setup](#windows-setup)
4. [Honeypot Artifact Generation](#honeypot-artifact-generation)
5. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.
- **Hardware (Manager):** Raspberry Pi 4 (8GB) or 5 is highly recommended for SMB environments.
- **Network:**
    - Port **1514** (TCP/UDP) must be open for agent-manager event communication.
    - Port **1515** (TCP) must be open for agent enrollment.

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

### Containerized Deployment
If deploying the Wazuh agent within a Docker container:
- **Privileges:** The container must be run with `--cap-add=AUDIT_CONTROL` and `--pid=host` to support high-fidelity `whodata` monitoring via `auditd`.
- **Volumes:** Mount persistent volumes for artifact storage and Wazuh configuration to ensure persistence across container restarts.
- **Environment:** Pass the `NODE_NAME` environment variable to uniquely identify the agent in the Wazuh dashboard.

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

The agent configuration can be performed automatically using the `honeypot-deployer` CLI or manually using pre-defined templates.

### Automated Configuration (Recommended)
Use the `wazuh-config` command to generate localized FIM configuration snippets based on the actual artifacts listed in your deployment manifest:

```bash
honeypot-deployer wazuh-config --manifest ./path/to/manifest.json --os linux --output ./wazuh-config.xml
```

### Manual Configuration
Alternatively, you can manually copy templates from the `wazuh/agent-config/` directory.

### Linux Setup

#### 1. Install Auditd
`auditd` is required for high-fidelity "whodata" monitoring, which tracks *who* accessed a file.
```bash
sudo apt update && sudo apt install auditd -y
```

#### 2. Configure FIM
Add the honeypot monitoring paths to `/var/ossec/etc/ossec.conf` inside the `<syscheck>` block. Use the following attributes for optimal detection:
- `realtime="yes"`
- `whodata="yes"` (requires `auditd`)
- `check_all="yes"`
- `report_changes="yes"`

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

## Browser Extension Decoy Paths

To effectively trigger infostealers, decoys must be placed in the specific directories where browsers store extension data.

### Chrome, Edge, and Brave (Chromium-based)
These browsers use a similar LevelDB-based storage structure.

| Browser | OS | Path |
|---------|----|------|
| **Chrome** | Linux | `~/.config/google-chrome/Default/Local Extension Settings/` |
| **Chrome** | Windows | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\` |
| **Edge** | Windows | `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Local Extension Settings\` |
| **Brave** | Windows | `%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Local Extension Settings\` |

### Firefox
Firefox uses IndexedDB for extension storage, typically within profile-specific directories.

| Browser | OS | Path Pattern |
|---------|----|--------------|
| **Firefox** | Linux | `~/.mozilla/firefox/*.default*/storage/default/moz-extension+++<ID>^userContextId=<N>/idb/` |
| **Firefox** | Windows | `%APPDATA%\Mozilla\Firefox\Profiles\*.default*\storage\default\moz-extension+++<ID>^userContextId=<N>\idb\` |

### Supported Extension IDs
The honeypot currently supports decoys for:
- **MetaMask:** `nkbihfbeogaeaoehlefnkodbefgpgknn`
- **Phantom:** `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- **TronLink:** `ibnejdfjmmkpcnlpebklmnkoeoihofec`
- **Coinbase Wallet:** `hnfanknocfeofbddgcijnmhnfnkdnaad`
- **Binance Wallet:** `cadiboklkpojfamcoggejbbdjcoiljjk`

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
The `manifest.json` contains the private keys for the generated honeypots. **Always keep this file secure.** It is recommended to use the `--encrypt-manifest` flag (enabled by default) to protect it with a password.

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
