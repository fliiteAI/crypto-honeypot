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
6. [Honeypot Artifact Generation](#honeypot-artifact-generation)
7. [Browser Extension Path Mappings](#browser-extension-path-mappings)
8. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.

### Supported Operating Systems
- **Linux:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
- **Windows:** Windows 10/11 or Windows Server 2016+.

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

For SMB environments, we recommend running the Wazuh Manager on dedicated hardware to ensure performance and reliability.

- **Recommended Device:** Raspberry Pi 4 (8GB) or Raspberry Pi 5.
- **Storage:** High-endurance microSD card or, preferably, a USB 3.0 SSD for better I/O performance.
- **Power:** Official Raspberry Pi power supply to prevent throttling.

---

## Network Requirements

Ensure the following ports are open on the Wazuh Manager to allow agent communication:

| Port | Protocol | Description |
|------|----------|-------------|
| 1514 | TCP/UDP  | Agent event communication (FIM, logs, etc.) |
| 1515 | TCP      | Agent enrollment and registration |

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
To automatically capture forensic data or lockout accounts when a honeypot is accessed:
```bash
cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
```
The system is also configured to support account lockout via `disable-account` for high-severity alerts.

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

To run a Wazuh agent within a Docker container while maintaining high-fidelity monitoring:

1. **Run with elevated privileges:**
   ```bash
   docker run -d --name wazuh-agent \
     --cap-add=AUDIT_CONTROL \
     --pid=host \
     -e WAZUH_MANAGER="MANAGER_IP" \
     -e NODE_NAME="CONTAINER_NAME" \
     -v /path/to/artifacts:/mnt/honeypot:ro \
     wazuh/wazuh-agent:latest
   ```
2. **Persistence:** Ensure honeypot artifacts are mounted from the host or a persistent volume.

---

## Honeypot Artifact Generation

Use the `honeypot-deployer` CLI to generate unique, randomized artifacts.

```bash
# Generate artifacts
honeypot-deployer generate --output ./my-artifacts

# Health check
honeypot-deployer health-check --manifest ./my-artifacts/manifest.json
```

---

## Browser Extension Path Mappings

The honeypot targets common paths used by info-stealer malware to find wallet data.

| Browser | Extension | Linux Path | Windows Path |
|---------|-----------|------------|--------------|
| Chrome | MetaMask | `~/.config/google-chrome/Default/Local Extension Settings/nkbihfbeogaeaoehlefnkodbefgpgknn/` | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\nkbihfbeogaeaoehlefnkodbefgpgknn\` |
| Chrome | Phantom | `~/.config/google-chrome/Default/Local Extension Settings/bfnaelmomeimhlpmgjnjophhpkkoljpa/` | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\bfnaelmomeimhlpmgjnjophhpkkoljpa\` |
| Firefox | Multiple | `~/.mozilla/firefox/*.default*/storage/default/` | `%APPDATA%\Mozilla\Firefox\Profiles\*.default*\storage\default\` |

*Note: Firefox uses the `moz-extension+++` naming convention for decoy folders within the storage directory.*

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
