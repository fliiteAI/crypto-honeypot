# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Network Requirements](#network-requirements)
3. [Browser Extension Path Mappings](#browser-extension-path-mappings)
4. [Wazuh Manager Configuration](#wazuh-manager-configuration)
5. [Wazuh Agent Configuration](#wazuh-agent-configuration)
6. [Containerized Deployment (Docker)](#containerized-deployment-docker)
7. [Honeypot Artifact Generation](#honeypot-artifact-generation)
8. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.

### Hardware Recommendations (SMB)
For small to medium business environments, we recommend the following for the Wazuh Manager:
- **Primary:** Raspberry Pi 5 (8GB RAM) with NVMe SSD.
- **Secondary:** Raspberry Pi 4 (8GB RAM).
- **Endpoint:** Any standard workstation (Linux, Windows, macOS).

### Endpoint Software Requirements
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

Ensure the following ports are open between the monitored agents and the Wazuh Manager:

| Port | Protocol | Description |
|------|----------|-------------|
| **1514** | TCP/UDP | Agent event communication (FIM, Audit logs) |
| **1515** | TCP | Agent enrollment and keep-alive |
| **55000**| TCP | Wazuh API (optional, for remote management) |

---

## Browser Extension Path Mappings

The honeypot targets specific browser extension IDs across different browsers and operating systems.

### Extension IDs
- **MetaMask:** `nkbihfbeogaeaoehlefnkodbefgpgknn`
- **Phantom:** `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- **Coinbase Wallet:** `hnfanknocfeofbddgcijnmhnfnkdnaad`

### Path Templates

#### Windows
- **Chrome:** `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\<ID>`
- **Edge:** `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Local Extension Settings\<ID>`
- **Brave:** `%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Local Extension Settings\<ID>`

#### Linux
- **Chrome:** `~/.config/google-chrome/Default/Local Extension Settings/<ID>`
- **Brave:** `~/.config/BraveSoftware/Brave-Browser/Default/Local Extension Settings/<ID>`
- **Firefox:** `~/.mozilla/firefox/*.default*/storage/default/moz-extension+++<UUID>`

---

## Wazuh Manager Configuration

### 1. Install Decoders & Rules
Copy the custom configuration files to your Wazuh Manager:
```bash
# Decoders
cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/

# Rules
cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/
```

### 2. Active Response Setup
```bash
cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
```

### 3. Restart Manager
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
Add the honeypot monitoring paths to `/var/ossec/etc/ossec.conf` inside the `<syscheck>` block.

#### 3. Install Audit Rules
```bash
cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
sudo auditctl -R /etc/audit/rules.d/honeypot.rules
```

### Windows Setup

#### 1. Install Sysmon
Install Sysmon with the provided configuration:
```powershell
.\Sysmon64.exe -i wazuh/agent-config/honeypot-sysmon.xml
```

---

## Containerized Deployment (Docker)

To run the Wazuh Agent in a container while maintaining high-fidelity honeypot monitoring:

### Docker Run Configuration
The container must have access to the host's audit system for `whodata` to work.

```bash
docker run -d --name wazuh-agent \
  --privileged \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -e WAZUH_MANAGER="192.168.1.100" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/log:/var/log \
  wazuh/wazuh-agent:latest
```

**Note:** `--cap-add=AUDIT_CONTROL` and `--pid=host` are required for the agent to receive audit events from the host kernel.

---

## Honeypot Artifact Generation

```bash
# Generate artifacts
honeypot-deployer generate --output ./artifacts

# Generate Wazuh config snippet
honeypot-deployer wazuh-config --manifest ./artifacts/manifest.json --os linux
```

---

## Deployment Verification

1. **Health Check:** `honeypot-deployer health-check --manifest ./artifacts/manifest.json`
2. **Trigger Test:** `cat ~/.bitcoin/wallet.dat`
3. **Verify Alert:** Check the Wazuh dashboard for Rule **100501**.
