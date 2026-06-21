# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Honeypot Artifact Locations](#honeypot-artifact-locations)
3. [Wazuh Manager Configuration](#wazuh-manager-configuration)
4. [Wazuh Agent Configuration](#wazuh-agent-configuration)
5. [Containerized Deployment (Docker)](#containerized-deployment-docker)
6. [Honeypot Artifact Generation](#honeypot-artifact-generation)
7. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.

### Hardware Recommendations
- **SMB Environments:** Raspberry Pi 4 (8GB) or Raspberry Pi 5 with a high-endurance microSD card or USB 3.0 SSD (preferred) for the Wazuh Manager.

### Endpoint Requirements
#### Linux
- **Python:** 3.10+ (required for running the `honeypot-deployer` CLI).
- **Packages:** `auditd` (essential for high-fidelity `whodata` FIM support).
- **Distributions:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.

#### Windows
- **Operating System:** Windows 10/11 or Windows Server 2016+.
- **PowerShell:** 5.1 or higher.
- **Sysmon:** Recommended for enhanced process-level visibility.

---

## Honeypot Artifact Locations

To maximize the chance of discovery by infostealers and manual attackers, artifacts should be placed in standard locations.

### Common Wallet Paths

| Asset | Linux Path | Windows Path |
|-------|------------|--------------|
| **Bitcoin** | `~/.bitcoin/wallet.dat` | `%APPDATA%\Bitcoin\wallet.dat` |
| **Ethereum** | `~/.ethereum/keystore/` | `%APPDATA%\Ethereum\keystore\` |
| **Solana** | `~/.config/solana/id.json` | `%USERPROFILE%\.config\solana\id.json` |
| **Electrum** | `~/.electrum/wallets/default_wallet` | `%APPDATA%\Electrum\wallets\default_wallet` |
| **Exodus** | `~/.config/Exodus/exodus.wallet/seed.secur` | `%APPDATA%\Exodus\exodus.wallet\seed.secur` |

### Browser Extension Paths (Chrome-based)
*Includes Chrome, Edge, Brave.*

- **Linux:** `~/.config/[browser]/Default/Local Extension Settings/[Extension ID]`
- **Windows:** `%LOCALAPPDATA%\[browser]\User Data\Default\Local Extension Settings\[Extension ID]`

**Common Extension IDs:**
- MetaMask: `nkbihfbeogaeaoehlefnkodbefgpgknn`
- Phantom: `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- Coinbase Wallet: `hnfanknocfeofbddgcijnmhnfnkdnaad`

### Browser Extension Paths (Firefox)

- **Linux:** `~/.mozilla/firefox/*.default*/storage/default/moz-extension+++[Extension ID]`
- **Windows:** `%APPDATA%\Mozilla\Firefox\Profiles\*.default-release\storage\default\moz-extension+++[Extension ID]`

---

## Wazuh Manager Configuration

### 1. Install Decoders & Rules
On the Wazuh Manager, copy the custom files and restart the service:

```bash
# Copy Decoders
sudo cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/

# Copy Rules
sudo cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/

# Restart
sudo systemctl restart wazuh-manager
```

### 2. Configure Active Response (Optional)
To trigger automated remediation (like account lockout) when a honeypot is accessed, add the following to the manager's `ossec.conf`:

```xml
<active-response>
  <command>disable-account</command>
  <location>local</location>
  <rules_group>crypto_honeypot</rules_group>
  <timeout>600</timeout>
</active-response>
```

---

## Wazuh Agent Configuration

### Linux (with auditd)
1. **Install auditd:** `sudo apt install auditd`
2. **Apply Audit Rules:**
   ```bash
   sudo cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
   sudo auditctl -R /etc/audit/rules.d/honeypot.rules
   ```
3. **Configure FIM:** Add the generated configuration from `honeypot-deployer wazuh-config` to `/var/ossec/etc/ossec.conf`.

### Windows (with Sysmon)
1. **Install Sysmon:** Use the configuration provided in `wazuh/agent-config/honeypot-sysmon.xml`.
2. **Configure FIM:** Add monitored paths to `C:\Program Files (x86)\ossec-agent\ossec.conf`.

---

## Containerized Deployment (Docker)

To deploy the honeypot in a containerized environment while maintaining high-fidelity monitoring:

1. **Run Wazuh Agent with Privileges:**
   ```bash
   docker run -d --name wazuh-agent \
     --cap-add=AUDIT_CONTROL \
     --pid=host \
     -e WAZUH_MANAGER="manager-ip" \
     -e NODE_NAME="honeypot-node" \
     -v /path/to/artifacts:/mnt/honeypot:ro \
     wazuh/wazuh-agent:latest
   ```
2. **Note:** The `--pid=host` and `AUDIT_CONTROL` capability are required for the containerized agent to receive `auditd` events from the host kernel.

---

## Honeypot Artifact Generation

Use the CLI to generate unique, randomized artifacts:

```bash
# Install
pip install .

# Generate
honeypot-deployer generate --output ./deploy-dir --encrypt-manifest

# This will create a directory structure mimicking real wallets
# and a manifest.json containing the private keys.
```

---

## Deployment Verification

1. **Check Manifest:** `honeypot-deployer show --manifest ./deploy-dir/manifest.json`
2. **Health Check:** `honeypot-deployer health-check --manifest ./deploy-dir/manifest.json`
3. **Test Alert:**
   - Linux: `cat ~/.bitcoin/wallet.dat`
   - Windows: `type %APPDATA%\Bitcoin\wallet.dat`
4. **Confirm in Wazuh:** Search for Rule ID `100501` in the Wazuh dashboard.
