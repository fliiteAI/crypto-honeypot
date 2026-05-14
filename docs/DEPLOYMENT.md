# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Hardware Recommendations](#hardware-recommendations)
3. [Wazuh Manager Configuration](#wazuh-manager-configuration)
4. [Wazuh Agent Configuration](#wazuh-agent-configuration)
    - [Linux Setup](#linux-setup)
    - [Windows Setup](#windows-setup)
    - [Browser Extension Path Mappings](#browser-extension-path-mappings)
    - [Containerized Deployment (Docker)](#containerized-deployment-docker)
5. [Honeypot Artifact Generation](#honeypot-artifact-generation)
6. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.
- **Connectivity:**
    - Port **1514 (TCP/UDP)**: For agent event communication.
    - Port **1515 (TCP)**: For agent enrollment.

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

## Hardware Recommendations

For SMB environments, we recommend the following hardware for the **Wazuh Manager**:

- **Primary Recommendation:** Raspberry Pi 5 (8GB RAM).
- **Minimum Recommendation:** Raspberry Pi 4 (8GB RAM).
- **Storage:** High-endurance microSD card or USB 3.0 SSD (preferred).

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
Add the honeypot monitoring paths to `/var/ossec/etc/ossec.conf` inside the `<syscheck>` block. You can use the template at `wazuh/agent-config/ossec-honeypot-fim.conf` or generate a custom one:
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

The honeypot decoys should be placed in the following directories to mimic real browser extension storage.

| Browser | OS | Extension Path |
|---------|----|----------------|
| **Chrome / Brave** | **Linux** | `~/.config/[browser-name]/Default/Local Extension Settings/[extension-id]` |
| **Chrome / Brave** | **Windows** | `%LOCALAPPDATA%\[browser-name]\User Data\Default\Local Extension Settings\[extension-id]` |
| **Edge** | **Windows** | `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Local Extension Settings\[extension-id]` |
| **Firefox** | **Linux** | `~/.mozilla/firefox/[profile-id].default/storage/default/moz-extension+++[extension-id]` |
| **Firefox** | **Windows** | `%APPDATA%\Mozilla\Firefox\Profiles\[profile-id].default\storage\default\moz-extension+++[extension-id]` |

**Common Extension IDs:**
- MetaMask: `nkbihfbeogaeaoehlefnkodbefgpgknn`
- Phantom: `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- Coinbase Wallet: `hnfanknocfeofbddgcijnmhnfnkdnaad`

---

## Containerized Deployment (Docker)

To run the Wazuh Agent as a container while still monitoring the host's honeypot files:

1.  **Mount Volumes:** Map the host honeypot directories into the container.
2.  **Elevated Privileges:** Required for `auditd` support inside the container.

```bash
docker run -d \
  --name wazuh-agent \
  --privileged \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -e WAZUH_MANAGER='192.168.1.100' \
  -e WAZUH_AGENT_NAME='my-docker-agent' \
  -v /home/user/.bitcoin:/home/user/.bitcoin:ro \
  -v /var/ossec/etc/ossec.conf:/var/ossec/etc/ossec.conf:ro \
  wazuh/wazuh-agent:latest
```

---

## Honeypot Artifact Generation

### Option A: Using the CLI (Recommended)
```bash
pip install .
honeypot-deployer generate --output ./my-artifacts
```

### Option B: Standalone Scripts
**Linux:** `./deploy.sh`
**Windows:** `.\deploy.ps1`

---

## Deployment Verification

1.  **Verify Artifacts:** `honeypot-deployer health-check --manifest ./my-artifacts/manifest.json`
2.  **Trigger a Test Alert:** `cat ~/.bitcoin/wallet.dat`
3.  **Check Wazuh Dashboard:** Confirm that a Level 12 (or higher) alert appears.
