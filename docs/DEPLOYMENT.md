# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Wazuh Manager Configuration](#wazuh-manager-configuration)
3. [Wazuh Agent Configuration](#wazuh-agent-configuration)
4. [Honeypot Artifact Generation](#honeypot-artifact-generation)
5. [Browser Extension Path Mappings](#browser-extension-path-mappings)
6. [Containerized Deployment](#containerized-deployment)
7. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Hardware Recommendations (SMB/SOHO)
For SMB environments, we recommend running the Wazuh Manager on dedicated hardware:
- **Primary Choice:** Raspberry Pi 5 (8GB RAM) with NVMe SSD.
- **Secondary Choice:** Raspberry Pi 4 (8GB RAM) with High-Endurance SD card.
- **Enterprise:** Any modern Linux server (x86_64) with 4+ vCPUs and 8GB+ RAM.

### Supported Operating Systems
- **Wazuh Manager:** Ubuntu 20.04/22.04+, Debian 11/12, RHEL/AlmaLinux 8/9.
- **Monitored Endpoints:**
  - **Linux:** Ubuntu, Debian, CentOS, RHEL, Fedora, Arch.
  - **Windows:** Windows 10/11, Windows Server 2016/2019/2022.
  - **macOS:** 11.0 (Big Sur) and newer.

---

## Wazuh Manager Configuration

Before deploying agents, the Wazuh Manager must be configured to recognize honeypot-specific logs and trigger alerts.

### 1. Install Decoders & Rules
Copy the custom configuration files from the `wazuh/` directory to your Wazuh Manager:
```bash
# Decoders
cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/

# Rules
cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/

# Restart Manager
systemctl restart wazuh-manager
```

### 2. (Optional) Active Response
To automatically capture forensic data when a honeypot is accessed:
```bash
cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
```
Add the corresponding `<active-response>` block to your manager's `ossec.conf`.

---

## Wazuh Agent Configuration

### Linux Setup (with Auditd)
`auditd` is essential for "whodata" FIM, providing the user attribution (who accessed the file).

1. **Install Auditd:** `sudo apt install auditd -y`
2. **Apply Audit Rules:**
   ```bash
   cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
   sudo auditctl -R /etc/audit/rules.d/honeypot.rules
   ```
3. **Configure FIM:** Use the `honeypot-deployer wazuh-config` command to generate the `<syscheck>` snippet for your `ossec.conf`.

### Windows Setup (with Sysmon)
1. **Install Sysmon:** Use the configuration provided in `wazuh/agent-config/honeypot-sysmon.xml`.
2. **Configure FIM:** Ensure the Wazuh agent has read access to the honeypot paths.

---

## Honeypot Artifact Generation

Use the `honeypot-deployer` CLI to generate realistic, randomized artifacts.

```bash
# Install the tool
pip install .

# Generate all artifacts (BTC, ETH, SOL, Seed phrases, Browser decoys)
# This also generates 'manifest.json' (keep this file secure!)
honeypot-deployer generate --output ./my-honeypot

# Generate Wazuh FIM config tailored to your generated artifacts
honeypot-deployer wazuh-config --manifest ./my-honeypot/manifest.json --os linux
```

---

## Browser Extension Path Mappings

The honeypot deployer places decoys in the standard local storage paths used by popular browsers.

| Browser | OS | Path Template |
|---------|----|---------------|
| **Chrome** | Linux | `~/.config/google-chrome/Default/Local Extension Settings/` |
| **Chrome** | Windows | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\` |
| **Brave** | Linux | `~/.config/BraveSoftware/Brave-Browser/Default/Local Extension Settings/` |
| **Edge** | Windows | `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Local Extension Settings\` |
| **Firefox** | Linux | `~/.mozilla/firefox/*.default-release/storage/default/` |

**Monitored IDs:**
- **MetaMask:** `nkbihfbeogaeaoehlefnkodbefgpgknn`
- **Phantom:** `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- **Coinbase:** `hnfanknocfeofbddgcijnmhnfnkdnaad`

---

## Containerized Deployment

When deploying the Wazuh agent in a Docker container to monitor a host, use the following requirements for full Layer 2 (Auditd) visibility:

```bash
docker run -d --name wazuh-agent \
  --privileged \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/ossec/etc:/var/ossec/etc \
  -e WAZUH_MANAGER="YOUR_MANAGER_IP" \
  wazuh/wazuh-agent:latest
```
*Note: `--privileged` and `--pid=host` are required for the agent to receive audit events from the host kernel.*

---

## Deployment Verification

1. **Check Artifacts:** `honeypot-deployer health-check --manifest ./my-honeypot/manifest.json`
2. **Trigger Test:** `cat ~/.bitcoin/wallet.dat` (on Linux) or `type %APPDATA%\Bitcoin\wallet.dat` (on Windows).
3. **Verify Alert:** Log into your Wazuh Dashboard and look for Rule ID **100501** (Wallet file accessed).
