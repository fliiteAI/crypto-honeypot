# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Wazuh Manager Configuration](#wazuh-manager-configuration)
3. [Wazuh Agent Configuration](#wazuh-agent-configuration)
    - [Linux Setup](#linux-setup)
    - [Windows Setup](#windows-setup)
    - [Containerized Deployment (Docker)](#containerized-deployment-docker)
4. [Honeypot Artifact Generation](#honeypot-artifact-generation)
5. [Browser Extension Path Mappings](#browser-extension-path-mappings)
6. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher. Recommended hardware for SMBs: Raspberry Pi 4 (8GB) or Raspberry Pi 5 with a high-endurance microSD card or USB 3.0 SSD.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.
- **Connectivity:** Port 1514 (TCP/UDP) for events and 1515 (TCP) for enrollment must be open on the Manager.

### Supported Operating Systems
- **Linux:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
- **Windows:** Windows 10/11 or Windows Server 2016+.

### Endpoint Requirements
#### Linux
- **Python:** 3.10+ (required for running the `honeypot-deployer` CLI).
- **Packages:** `auditd` (essential for high-fidelity `whodata` FIM support and user attribution).
- **Permissions:** Root/sudo access for installing audit rules and modifying Wazuh configuration.

#### Windows
- **Operating System:** Windows 10/11 or Windows Server 2016+.
- **PowerShell:** 5.1 or higher.
- **Sysmon:** Recommended for enhanced process-level visibility.
- **Permissions:** Administrator privileges for modifying Wazuh configuration and deploying artifacts.

---

## Wazuh Manager Configuration

The Wazuh Manager must be configured to recognize honeypot-specific logs and trigger alerts.

### 1. Install Decoders
Copy the custom decoders:
```bash
sudo cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/
```

### 2. Install Rules
Copy the custom rules (ID range 100500-100599):
```bash
sudo cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/
```

### 3. (Optional) Active Response
To automatically trigger remediation (e.g., account lockout) or capture forensic data:
```bash
sudo cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
sudo chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
sudo chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
```
Add the Active Response configuration to your Manager's `ossec.conf` within the `<ossec_config>` section.

### 4. Restart Wazuh Manager
```bash
sudo systemctl restart wazuh-manager
```

---

## Wazuh Agent Configuration

### Linux Setup

#### 1. Install Auditd
```bash
sudo apt update && sudo apt install auditd -y
```

#### 2. Configure FIM
Add the monitoring paths to `/var/ossec/etc/ossec.conf` inside the `<syscheck>` block. Use `whodata="yes"` for high fidelity.
You can generate a tailored snippet using the CLI:
```bash
honeypot-deployer wazuh-config --manifest ./path/to/manifest.json --os linux
```

#### 3. Install Audit Rules
```bash
sudo cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
sudo auditctl -R /etc/audit/rules.d/honeypot.rules
```

### Windows Setup

#### 1. Install Sysmon
Download [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon) and install it with the provided honeypot rules:
```powershell
.\Sysmon64.exe -i .\wazuh\agent-config\honeypot-sysmon.xml
```

#### 2. Configure FIM
Edit `C:\Program Files (x86)\ossec-agent\ossec.conf` and add the honeypot directories to the `<syscheck>` section.

---

## Containerized Deployment (Docker)

To run a Wazuh agent in a container while maintaining high-fidelity monitoring:

1. **Run with Privileges:** The container needs audit capabilities.
   ```bash
   docker run -d --name wazuh-agent \
     --cap-add=AUDIT_CONTROL \
     --pid=host \
     -e WAZUH_MANAGER="manager-ip" \
     -e NODE_NAME="container-honeypot" \
     wazuh/wazuh-agent:latest
   ```
2. **Volume Mounts:** Mount the directories where honeyfiles will be deployed.

---

## Honeypot Artifact Generation

### Using the CLI (Recommended)
The CLI generates randomized artifacts and tracks them in an encrypted manifest.

```bash
# 1. Install
pip install .

# 2. Generate
# Use --encrypt-manifest (default) to protect keys
honeypot-deployer generate --output ./my-artifacts
```

---

## Browser Extension Path Mappings

The honeypot targets the following extension IDs and locations:

| Extension | ID | Browser | Linux Path (User Home) | Windows Path (%LOCALAPPDATA%) |
|-----------|----|---------|------------|--------------|
| **MetaMask** | `nkbihfbeogaeaoehlefnkodbefgpgknn` | Chrome/Edge/Brave | `.config/google-chrome/Default/Local Extension Settings/` | `Google\Chrome\User Data\Default\Local Extension Settings\` |
| **Phantom** | `bfnaelmomeimhlpmgjnjophhpkkoljpa` | Chrome/Edge/Brave | `.config/google-chrome/Default/Local Extension Settings/` | `Google\Chrome\User Data\Default\Local Extension Settings\` |
| **Coinbase** | `hnfanknocfeofbddgcijnmhnfnkdnaad` | Chrome/Edge/Brave | `.config/google-chrome/Default/Local Extension Settings/` | `Google\Chrome\User Data\Default\Local Extension Settings\` |

*Note: For Firefox, decoys are placed in `~/.mozilla/firefox/*.default*/storage/default` using `moz-extension+++` naming.*

---

## Deployment Verification

1. **Health Check:** `honeypot-deployer health-check --manifest ./my-artifacts/manifest.json`
2. **Trigger Test:**
   - Linux: `cat ~/.bitcoin/wallet.dat`
   - Windows: `type %APPDATA%\Bitcoin\wallet.dat`
3. **Dashboard:** Verify a Level 12+ alert in Wazuh.
