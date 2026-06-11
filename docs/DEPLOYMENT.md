# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Hardware Recommendations](#hardware-recommendations)
3. [Wazuh Manager Configuration](#wazuh-manager-configuration)
4. [Wazuh Agent Configuration](#wazuh-agent-configuration)
5. [Browser Extension Path Mappings](#browser-extension-path-mappings)
6. [Honeypot Artifact Generation](#honeypot-artifact-generation)
7. [Containerized Deployment (Docker)](#containerized-deployment-docker)
8. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.
- **Connectivity:** Port 1514 (TCP/UDP) and 1515 (TCP) must be open on the Wazuh Manager.

### Endpoint Requirements
#### Linux
- **OS Support:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
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

For SMB environments, we recommend running the Wazuh Manager on dedicated hardware:
- **Primary Choice:** Raspberry Pi 4 (8GB) or Raspberry Pi 5.
- **Storage:** High-endurance microSD card or USB 3.0 SSD (preferred for performance).
- **Network:** Wired Ethernet connection.

---

## Wazuh Manager Configuration

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

### 3. Active Response
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
The honeypot-deployer CLI can generate a customized FIM configuration based on your manifest:
```bash
honeypot-deployer wazuh-config --manifest ./manifest.json --os linux
```
Add the output to `/var/ossec/etc/ossec.conf` inside the `<syscheck>` block.

#### 3. Install Audit Rules
```bash
cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
sudo auditctl -R /etc/audit/rules.d/honeypot.rules
```

---

## Browser Extension Path Mappings

The honeypot monitors the following default browser extension paths:

### Chrome-based (Chrome, Edge, Brave)
- **Linux:** `~/.config/[browser]/Default/Local Extension Settings/[Extension ID]`
- **Windows:** `%LOCALAPPDATA%\[browser]\User Data\Default\Local Extension Settings\[Extension ID]`

### Firefox
- **Linux:** `~/.mozilla/firefox/*.default*/storage/default/moz-extension+++[Extension ID]`
- **Windows:** `%APPDATA%\Mozilla\Firefox\Profiles\*.default*\storage\default\moz-extension+++[Extension ID]`

### Monitored Extension IDs:
- **MetaMask:** `nkbihfbeogaeaoehlefnkodbefgpgknn`
- **Phantom:** `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- **TronLink:** `ibnejdfjmmkpcnlpebklmnkoeoihofec`
- **Coinbase Wallet:** `hnfanknocfeofbddgcijnmhnfnkdnaad`
- **Binance Wallet:** `cadiboklkpojfamcoggejbbdjcoiljjk`

---

## Containerized Deployment (Docker)

To deploy the Wazuh agent in a container while maintaining high-fidelity monitoring:

```bash
docker run -d \
  --name wazuh-agent \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -e WAZUH_MANAGER='192.168.1.100' \
  -e NODE_NAME='Honeypot-Node-01' \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/ossec/data:/var/ossec/data \
  wazuh/wazuh-agent:latest
```
*Note: `--cap-add=AUDIT_CONTROL` and `--pid=host` are required for the agent to interact with the host's `auditd` system.*

---

## Deployment Verification

1. **Verify Artifacts:**
   ```bash
   honeypot-deployer health-check --manifest ./manifest.json
   ```
2. **Trigger Test Access:**
   On Linux: `cat ~/.bitcoin/wallet.dat`
3. **Verify Alert:** Check the Wazuh dashboard for Rule ID 100501.
