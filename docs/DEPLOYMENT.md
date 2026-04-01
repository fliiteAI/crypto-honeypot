# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Wazuh Manager Configuration](#wazuh-manager-configuration)
3. [Wazuh Agent Configuration](#wazuh-agent-configuration)
    - [Linux Setup](#linux-setup)
    - [Windows Setup](#windows-setup)
4. [Honeypot Artifact Generation](#honeypot-artifact-generation)
5. [Browser Extension Path Mappings](#browser-extension-path-mappings)
6. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.

### Hardware Recommendation
For SMB environments, we recommend running the Wazuh Manager on a **Raspberry Pi 4 (8GB)** or **Raspberry Pi 5**. This provides a cost-effective, dedicated security appliance.

### Endpoint Requirements
#### Linux
- **Python:** 3.10+ (required for running the `honeypot-deployer` CLI).
- **Packages:** `auditd` (essential for `whodata` FIM support and user attribution).
- **Permissions:** Root/sudo access for installing audit rules and modifying Wazuh configuration.

#### Windows
- **Operating System:** Windows 10/11 or Windows Server 2016+.
- **PowerShell:** 5.1 or higher.
- **Sysmon:** Recommended for enhanced process-level visibility and process-to-file correlation.
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
Add the honeypot monitoring paths to `/var/ossec/etc/ossec.conf` inside the `<syscheck>` block. Use `whodata="yes"` for best results.

```xml
<syscheck>
  <directories check_all="yes" report_changes="yes" realtime="yes" whodata="yes">/home/*/.bitcoin</directories>
  <directories check_all="yes" report_changes="yes" realtime="yes" whodata="yes">/home/*/.ethereum</directories>
  <directories check_all="yes" report_changes="yes" realtime="yes" whodata="yes">/home/*/.config/solana</directories>
</syscheck>
```

Alternatively, generate a custom config from your manifest:
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
Download and install [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon). Use the provided configuration template:
```bash
sysmon.exe -i wazuh/agent-config/honeypot-sysmon.xml
```

#### 2. Configure FIM
Edit `C:\Program Files (x86)\ossec-agent\ossec.conf` and add the honeypot directories to the `<syscheck>` section.

---

## Honeypot Artifact Generation

### Using the CLI (Recommended)
The CLI generates unique, randomized artifacts and tracks them in an encrypted manifest.

```bash
# 1. Install the tool
pip install .

# 2. Generate artifacts
honeypot-deployer generate --output ./my-artifacts

# 3. View the generated manifest
honeypot-deployer show --manifest ./my-artifacts/manifest.json
```

### Manifest Security
The `manifest.json` contains the private keys for the generated honeypots. **Always keep this file secure.** Use the `--encrypt-manifest` flag (enabled by default).

---

## Browser Extension Path Mappings

The deployer places decoys in standard locations where infostealers look.

| Extension | ID | Chrome/Edge Path (Linux) | Chrome/Edge Path (Windows) |
|-----------|----|--------------------------|----------------------------|
| MetaMask | `nkbihfbeogaeaoehlefnkodbefgpgknn` | `~/.config/google-chrome/Default/Local Extension Settings/` | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\` |
| Phantom | `bfnaelmomeimhlpmgjnjophhpkkoljpa` | `~/.config/google-chrome/Default/Local Extension Settings/` | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\` |
| Coinbase | `hnfanknocfeofbddgcijnmhnfnkdnaad` | `~/.config/google-chrome/Default/Local Extension Settings/` | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\` |

---

## Deployment Verification

1. **Verify Artifacts:**
   ```bash
   honeypot-deployer health-check --manifest ./my-artifacts/manifest.json
   ```
2. **Trigger a Test Alert:**
   - Linux: `cat ~/.bitcoin/wallet.dat`
   - Windows: `type %APPDATA%\Bitcoin\wallet.dat`
3. **Check Wazuh Dashboard:** Confirm that a Level 12+ alert appears.
