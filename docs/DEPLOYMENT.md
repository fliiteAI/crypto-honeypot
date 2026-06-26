# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements & Hardware](#system-requirements--hardware)
2. [Wazuh Manager Configuration](#wazuh-manager-configuration)
3. [Wazuh Agent Configuration](#wazuh-agent-configuration)
4. [Honeypot Artifact Generation](#honeypot-artifact-generation)
5. [Containerized Deployment (Docker)](#containerized-deployment-docker)
6. [Deployment Verification](#deployment-verification)

---

## System Requirements & Hardware

### Hardware Recommendations (Wazuh Manager)
For SMB environments (1-50 endpoints), we recommend running the Wazuh Manager on dedicated hardware:
- **Recommended:** Raspberry Pi 4 (8GB) or Raspberry Pi 5.
- **Storage:** High-endurance microSD card or, preferably, a USB 3.0 SSD.
- **Network:** Wired Ethernet connection.

### Supported Operating Systems
#### Linux
- **Distributions:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
- **Packages:** `auditd` (essential for `whodata` FIM support).
- **Python:** 3.10+ (required for the `honeypot-deployer` CLI).

#### Windows
- **Operating System:** Windows 10/11 or Windows Server 2016+.
- **PowerShell:** 5.1 or higher.
- **Sysmon:** Recommended for enhanced process-level visibility.

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

### 4. Restart Wazuh Manager
```bash
systemctl restart wazuh-manager
```

---

## Wazuh Agent Configuration

### Linux Setup

#### 1. Install Auditd
```bash
sudo apt update && sudo apt install auditd -y
```

#### 2. Configure FIM
Add the honeypot monitoring paths to `/var/ossec/etc/ossec.conf` inside the `<syscheck>` block. You can use the template at `wazuh/agent-config/ossec-honeypot-fim.conf` or generate a custom one using the CLI.

#### 3. Install Audit Rules
```bash
cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
sudo auditctl -R /etc/audit/rules.d/honeypot.rules
```

### Windows Setup

#### 1. Install Sysmon
Install Sysmon with a configuration that includes the rules in `wazuh/agent-config/honeypot-sysmon.xml`.

#### 2. Configure FIM
Edit `C:\Program Files (x86)\ossec-agent\ossec.conf` and add the honeypot directories to the `<syscheck>` section.

---

## Honeypot Artifact Generation

### Option A: Using the CLI (Recommended)
```bash
# 1. Install the tool
pip install .

# 2. Generate artifacts
honeypot-deployer generate --output ./my-artifacts
```

### Browser Extension Path Mappings
Place decoys in these paths for detection by infostealers:

**Chrome/Edge/Brave:**
- **Linux:** `~/.config/<browser>/Default/Local Extension Settings/<extension-id>/`
- **Windows:** `%LOCALAPPDATA%\<browser>\User Data\Default\Local Extension Settings\<extension-id>\`

**Common IDs:**
- MetaMask: `nkbihfbeogaeaoehlefnkodbefgpgknn`
- Phantom: `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- Coinbase: `hnfanknocfeofbddgcijnmhnfnkdnaad`

---

## Containerized Deployment (Docker)

To deploy the Wazuh Agent with `auditd` support:
```bash
docker run -d \
  --name wazuh-agent-honeypot \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -e WAZUH_MANAGER="YOUR_MANAGER_IP" \
  -v /path/to/artifacts:/var/monitored/wallets \
  wazuh/wazuh-agent:latest
```

---

## Deployment Verification

1. **Verify Artifacts:** `honeypot-deployer health-check --manifest ./my-artifacts/manifest.json`
2. **Trigger a Test Alert:** `cat ~/.bitcoin/wallet.dat` (Linux) or `type %APPDATA%\Bitcoin\wallet.dat` (Windows)
3. **Check Wazuh Dashboard:** Confirm Level 12+ alert appears.
