# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Network Requirements](#network-requirements)
3. [Wazuh Manager Configuration](#wazuh-manager-configuration)
4. [Wazuh Agent Configuration](#wazuh-agent-configuration)
    - [Linux Setup](#linux-setup)
    - [Windows Setup](#windows-setup)
5. [Browser Extension Path Mappings](#browser-extension-path-mappings)
6. [Honeypot Artifact Generation](#honeypot-artifact-generation)
7. [Containerized Deployment (Docker)](#containerized-deployment-docker)
8. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.

### Hardware Recommendations
For SMB environments, we recommend running the Wazuh Manager on:
- **Raspberry Pi 4 (8GB RAM)** or **Raspberry Pi 5**.
- High-endurance microSD card or USB 3.0 SSD for storage.

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

## Network Requirements

The following ports must be open between the Wazuh Agents and the Wazuh Manager:

| Port | Protocol | Description |
|------|----------|-------------|
| **1514** | TCP / UDP | Agent event communication (FIM logs, etc.) |
| **1515** | TCP | Agent enrollment and keep-alive |

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

The honeypot targets common paths used by browser-based wallets.

### Chrome / Brave / Edge (Chromium-based)
- **Linux:** `~/.config/[Browser Name]/Default/Local Extension Settings/[Extension ID]`
- **Windows:** `%LOCALAPPDATA%\[Browser Vendor]\[Browser Name]\User Data\Default\Local Extension Settings\[Extension ID]`

### Firefox
- **Linux:** `~/.mozilla/firefox/[Profile Name]/storage/default/moz-extension+++[Extension UUID]`
- **Windows:** `%APPDATA%\Mozilla\Firefox\Profiles\[Profile Name]\storage\default\moz-extension+++[Extension UUID]`

### Targeted Extension IDs
| Wallet | Extension ID |
|--------|--------------|
| MetaMask | `nkbihfbeogaeaoehlefnkodbefgpgknn` |
| Phantom | `bfnaelmomeimhlpmgjnjophhpkkoljpa` |
| TronLink | `ibnejdfjmmkpcnlpebklmnkoeoihofec` |
| Coinbase Wallet | `hnfanknocfeofbddgcijnmhnfnkdnaad` |
| Binance Wallet | `cadiboklkpojfamcoggejbbdjcoiljjk` |

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
The `manifest.json` contains the private keys for the generated honeypots. **Always keep this file secure.** Use the `--encrypt-manifest` flag (enabled by default) to protect it with a password.

---

## Containerized Deployment (Docker)

To run the Wazuh Agent in a container while monitoring honeypot files on the host:

1. **Mount the honeypot directories:**
```bash
docker run -d \
  --name wazuh-agent \
  -e WAZUH_MANAGER='192.168.1.100' \
  -e NODE_NAME='Honeypot-Node-01' \
  -v /home/user/.bitcoin:/home/user/.bitcoin:ro \
  -v /var/ossec/etc/ossec.conf:/var/ossec/etc/ossec.conf:ro \
  wazuh/wazuh-agent:latest
```

2. **Note on `whodata`:** High-fidelity monitoring via `auditd` requires the container to run with `--cap-add=AUDIT_CONTROL` and `--pid=host` to interact with the host's audit subsystem.

---

## Deployment Verification

1. **Verify Artifacts:** Run the health check command:
   ```bash
   honeypot-deployer health-check --manifest ./my-artifacts/manifest.json
   ```
2. **Trigger a Test Alert:**
   On a Linux agent: `cat ~/.bitcoin/wallet.dat`
   On a Windows agent: `type %APPDATA%\Bitcoin\wallet.dat`
3. **Check Wazuh Dashboard:** Confirm that a Level 12 (or higher) alert appears in the security events.
