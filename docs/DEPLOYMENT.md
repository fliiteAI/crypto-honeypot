# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Hardware Recommendations](#hardware-recommendations)
3. [Network Requirements](#network-requirements)
4. [Wazuh Manager Configuration](#wazuh-manager-configuration)
5. [Wazuh Agent Configuration](#wazuh-agent-configuration)
    - [Linux Setup](#linux-setup)
    - [Windows Setup](#windows-setup)
    - [Docker/Containerized Setup](#dockercontainerized-setup)
6. [Browser Extension Monitoring](#browser-extension-monitoring)
7. [Honeypot Artifact Generation](#honeypot-artifact-generation)
8. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.

### Operating Systems
- **Linux:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
- **Windows:** Windows 10/11 or Windows Server 2016+.

### Software Dependencies
- **Python:** 3.10+ (required for the `honeypot-deployer` CLI).
- **Linux:** `auditd` package (essential for `whodata` FIM support and user attribution).
- **Windows:** Sysmon (recommended for enhanced process-level visibility).

---

## Hardware Recommendations

For SMB environments, the Wazuh Manager can be deployed on cost-effective ARM-based hardware:
- **Recommended:** Raspberry Pi 4 (8GB) or Raspberry Pi 5.
- **Storage:** High-endurance microSD card or, preferably, a USB 3.0 SSD for better I/O performance and reliability.
- **Cooling:** Active cooling is recommended for sustained performance.

---

## Network Requirements

Ensure the following ports are open on the Wazuh Manager to allow agent communication:
- **Port 1514 (TCP/UDP):** Agent event communication.
- **Port 1515 (TCP):** Agent registration and enrollment.

---

## Wazuh Manager Configuration

Before deploying agents, the Wazuh Manager must be configured to recognize honeypot-specific logs and trigger alerts.

### 1. Install Decoders
Copy the custom decoders to your Wazuh Manager:
```bash
sudo cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/
```

### 2. Install Rules
Copy the custom rules to your Wazuh Manager:
```bash
sudo cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/
```

### 3. Restart Wazuh Manager
```bash
sudo systemctl restart wazuh-manager
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
You can generate a localized Wazuh FIM configuration snippet based on your deployment manifest:
```bash
honeypot-deployer wazuh-config --manifest ./path/to/manifest.json --os linux
```
Add the output to the `<syscheck>` block in `/var/ossec/etc/ossec.conf`.

#### 3. Install Audit Rules
```bash
sudo cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
sudo auditctl -R /etc/audit/rules.d/honeypot.rules
```

### Windows Setup

#### 1. Install Sysmon
Download [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon) and install it with the provided configuration:
```powershell
.\Sysmon64.exe -i .\wazuh\agent-config\honeypot-sysmon.xml
```

#### 2. Configure FIM
Edit `C:\Program Files (x86)\ossec-agent\ossec.conf` and add the honeypot directories to the `<syscheck>` section.

---

## Docker/Containerized Setup

To run a Wazuh agent in a container while maintaining high-fidelity monitoring:
- **Privileged Mode:** Required for certain audit functions.
- **Capabilities:** Add `--cap-add=AUDIT_CONTROL`.
- **PID Namespace:** Use `--pid=host` to allow the agent to see host-level processes for attribution.
- **Environment Variables:** Pass `NODE_NAME` to identify the container in the Wazuh manager.

Example Docker run command:
```bash
docker run -d --name wazuh-agent \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -e WAZUH_MANAGER="192.168.1.100" \
  -e NODE_NAME="crypto-node-01" \
  wazuh/wazuh-agent:latest
```

---

## Browser Extension Monitoring

The honeypot targets common browser extension locations. The following extension IDs are monitored:
- **MetaMask:** `nkbihfbeogaeaoehlefnkodbefgpgknn`
- **Phantom:** `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- **TronLink:** `ibnejdfjmmkpcnlpebklmnkoeoihofec`
- **Coinbase Wallet:** `hnfanknocfeofbddgcijnmhnfnkdnaad`
- **Binance Wallet:** `cadiboklkpojfamcoggejbbdjcoiljjk`

### Paths
- **Linux (Chrome/Edge/Brave):** `~/.config/[browser]/Default/Local Extension Settings/[ID]`
- **Windows (Chrome/Edge/Brave):** `%LOCALAPPDATA%\[browser]\User Data\Default\Local Extension Settings\[ID]`
- **Firefox:** Uses a different structure under the profile storage directory.

---

## Honeypot Artifact Generation

### Using the CLI (Recommended)
```bash
# Generate artifacts
honeypot-deployer generate --output ./my-artifacts --encrypt-manifest

# Perform health check
honeypot-deployer health-check --manifest ./my-artifacts/manifest.json
```

### Standalone Scripts
For environments where Python cannot be installed:
- **Linux:** `./deploy.sh`
- **Windows:** `.\deploy.ps1`

---

## Deployment Verification

1. **Check Manifest:** Ensure `manifest.json` is generated and secured.
2. **Verify Files:** Use `honeypot-deployer health-check`.
3. **Test Alerts:** Access a honeyfile (e.g., `cat ~/.bitcoin/wallet.dat`) and verify that an alert appears in the Wazuh dashboard with Level 12+ severity.
