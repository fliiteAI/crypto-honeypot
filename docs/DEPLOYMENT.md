# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Hardware Recommendations](#hardware-recommendations)
3. [OS-Specific Requirements](#os-specific-requirements)
4. [Wazuh Manager Configuration](#wazuh-manager-configuration)
5. [Wazuh Agent Configuration](#wazuh-agent-configuration)
6. [Honeypot Artifact Generation](#honeypot-artifact-generation)
7. [Standard Monitored Paths](#standard-monitored-paths)
8. [Containerized Deployment](#containerized-deployment)
9. [Deployment Verification](#deployment-verification)

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

For SMB environments, we recommend the following hardware for the Wazuh Manager:
- **Raspberry Pi 4 (8GB)** or **Raspberry Pi 5**.
- High-endurance microSD card or USB 3.0 SSD for storage.
- Wired Ethernet connection for stability.

---

## OS-Specific Requirements

### Linux: Auditd
`auditd` is required for high-fidelity "whodata" monitoring, which tracks *who* accessed a file. Without `auditd`, Wazuh FIM can only detect *that* a file was accessed, but not the specific process or user responsible.

### Windows: Sysmon
While Wazuh FIM works natively on Windows, installing Sysmon provides deep visibility into process trees, network connections, and DNS queries triggered after a honeypot access.

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
```bash
sudo apt update && sudo apt install auditd -y
```

#### 2. Configure FIM
Add the honeypot monitoring paths to `/var/ossec/etc/ossec.conf` inside the `<syscheck>` block. Use the `honeypot-deployer` to generate the exact config for your deployed artifacts:
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

## Honeypot Artifact Generation

### Using the CLI (Recommended)
The CLI generates unique, randomized artifacts and tracks them in an encrypted manifest for high-fidelity monitoring and on-chain correlation.

```bash
# 1. Install the tool
pip install .

# 2. Generate artifacts
honeypot-deployer generate --output ./my-artifacts

# 3. View the generated manifest
honeypot-deployer show --manifest ./my-artifacts/manifest.json
```

---

## Standard Monitored Paths

The honeypot targets common wallet locations to maximize the chance of discovery by infostealers.

### Linux Paths
- **Bitcoin:** `~/.bitcoin/wallet.dat`
- **Ethereum:** `~/.ethereum/keystore/`
- **Solana:** `~/.config/solana/id.json`
- **Electrum:** `~/.electrum/wallets/`
- **Exodus:** `~/.config/Exodus/exodus.wallet/`
- **Browser Extensions (Chrome):** `~/.config/google-chrome/Default/Local Extension Settings/<extension_id>`

### Windows Paths
- **Bitcoin:** `%APPDATA%\Bitcoin\wallet.dat`
- **Ethereum:** `%APPDATA%\Ethereum\keystore\`
- **Solana:** `%USERPROFILE%\.config\solana\id.json`
- **Exodus:** `%APPDATA%\Exodus\exodus.wallet\`

---

## Containerized Deployment

When running the Wazuh agent inside a container, special configuration is required to support `whodata` monitoring via `auditd`.

### Docker Run Requirements
You must grant the container access to the host's audit system:
```bash
docker run -d \
  --name wazuh-agent \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e NODE_NAME=my-container-agent \
  wazuh/wazuh-agent:latest
```

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
