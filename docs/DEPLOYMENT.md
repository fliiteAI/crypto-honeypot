# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Wazuh Manager Configuration](#wazuh-manager-configuration)
3. [Wazuh Agent Configuration](#wazuh-agent-configuration)
    - [Linux Setup](#linux-setup)
    - [Windows Setup](#windows-setup)
4. [Browser Extension Path Reference](#browser-extension-path-reference)
5. [Honeypot Artifact Generation](#honeypot-artifact-generation)
6. [Containerized Deployment (Docker)](#containerized-deployment-docker)
7. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher.
- **Hardware Recommendation:**
    - Raspberry Pi 4 (8GB) or Raspberry Pi 5.
    - High-endurance microSD card or USB 3.0 SSD (preferred).
- **Network Connectivity:**
    - Port **1514 (TCP/UDP)**: Agent event communication.
    - Port **1515 (TCP)**: Agent enrollment.

### Endpoint Requirements
#### Linux
- **Operating Systems:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
- **Python:** 3.10+ (required for running the `honeypot-deployer` CLI).
- **Packages:** `auditd` (essential for `whodata` FIM support and user attribution).
- **Permissions:** Root/sudo access for installing audit rules and modifying Wazuh configuration.

#### Windows
- **Operating Systems:** Windows 10/11 or Windows Server 2016+.
- **PowerShell:** 5.1 or higher.
- **Sysmon:** Recommended for enhanced process-level visibility.
- **Permissions:** Administrator privileges for modifying Wazuh configuration and deploying artifacts.

---

## Wazuh Manager Configuration

### 1. Manual Configuration
Before deploying agents, the Wazuh Manager must be configured to recognize honeypot-specific logs and trigger alerts.

**Copy custom decoders:**
```bash
cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/
```

**Copy custom rules:**
```bash
cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/
```

**Restart Wazuh Manager:**
```bash
systemctl restart wazuh-manager
```

### 2. (Optional) Active Response
To automatically capture forensic data when a honeypot is accessed:
```bash
cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
```
Add the following to your manager's `/var/ossec/etc/ossec.conf`:
```xml
<active-response>
  <command>honeypot-forensic-snapshot</command>
  <location>local</location>
  <rules_group>crypto_honeypot</rules_group>
</active-response>
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
Add the honeypot monitoring paths to `/var/ossec/etc/ossec.conf` inside the `<syscheck>` block. You can use the `honeypot-deployer wazuh-config` command to generate the snippet.

#### 3. Install Audit Rules
```bash
cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
sudo auditctl -R /etc/audit/rules.d/honeypot.rules
```

### Windows Setup

#### 1. Install Sysmon (Recommended)
Download and install [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon) and apply the honeypot-specific rules.

#### 2. Configure FIM
Edit `C:\Program Files (x86)\ossec-agent\ossec.conf` and add the honeypot directories to the `<syscheck>` section.

---

## Browser Extension Path Reference

Honeypot decoys should be placed in the following locations to be effective:

| Browser | OS | Path |
|---------|----|------|
| **Chrome** | Linux | `~/.config/google-chrome/Default/Local Extension Settings/` |
| | Windows | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\` |
| **Edge** | Windows | `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Local Extension Settings\` |
| **Brave** | Linux | `~/.config/BraveSoftware/Brave-Browser/Default/Local Extension Settings/` |
| | Windows | `%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Local Extension Settings\` |
| **Firefox** | Linux | `~/.mozilla/firefox/*.default*/storage/default/` |
| | Windows | `%APPDATA%\Mozilla\Firefox\Profiles\*.default*\storage\default\` |

---

## Honeypot Artifact Generation

### Using the CLI (Recommended)
```bash
# Generate artifacts
honeypot-deployer generate --output ./my-artifacts

# Generate Wazuh config snippet for these artifacts
honeypot-deployer wazuh-config --manifest ./my-artifacts/manifest.json --os linux
```

---

## Containerized Deployment (Docker)

You can run the honeypot in a containerized environment. Ensure that the Wazuh agent inside the container has access to the host's audit logs if `whodata` is required.

```bash
docker run -d --name wazuh-agent-honeypot \
  -e WAZUH_MANAGER="manager-ip" \
  -e NODE_NAME="honeypot-node" \
  -v /path/to/artifacts:/mnt/honeypot:ro \
  wazuh/wazuh-agent:latest
```

**Note:** For full `auditd` support in Docker, you may need to run the container with `--cap-add=AUDIT_CONTROL --pid=host`.

---

## Deployment Verification

1. **Verify Artifacts:** `honeypot-deployer health-check --manifest ./my-artifacts/manifest.json`
2. **Trigger Alert:** `cat ~/.bitcoin/wallet.dat`
3. **Dashboard:** Confirm Level 12+ alert in Wazuh.
