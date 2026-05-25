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
    - [Containerized Deployment (Docker)](#containerized-deployment-docker)
6. [Browser Extension Monitoring](#browser-extension-monitoring)
7. [Honeypot Artifact Generation](#honeypot-artifact-generation)
8. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.

### OS Support
- **Linux:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
- **Windows:** Windows 10/11, Windows Server 2016+.

### Endpoint Requirements
#### Linux
- **Python:** 3.10+ (required for running the `honeypot-deployer` CLI).
- **Packages:** `auditd` (essential for `whodata` FIM support and user attribution).
- **Permissions:** Root/sudo access for installing audit rules and modifying Wazuh configuration.

#### Windows
- **PowerShell:** 5.1 or higher.
- **Sysmon:** Recommended for enhanced process-level visibility.
- **Permissions:** Administrator privileges for modifying Wazuh configuration and deploying artifacts.

---

## Hardware Recommendations

For SMB environments, the Wazuh Manager can be deployed on cost-effective hardware:

- **Recommended:** Raspberry Pi 4 (8GB) or Raspberry Pi 5.
- **Storage:** High-endurance microSD card or USB 3.0 SSD (preferred for better I/O performance).
- **Power:** Official Raspberry Pi power supply to ensure stability.

---

## Network Requirements

Ensure the following ports are open on the Wazuh Manager for agent communication:

| Port | Protocol | Description |
|------|----------|-------------|
| 1514 | TCP/UDP | Agent event communication |
| 1515 | TCP | Agent enrollment and keep-alive |
| 55000 | TCP | Wazuh API (optional, for management) |

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

### Containerized Deployment (Docker)

To run the Wazuh agent in a container while maintaining honeypot monitoring capabilities:

1. **Host Prerequisites:** `auditd` must be installed on the host OS.
2. **Docker Run Command:**
```bash
docker run -d --name wazuh-agent \
  -e WAZUH_MANAGER='WAZUH_MANAGER_IP' \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/ossec/etc:/var/ossec/etc \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  wazuh/wazuh-agent:latest
```
*Note: `--cap-add=AUDIT_CONTROL` and `--pid=host` are required for the agent to interact with the host's auditd system for `whodata` monitoring.*

---

## Browser Extension Monitoring

The system monitors specific browser extension data directories for common crypto wallets.

### Monitored Extension IDs

| Extension | ID |
|-----------|----|
| MetaMask | `nkbihfbeogaeaoehlefnkodbefgpgknn` |
| Phantom | `bfnaelmomeimhlpmgjnjophhpkkoljpa` |
| TronLink | `ibnejdfjmmkpcnlpebklmnkoeoihofec` |
| Coinbase Wallet | `hnfanknocfeofbddgcijnmhnfnkdnaad` |
| Binance Wallet | `cadiboklkpojfamcoggejbbdjcoiljjk` |

### Path Mappings

#### Browser Extensions
- **Linux (Chrome/Brave):** `~/.config/[browser]/Default/Local Extension Settings/[extension_id]`
- **Windows (Chrome/Edge/Brave):** `%LOCALAPPDATA%\[browser]\User Data\Default\Local Extension Settings\[extension_id]`
- **Linux (Firefox):** `~/.mozilla/firefox/*.default*/storage/default/moz-extension+++[UUID]`
- **Windows (Firefox):** `%APPDATA%\Mozilla\Firefox\Profiles\*.default*\storage\default\moz-extension+++[UUID]`

#### Desktop Wallets
- **Bitcoin:**
  - Linux: `~/.bitcoin/wallet.dat`
  - Windows: `%APPDATA%\Bitcoin\wallet.dat`
- **Ethereum:**
  - Linux: `~/.ethereum/keystore/`
  - Windows: `%APPDATA%\Ethereum\keystore\`
- **Solana:**
  - Linux: `~/.config/solana/id.json`
- **Electrum:**
  - Linux: `~/.electrum/wallets/`
  - Windows: `%APPDATA%\Electrum\wallets\`
- **Exodus:**
  - Linux: `~/.config/Exodus/exodus.wallet/`
  - Windows: `%APPDATA%\Exodus\exodus.wallet\`

---

## Honeypot Artifact Generation

There are two ways to deploy honeypot artifacts: using the `honeypot-deployer` CLI (recommended) or using standalone deployment scripts.

### Option A: Using the CLI (Recommended)
The CLI generates unique, randomized artifacts and tracks them in an encrypted manifest for high-fidelity monitoring and on-chain correlation.

```bash
# 1. Install the tool
pip install .

# 2. Generate artifacts
honeypot-deployer generate --output ./my-artifacts

# 3. View the generated manifest
honeypot-deployer show --manifest ./my-artifacts/manifest.json
```

### Option B: Standalone Scripts
For quick deployments without installing the Python package, you can use the provided shell and PowerShell scripts. These create a standard set of honeyfiles.

**Linux:**
```bash
chmod +x deploy.sh
./deploy.sh
```

**Windows:**
```powershell
.\deploy.ps1
```

### Manifest Security
The `manifest.json` contains the private keys for the generated honeypots. **Always keep this file secure.** It is recommended to use the `--encrypt-manifest` flag (enabled by default) to protect it with a password.

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
