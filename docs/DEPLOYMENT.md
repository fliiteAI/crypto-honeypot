# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Hardware Recommendations](#hardware-recommendations)
3. [Wazuh Manager Configuration](#wazuh-manager-configuration)
4. [Wazuh Agent Configuration](#wazuh-agent-configuration)
    - [Linux Setup](#linux-setup)
    - [Windows Setup](#windows-setup)
    - [Containerized Deployment](#containerized-deployment)
5. [Honeypot Artifact Generation](#honeypot-artifact-generation)
6. [Monitored Paths Reference](#monitored-paths-reference)
7. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Supported Operating Systems
- **Linux:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
- **Windows:** Windows 10/11 or Windows Server 2016+.

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.
- **Network:** Ports 1514 (TCP/UDP) and 1515 (TCP) must be open on the Wazuh Manager for agent communication and enrollment.

---

## Hardware Recommendations

For SMB environments, the Wazuh Manager can be deployed on lightweight hardware:
- **Primary Recommendation:** Raspberry Pi 4 (8GB) or Raspberry Pi 5.
- **Storage:** High-endurance microSD card or USB 3.0 SSD (strongly preferred for performance).
- **Alternative:** Any x86_64 system with 4GB+ RAM and 2+ cores.

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

### 3. (Optional) Active Response
To automatically capture forensic data when a honeypot is accessed:
```bash
sudo cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
sudo chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
sudo chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
```

### 4. Restart Wazuh Manager
```bash
sudo systemctl restart wazuh-manager
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
sudo cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
sudo auditctl -R /etc/audit/rules.d/honeypot.rules
```

### Windows Setup

#### 1. Install Sysmon (Recommended)
Download and install [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon). Use a configuration that captures file access events for the honeypot paths.

#### 2. Configure FIM
Edit `C:\Program Files (x86)\ossec-agent\ossec.conf` and add the honeypot directories to the `<syscheck>` section. Use the `wazuh-config` CLI command to generate the XML snippet:
```bash
honeypot-deployer wazuh-config --manifest ./path/to/manifest.json --os windows
```

### Containerized Deployment

To run a Wazuh agent in a Docker container with full honeypot monitoring capabilities (including `whodata`), use the following flags:

```bash
docker run -d --name wazuh-agent \
  -e WAZUH_MANAGER='192.168.1.100' \
  -e NODE_NAME='crypto-honeypot-node' \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -v /path/to/honeypots:/mnt/honeypots:ro \
  wazuh/wazuh-agent:latest
```
*Note: `--cap-add=AUDIT_CONTROL` and `--pid=host` are required for the agent to interact with the host's audit subsystem.*

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
The `manifest.json` contains the private keys for the generated honeypots. **Always keep this file secure.** It is recommended to use the `--encrypt-manifest` flag (enabled by default) to protect it with a password.

---

## Monitored Paths Reference

Standard paths monitored by the honeypot system include:

### Linux
- **Bitcoin:** `~/.bitcoin/wallet.dat`
- **Ethereum:** `~/.ethereum/keystore/`
- **Solana:** `~/.config/solana/id.json`
- **Electrum:** `~/.electrum/wallets/`
- **Exodus:** `~/.config/Exodus/exodus.wallet/`
- **Browser Extensions:** `~/.config/google-chrome/Default/Local Extension Settings/nkbihfbeogaeaoehlefnkodbefgpgknn` (MetaMask)

### Windows
- **Bitcoin:** `%APPDATA%\Bitcoin\wallet.dat`
- **Ethereum:** `%APPDATA%\Ethereum\keystore\`
- **Solana:** `%USERPROFILE%\.config\solana\id.json`
- **Electrum:** `%APPDATA%\Electrum\wallets\`
- **Exodus:** `%APPDATA%\Exodus\exodus.wallet\`
- **Browser Extensions:** `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\nkbihfbeogaeaoehlefnkodbefgpgknn`

---

## Deployment Verification

1. **Verify Artifacts:** Run the health check command:
   ```bash
   honeypot-deployer health-check --manifest ./my-artifacts/manifest.json
   ```
2. **Trigger a Test Alert:**
   On a Linux agent: `cat ~/.bitcoin/wallet.dat`
   On a Windows agent: `type %APPDATA%\Bitcoin\wallet.dat`
3. **Check Wazuh Dashboard:** Confirm that a Level 12 (or higher) alert appears in the security events with Rule ID 100501.
