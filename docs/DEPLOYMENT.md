# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.

**Recommended Hardware (Wazuh Manager):**
For SMB environments, we recommend running the Wazuh Manager on:
- **Device:** Raspberry Pi 4 (8GB) or Raspberry Pi 5.
- **Storage:** High-endurance microSD card or, preferably, a USB 3.0 SSD.

**Connectivity Requirements:**
The following ports must be open on the Wazuh Manager:
- `1514/TCP/UDP`: Agent event communication.
- `1515/TCP`: Agent enrollment.
- `55000/TCP`: Wazuh API.

### Supported Operating Systems
- **Linux:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
- **Windows:** Windows 10/11 or Windows Server 2016+.

---

## Wazuh Manager Configuration

The Wazuh Manager must be configured with custom decoders and rules to recognize honeypot-specific logs.

### 1. Manual Configuration
Copy the configuration files to the manager:

```bash
# Decoders
sudo cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/

# Rules
sudo cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/

# Active Response (Optional)
sudo cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
sudo chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
sudo chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
```

### 2. Restart Service
```bash
sudo systemctl restart wazuh-manager
```

---

## Wazuh Agent Configuration

### Linux Setup

#### 1. Auditd Installation
`auditd` is required for high-fidelity `whodata` monitoring (Layer 2), which provides user attribution for file access.
```bash
sudo apt update && sudo apt install auditd -y
```

#### 2. Configure FIM
Add the following to `/var/ossec/etc/ossec.conf` inside the `<syscheck>` block. Use `whodata="yes"` for paths where `auditd` is configured.

```xml
<directories check_all="yes" report_changes="yes" realtime="yes" whodata="yes">/home/*/.bitcoin</directories>
<directories check_all="yes" report_changes="yes" realtime="yes" whodata="yes">/home/*/.ethereum</directories>
<directories check_all="yes" report_changes="yes" realtime="yes" whodata="yes">/home/*/.config/solana</directories>
```

Alternatively, use the CLI to generate a config snippet based on your manifest:
```bash
honeypot-deployer wazuh-config --manifest ./manifest.json --os linux
```

#### 3. Install Audit Rules
```bash
sudo cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
sudo auditctl -R /etc/audit/rules.d/honeypot.rules
```

### Windows Setup

#### 1. Sysmon (Recommended)
Install [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon) for enhanced process-level visibility. A sample configuration is provided in `wazuh/agent-config/honeypot-sysmon.xml`.

#### 2. Configure FIM
Edit `C:\Program Files (x86)\ossec-agent\ossec.conf` to include the honeypot paths (e.g., `%APPDATA%\Bitcoin`).

---

## Containerized Deployment (Docker)

To run a Wazuh agent inside a container with high-fidelity monitoring enabled:

1. **Privileges:** The container requires `--cap-add=AUDIT_CONTROL` and `--pid=host` to interact with the host's audit system.
2. **Environment:** Set the `NODE_NAME` variable to identify the agent.
3. **Volumes:** Mount the directories where artifacts will be stored.

```bash
docker run -d \
  --name wazuh-agent \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -e WAZUH_MANAGER='192.168.1.100' \
  -e NODE_NAME='prod-web-01' \
  -v /opt/honeypots:/opt/honeypots \
  wazuh/wazuh-agent:4.7.2
```

---

## Browser Extension Paths

The `honeypot-deployer` generates decoys for popular extensions. They should be placed in the following locations:

### Chrome-based (Chrome, Edge, Brave)
- **Linux:** `~/.config/google-chrome/Default/Local Extension Settings/`
- **Windows:** `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\`

### Firefox
- **Linux:** `~/.mozilla/firefox/*.default*/storage/default/`
- **Naming:** Folders should use the `moz-extension+++` convention.

**Supported Extension IDs:**
- MetaMask: `nkbihfbeogaeaoehlefnkodbefgpgknn`
- Phantom: `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- Coinbase Wallet: `hnfanknocfeofbddgcijnmhnfnkdnaad`

---

## Deployment Verification

1. **Health Check:**
   ```bash
   honeypot-deployer health-check --manifest ./manifest.json
   ```
2. **Simulate Attack:**
   On Linux: `cat ~/.bitcoin/wallet.dat`
   On Windows: `type %APPDATA%\Bitcoin\wallet.dat`
3. **Verify Alert:**
   Check the Wazuh dashboard for Rule ID `100501` (Wallet file accessed).
