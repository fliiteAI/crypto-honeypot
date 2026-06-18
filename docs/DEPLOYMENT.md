# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Supported Operating Systems](#supported-operating-systems)
3. [Wazuh Manager Configuration](#wazuh-manager-configuration)
4. [Wazuh Agent Configuration](#wazuh-agent-configuration)
    - [Linux Setup](#linux-setup)
    - [Windows Setup](#windows-setup)
    - [Containerized Deployment (Docker)](#containerized-deployment-docker)
5. [Browser Extension Path Reference](#browser-extension-path-reference)
6. [Honeypot Artifact Generation](#honeypot-artifact-generation)
7. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Wazuh Infrastructure
- **Wazuh Manager:** version 4.x or higher.
- **Wazuh Agent:** version 4.x or higher installed on all target endpoints.
- **Network:**
    - Port `1514` (TCP/UDP) must be open on the Manager for agent communication.
    - Port `1515` (TCP) must be open on the Manager for agent enrollment.

### Hardware Recommendations (Manager)
For SMB environments, we recommend running the Wazuh Manager on:
- **Raspberry Pi 4 (8GB)** or **Raspberry Pi 5**.
- **Storage:** High-endurance microSD card (minimum 64GB) or a USB 3.0 SSD (preferred).

---

## Supported Operating Systems

The honeypot artifacts and Wazuh configurations are tested on:

### Linux
- **Ubuntu:** 20.04, 22.04 LTS
- **Debian:** 11, 12
- **RHEL/AlmaLinux/Rocky Linux:** 8.x, 9.x

### Windows
- **Windows 10/11** (Home/Pro/Enterprise)
- **Windows Server:** 2016, 2019, 2022

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

### 3. Restart Wazuh Manager
```bash
systemctl restart wazuh-manager
```

---

## Wazuh Agent Configuration

### Linux Setup

#### 1. Install Auditd
`auditd` is required for high-fidelity "whodata" monitoring, which tracks *who* (user and process) accessed a file.
```bash
sudo apt update && sudo apt install auditd -y
```

#### 2. Configure FIM
Add the honeypot monitoring paths to `/var/ossec/etc/ossec.conf` inside the `<syscheck>` block. Use the `honeypot-deployer` CLI to generate a localized config:
```bash
honeypot-deployer wazuh-config --manifest ./manifest.json --os linux
```

#### 3. Install Audit Rules
```bash
cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
sudo auditctl -R /etc/audit/rules.d/honeypot.rules
```

### Windows Setup

#### 1. Install Sysmon (Recommended)
Download and install [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon). Use the provided template for honeypot-specific process monitoring:
`wazuh/agent-config/honeypot-sysmon.xml`

#### 2. Configure FIM
Edit `C:\Program Files (x86)\ossec-agent\ossec.conf` and add the honeypot directories to the `<syscheck>` section. Use the CLI to generate the correct XML snippet.

### Containerized Deployment (Docker)

To monitor files within a Docker container, ensure the Wazuh agent is installed in the container image or running on the host with visibility into the container's volume mounts.

**Note on `whodata` in Docker:**
To use `whodata` (auditd) inside a container, you must run the container with:
- `--cap-add=AUDIT_CONTROL`
- `--pid=host` (to allow the agent to see host-level process IDs)

---

## Browser Extension Path Reference

The honeypot targets the following standard extension storage paths. Ensure your Wazuh FIM configuration includes these:

| Browser | OS | Path Pattern |
|---------|----|--------------|
| **Chrome** | Linux | `~/.config/google-chrome/Default/Local Extension Settings/` |
| **Chrome** | Windows | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\` |
| **Brave** | Linux | `~/.config/BraveSoftware/Brave-Browser/Default/Local Extension Settings/` |
| **Brave** | Windows | `%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Local Extension Settings\` |
| **Edge** | Windows | `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Local Extension Settings\` |
| **Firefox** | Linux | `~/.mozilla/firefox/*.default*/storage/default/` |

---

## Honeypot Artifact Generation

### Using the CLI (Recommended)
```bash
pip install .
honeypot-deployer generate --output ./my-artifacts
```

### Standalone Scripts
For quick deployments without Python:
- **Linux:** `./deploy.sh`
- **Windows:** `.\deploy.ps1`

---

## Deployment Verification

1. **Verify Artifacts:**
   `honeypot-deployer health-check --manifest ./my-artifacts/manifest.json`
2. **Trigger a Test Alert:**
   `cat ~/.bitcoin/wallet.dat` (Linux)
3. **Check Wazuh Dashboard:** Confirm a high-severity alert appears in the "Security Events" tab.
