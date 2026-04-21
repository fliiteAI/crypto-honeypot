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
    - [Containerized Deployment](#containerized-deployment)
6. [Honeypot Artifact Generation](#honeypot-artifact-generation)
7. [Browser Extension Path Mappings](#browser-extension-path-mappings)
8. [Deployment Verification](#deployment-verification)

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

For SMB environments, we recommend running the Wazuh Manager on dedicated hardware:
- **Primary Recommendation:** Raspberry Pi 5 (8GB RAM).
- **Secondary Recommendation:** Raspberry Pi 4 (8GB RAM).
- **Storage:** High-endurance microSD card or USB 3.0 SSD (preferred).

---

## Network Requirements

Ensure the following ports are open on the Wazuh Manager to allow agent communication:

| Port | Protocol | Service | Description |
|------|----------|---------|-------------|
| 1514 | TCP/UDP | Agent Communication | For event data and log collection |
| 1515 | TCP | Agent Enrollment | For registering new agents |

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
Add the honeypot monitoring paths to `/var/ossec/etc/ossec.conf` inside the `<syscheck>` block. Use the `honeypot-deployer` CLI to generate a custom config:
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

### Containerized Deployment

To run a Wazuh agent inside a Docker container while maintaining high-fidelity `whodata` monitoring:

1. **Capabilities:** Run the container with `--cap-add=AUDIT_CONTROL`.
2. **PID Namespace:** Use `--pid=host` to allow the agent to see host process IDs for audit logs.
3. **Identification:** Pass the `NODE_NAME` environment variable to identify the container.

Example command:
```bash
docker run -d --name wazuh-agent \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -e WAZUH_MANAGER="192.168.1.100" \
  -e NODE_NAME="honeypot-node-01" \
  -v /path/to/artifacts:/mnt/artifacts:ro \
  wazuh/wazuh-agent:latest
```

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

## Browser Extension Path Mappings

The honeypot targets the following standard extension IDs:
- **MetaMask:** `nkbihfbeogaeaoehlefnkodbefgpgknn`
- **Phantom:** `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- **Coinbase Wallet:** `hnfanknocfeofbddgcijnmhnfnkdnaad`
- **Binance Wallet:** `cadiboklkpojfamcoggejbbdjcoiljjk`
- **TronLink:** `ibnejdfjmmkpcnlpebklmnkoeoihofec`

### Path Templates

| OS | Browser | Path Template |
|----|---------|---------------|
| **Linux** | Chrome | `~/.config/google-chrome/Default/Local Extension Settings/<ID>` |
| **Linux** | Brave | `~/.config/BraveSoftware/Brave-Browser/Default/Local Extension Settings/<ID>` |
| **Linux** | Firefox | `~/.mozilla/firefox/*.default*/storage/default/moz-extension+++<ID>` |
| **Windows** | Chrome | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\<ID>` |
| **Windows** | Edge | `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Local Extension Settings\<ID>` |
| **Windows** | Brave | `%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Local Extension Settings\<ID>` |
| **macOS** | Chrome | `~/Library/Application Support/Google/Chrome/Default/Local Extension Settings/<ID>` |

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
