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
  - **Hardware Recommendation:** Raspberry Pi 4 (8GB) or Raspberry Pi 5.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.

### Endpoint Requirements
#### Linux
- **Python:** 3.10+ (required for running the `honeypot-deployer` CLI).
- **Packages:** `auditd` (essential for high-fidelity `whodata` FIM support and user attribution).
- **Permissions:** Root/sudo access for installing audit rules and modifying Wazuh configuration.
- **File Permissions:** Honeyfolders should be set to `700` and honeyfiles to `600`.

#### Windows
- **Operating System:** Windows 10/11 or Windows Server 2016+.
- **PowerShell:** 5.1 or higher.
- **Sysmon:** Recommended for enhanced process-level visibility and DNS query monitoring.
- **Permissions:** Administrator privileges for modifying Wazuh configuration and deploying artifacts.
- **File Permissions:** Restricted access (Full Control for the user, none for others).

---

## Wazuh Manager Configuration

Before deploying agents, the Wazuh Manager must be configured to recognize honeypot-specific logs, trigger alerts, and optionally execute active responses.

### 1. Install Decoders
Copy the custom decoders to your Wazuh Manager:
```bash
cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/
```

### 2. Install Rules
Copy the custom rules to your Wazuh Manager. These rules include detections for file access (100501-100503), rapid multi-file access (100511), and network-capable process interaction (100520).
```bash
cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/
```

### 3. (Optional) Active Response
Active Response allows the system to automatically react to threats. For example, it can capture a forensic snapshot or drop the attacker's IP.

**Install Forensic Snapshot Script:**
```bash
cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
```

**Configure Active Response in `ossec.conf`:**
Add the configuration from `wazuh/agent-config/ossec-active-response.conf` to your manager's `/var/ossec/etc/ossec.conf`. This enables:
- Automated forensic snapshots on any honeypot alert.
- Temporary IP blocking (`firewall-drop`) when infostealer or exfiltration patterns are detected.

### 4. (Optional) Log Collection for Chain Monitoring
To ingest logs from the chain monitor service, add the directives from `wazuh/agent-config/ossec-log-collector.conf` to the manager's `ossec.conf`.

### 5. Restart Wazuh Manager
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

**Important:** On Linux, use `whodata="yes"` for all honeypot directories to ensure user attribution in alerts.

You can use the template at `wazuh/agent-config/ossec-honeypot-fim.conf` or generate a custom one:
```bash
honeypot-deployer wazuh-config --manifest ./path/to/manifest.json --os linux
```

#### 3. Install Audit Rules
Audit rules provide process-level visibility and are required for `whodata` monitoring.
```bash
# Copy and edit to replace 'USER' with actual username
cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
sudo auditctl -R /etc/audit/rules.d/honeypot.rules
```

#### 4. Browser Extension Path Mappings
The honeypot monitors specific extension IDs for popular wallets:
- **MetaMask:** `nkbihfbeogaeaoehlefnkodbefgpgknn`
- **Phantom:** `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- **TronLink:** `ibnejdfjmmkpcnlpebklmnkoeoihofec`
- **Coinbase Wallet:** `hnfanknocfeofbddgcijnmhnfnkdnaad`
- **Binance Wallet:** `cadiboklkpojfamcoggejbbdjcoiljjk`

**Linux Paths:**
- **Chrome:** `~/.config/google-chrome/Default/Local Extension Settings/<ID>`
- **Brave:** `~/.config/BraveSoftware/Brave-Browser/Default/Local Extension Settings/<ID>`
- **Firefox:** `~/.mozilla/firefox/*.default*/storage/default/moz-extension+++<UUID>^userContextId=<ID>`

### Windows Setup

#### 1. Install Sysmon (Recommended)
Sysmon is highly recommended for process-level visibility and DNS query correlation.
1. Download [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon).
2. Merge the configuration rules from `wazuh/agent-config/honeypot-sysmon.xml` into your Sysmon configuration.

#### 2. Configure FIM
Edit `C:\Program Files (x86)\ossec-agent\ossec.conf` and add the honeypot directories to the `<syscheck>` section.

**Windows Paths:**
- **Bitcoin:** `%APPDATA%\Bitcoin\wallets\wallet.dat`
- **Ethereum:** `%APPDATA%\Ethereum\keystore`
- **Chrome Extensions:** `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\<ID>`
- **Edge Extensions:** `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Local Extension Settings\<ID>`
- **Brave Extensions:** `%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Local Extension Settings\<ID>`

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
