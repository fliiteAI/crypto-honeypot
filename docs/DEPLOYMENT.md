# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Hardware Recommendations](#hardware-recommendations)
3. [Wazuh Manager Configuration](#wazuh-manager-configuration)
4. [Wazuh Agent Configuration](#wazuh-agent-configuration)
    - [Linux Setup](#linux-setup)
    - [Windows Setup](#windows-setup)
    - [Docker Setup](#docker-setup)
5. [Browser Extension Mappings](#browser-extension-mappings)
6. [Honeypot Artifact Generation](#honeypot-artifact-generation)
7. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.

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

For SMB environments, we recommend running the Wazuh Manager on dedicated low-power hardware:
- **Device:** Raspberry Pi 4 (8GB) or Raspberry Pi 5.
- **Storage:** High-endurance microSD card or (preferred) USB 3.0 SSD.
- **OS:** Raspberry Pi OS (64-bit) or Ubuntu Server 22.04 LTS.

---

## Wazuh Manager Configuration

### 1. Install Decoders & Rules
Copy the custom configuration files to your Wazuh Manager:
```bash
cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/
cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/
```

### 2. Configure Active Response
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
```bash
sudo apt update && sudo apt install auditd -y
```

#### 2. Configure FIM
Generate a custom FIM configuration based on your deployment manifest:
```bash
honeypot-deployer wazuh-config --manifest ./path/to/manifest.json --os linux --output ./agent-snippet.conf
```

### Windows Setup

#### 1. Install Sysmon
Install Sysmon with the provided configuration template:
```powershell
.\Sysmon64.exe -i wazuh/agent-config/honeypot-sysmon.xml
```

### Docker Setup
When running a Wazuh Agent in a container, you must provide the following flags to enable `whodata` (auditd) support:
```bash
docker run -d --name wazuh-agent \
  -e WAZUH_MANAGER="192.168.1.100" \
  -e NODE_NAME="my-container-agent" \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  wazuh/wazuh-agent:latest
```

---

## Browser Extension Mappings

The honeypot targets the following common extension IDs:
- **MetaMask:** `nkbihfbeogaeaoehlefnkodbefgpgknn`
- **Phantom:** `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- **TronLink:** `ibnejdfjmmkpcnlpebklmnkoeoihofec`
- **Coinbase Wallet:** `hnfanknocfeofbddgcijnmhnfnkdnaad`
- **Binance Wallet:** `cadiboklkpojfamcoggejbbdjcoiljjk`

### Standard Paths
- **Chrome (Linux):** `~/.config/google-chrome/Default/Local Extension Settings/`
- **Chrome (Windows):** `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\`
- **Firefox (Linux):** `~/.mozilla/firefox/*.default*/storage/default/` (using `moz-extension+++` prefix)

---

## Honeypot Artifact Generation

```bash
# Generate artifacts
honeypot-deployer generate --output ./honeypot-artifacts --encrypt-manifest

# Health check
honeypot-deployer health-check --manifest ./honeypot-artifacts/manifest.json
```

---

## Deployment Verification

1. **Check Connectivity:** Ensure the agent is connected to the manager (Ports 1514/1515).
2. **Simulate Access:** `cat ~/.bitcoin/wallet.dat`
3. **Verify Alert:** Look for Rule ID `100501` in the Wazuh dashboard.
