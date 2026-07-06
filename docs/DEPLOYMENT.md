# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Browser Extension Path Mappings](#browser-extension-path-mappings)
3. [Wazuh Manager Configuration](#wazuh-manager-configuration)
4. [Wazuh Agent Configuration](#wazuh-agent-configuration)
5. [Honeypot Artifact Generation](#honeypot-artifact-generation)
6. [Containerized Deployment (Docker)](#containerized-deployment-docker)
7. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Hardware Recommendations (SMB/Home Lab)
- **Wazuh Manager:**
  - Raspberry Pi 4 (8GB) or Raspberry Pi 5.
  - High-endurance microSD card or USB 3.0 SSD (strongly preferred for performance).
- **Endpoint Agents:** Any system capable of running Wazuh Agent.

### Operating Systems
- **Linux:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
- **Windows:** Windows 10/11 or Windows Server 2016+.
- **macOS:** Monterey (12.x) or newer (FIM support only).

### Software Requirements
- **Python:** 3.10+ (required for the `honeypot-deployer` CLI).
- **Wazuh:** Version 4.x or higher (Manager and Agents).
- **Auditd:** (Linux) Essential for high-fidelity `whodata` FIM and user attribution.
- **Sysmon:** (Windows) Recommended for enhanced process-level visibility.

---

## Browser Extension Path Mappings

The honeypot targets common paths used by info-stealer malware.

### Chrome-based Browsers (Chrome, Edge, Brave)
Local storage data is typically found in:

| OS | Path |
|----|------|
| **Linux** | `~/.config/[browser-dir]/Default/Local Extension Settings/[extension-id]` |
| **Windows** | `%LOCALAPPDATA%\[browser-dir]\User Data\Default\Local Extension Settings\[extension-id]` |

**Browser Directories:**
- Google Chrome: `google-chrome` (Linux), `Google\Chrome` (Windows)
- Microsoft Edge: `microsoft-edge` (Linux), `Microsoft\Edge` (Windows)
- Brave: `BraveSoftware\Brave-Browser`

**Target Extension IDs:**
- MetaMask: `nkbihfbeogaeaoehlefnkodbefgpgknn`
- Phantom: `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- Coinbase Wallet: `hnfanknocfeofbddgcijnmhnfnkdnaad`

### Firefox
Firefox uses a different structure (IndexedDB) for extension storage.

| OS | Path |
|----|------|
| **Linux** | `~/.mozilla/firefox/*.default*/storage/default/moz-extension+++[uuid]` |
| **Windows** | `%APPDATA%\Mozilla\Firefox\Profiles\*.default*\storage\default\moz-extension+++[uuid]` |

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

### 3. Configure Active Response (Optional)
To automatically capture forensic data when a honeypot is accessed:
```bash
sudo cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
sudo chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
sudo chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
```
Configure the active response in your `ossec.conf` on the manager.

### 4. Restart Wazuh Manager
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
Add the honeypot monitoring paths to `/var/ossec/etc/ossec.conf` inside the `<syscheck>` block. Use the `honeypot-deployer` CLI to generate the exact config for your deployment:
```bash
honeypot-deployer wazuh-config --manifest ./path/to/manifest.json --os linux
```

#### 3. Install Audit Rules
```bash
sudo cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
sudo auditctl -R /etc/audit/rules.d/honeypot.rules
```

### Windows Setup

#### 1. Install Sysmon (Recommended)
Download and install [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon) with a configuration that includes the rules in `wazuh/agent-config/honeypot-sysmon.xml`.

#### 2. Configure FIM
Edit `C:\Program Files (x86)\ossec-agent\ossec.conf` and add the honeypot directories to the `<syscheck>` section using the output from:
```bash
honeypot-deployer wazuh-config --manifest ./path/to/manifest.json --os windows
```

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
The `manifest.json` contains the private keys for the generated honeypots. **Always keep this file secure.** Use the `--encrypt-manifest` flag (enabled by default) to protect it.

---

## Containerized Deployment (Docker)

To run the Wazuh Agent in a Docker container while maintaining high-fidelity monitoring:

1. **Permissions:** The container must run with `--cap-add=AUDIT_CONTROL` and `--pid=host` to interact with the host's `auditd`.
2. **Environment:** Pass the `NODE_NAME` variable to identify the agent.
3. **Volumes:** Mount the directories where honeypot artifacts are stored.

```bash
docker run -d --name wazuh-agent \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -e WAZUH_MANAGER="manager-ip" \
  -e NODE_NAME="honeypot-node-01" \
  -v /home/user/honeypots:/mnt/honeypots:ro \
  wazuh/wazuh-agent:latest
```

---

## Deployment Verification

1. **Verify Artifacts:**
   ```bash
   honeypot-deployer health-check --manifest ./my-artifacts/manifest.json
   ```
2. **Trigger a Test Alert:**
   On a Linux agent: `cat ~/.bitcoin/wallet.dat`
   On a Windows agent: `type %APPDATA%\Bitcoin\wallet.dat`
3. **Check Wazuh Dashboard:** Confirm that a Level 12+ alert (Rule 100501) appears.
