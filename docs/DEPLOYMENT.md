# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Wazuh Manager Configuration](#wazuh-manager-configuration)
3. [Wazuh Agent Configuration](#wazuh-agent-configuration)
    - [Linux Setup](#linux-setup)
    - [Windows Setup](#windows-setup)
    - [Browser Extension Paths](#browser-extension-paths)
4. [Containerized Deployment (Docker)](#containerized-deployment-docker)
5. [Honeypot Artifact Generation](#honeypot-artifact-generation)
6. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Hardware Recommendations
- **Wazuh Manager:** Raspberry Pi 4 (8GB) or Raspberry Pi 5.
- **Storage:** High-endurance microSD card or USB 3.0 SSD (preferred).

### Operating Systems
- **Linux:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
- **Windows:** Windows 10/11 or Windows Server 2016+.

### Network Requirements
The following ports must be open on the Wazuh Manager:
- **1514 (TCP/UDP):** Agent communication.
- **1515 (TCP):** Agent enrollment.

---

## Wazuh Manager Configuration

### 1. Install Decoders and Rules
Copy the custom configuration to your Wazuh Manager:
```bash
# Decoders
cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/

# Rules
cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/
```

### 2. (Optional) Active Response
To automatically capture forensic data when a honeypot is accessed:
```bash
cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
```

### 3. Restart Wazuh Manager
```bash
systemctl restart wazuh-manager
```

---

## Wazuh Agent Configuration

### Linux Setup

#### 1. Install Auditd
`auditd` is required for high-fidelity "whodata" monitoring.
```bash
sudo apt update && sudo apt install auditd -y
```

#### 2. Configure FIM
Add the monitoring paths to `/var/ossec/etc/ossec.conf` inside the `<syscheck>` block. You can generate a localized configuration snippet:
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
Install [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon) using the template in `wazuh/agent-config/honeypot-sysmon.xml`.

#### 2. Configure FIM
Use the CLI to generate the configuration:
```bash
honeypot-deployer wazuh-config --manifest ./path/to/manifest.json --os windows
```

---

## Browser Extension Paths

The system deploys decoys in standard browser extension paths to trigger infostealers.

### Chrome / Edge / Brave (Chromium-based)
- **Linux:** `~/.config/[browser]/Default/Local Extension Settings/[extension_id]/`
- **Windows:** `%LOCALAPPDATA%\[browser]\User Data\Default\Local Extension Settings\[extension_id]\`

### Firefox
- **Linux:** `~/.mozilla/firefox/[profile].default/storage/default/moz-extension+++[extension_id]/`
- **Windows:** `%APPDATA%\Mozilla\Firefox\Profiles\[profile].default\storage\default\moz-extension+++[extension_id]\`

---

## Containerized Deployment (Docker)

To run the Wazuh agent in a container while maintaining high-fidelity monitoring:

```bash
docker run -d \
  --name wazuh-agent \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -e WAZUH_MANAGER="192.168.1.100" \
  -e NODE_NAME="honeypot-node-01" \
  -v /home/user/wallets:/home/user/wallets:ro \
  wazuh/wazuh-agent:latest
```
**Note:** `--cap-add=AUDIT_CONTROL` and `--pid=host` are required for `auditd` integration.

---

## Honeypot Artifact Generation

```bash
# Recommended generation
honeypot-deployer generate --output ./my-artifacts --encrypt-manifest
```

---

## Deployment Verification

1. **Health Check:** `honeypot-deployer health-check --manifest ./my-artifacts/manifest.json`
2. **Trigger Test:** `cat ~/.bitcoin/wallet.dat` (Linux) or `type %APPDATA%\Bitcoin\wallet.dat` (Windows).
3. **Verify Alert:** Check the Wazuh dashboard for Rule ID 100501.
