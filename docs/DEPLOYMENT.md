# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Wazuh Manager Configuration](#wazuh-manager-configuration)
3. [Wazuh Agent Configuration](#wazuh-agent-configuration)
    - [Linux Setup](#linux-setup)
    - [Windows Setup](#windows-setup)
    - [Containerized Deployment (Docker)](#containerized-deployment-docker)
4. [Honeypot Artifact Generation](#honeypot-artifact-generation)
5. [Deployment Verification](#deployment-verification)

---

## System Requirements

### Hardware Recommendations (SMB/Home Lab)
For a dedicated Wazuh Manager in an SMB environment:
- **Device:** Raspberry Pi 4 (8GB) or Raspberry Pi 5.
- **Storage:** High-endurance microSD card or, preferably, a USB 3.0 SSD for better I/O performance and reliability.
- **Network:** Wired Ethernet connection.

### Supported Operating Systems
- **Linux:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
- **Windows:** Windows 10/11, Windows Server 2016+.
- **macOS:** Monterey (12.x)+ (FIM support only).

### Network Requirements
Ensure the following ports are open on the Wazuh Manager:
- **1514 (TCP/UDP):** Agent event communication.
- **1515 (TCP):** Agent enrollment.
- **55000 (TCP):** Wazuh API (for management).

---

## Wazuh Manager Configuration

### 1. Install Decoders & Rules
Copy the custom configuration files to your Wazuh Manager:
```bash
# Decoders
sudo cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/

# Rules
sudo cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/
```

### 2. Active Response Setup
To enable automated forensic snapshots:
```bash
sudo cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
sudo chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
sudo chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
```

### 3. Restart Service
```bash
sudo systemctl restart wazuh-manager
```

---

## Wazuh Agent Configuration

### Linux Setup
1. **Install auditd:** Required for `whodata` (identifying the user who accessed the file).
   ```bash
   sudo apt update && sudo apt install auditd -y
   ```
2. **Configure FIM:** Generate the FIM config snippet:
   ```bash
   honeypot-deployer wazuh-config --manifest manifest.json --os linux
   ```
   Add the output to `/var/ossec/etc/ossec.conf` within the `<syscheck>` block.
3. **Apply Audit Rules:**
   ```bash
   sudo cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/
   sudo auditctl -R /etc/audit/rules.d/honeypot-audit.rules
   ```

### Windows Setup
1. **Install Sysmon:** Use the provided configuration for process tracking:
   ```powershell
   sysmon.exe -i wazuh/agent-config/honeypot-sysmon.xml
   ```
2. **Configure FIM:** Add the monitored paths to `C:\Program Files (x86)\ossec-agent\ossec.conf`.

### Containerized Deployment (Docker)
To run the Wazuh Agent within a container while maintaining high-fidelity monitoring:
- Use the `--cap-add=AUDIT_CONTROL` flag to allow the agent to interact with the host's audit system.
- Use `--pid=host` to allow the agent to see processes running on the host for correlation.

```bash
docker run -d --name wazuh-agent \
  -e WAZUH_MANAGER="192.168.1.100" \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -v /home/user:/home/user:ro \
  wazuh/wazuh-agent:latest
```

---

## Honeypot Artifact Generation

Use the `honeypot-deployer` CLI to generate randomized, realistic artifacts.

```bash
# Install
pip install .

# Generate (Manifest is encrypted by default)
honeypot-deployer generate --output ./artifacts

# Export public addresses for Layer 4 monitoring
honeypot-deployer export-addresses --manifest ./artifacts/manifest.json --output addresses.json
```

---

## Deployment Verification

1. **Check Agent Status:** `sudo /var/ossec/bin/agent_control -l` (on manager).
2. **Simulate Access:** `cat ~/.bitcoin/wallet.dat` (on agent).
3. **Verify Alert:** Look for Rule ID `100501` in the Wazuh dashboard or `/var/ossec/logs/alerts/alerts.json`.
