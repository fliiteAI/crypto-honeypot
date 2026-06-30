# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## System Requirements

### Hardware Recommendations (Wazuh Manager)
For SMB environments, the Wazuh Manager can be deployed on cost-effective hardware:
- **Recommended:** Raspberry Pi 4 (8GB) or Raspberry Pi 5.
- **Storage:** High-endurance microSD card or, preferably, a USB 3.0 SSD for better IOPS.
- **Connectivity:** Ethernet connection (avoid Wi-Fi for the manager).

### Supported Operating Systems (Wazuh Agent)
- **Ubuntu:** 20.04, 22.04, 24.04 LTS
- **Debian:** 11, 12
- **RHEL/AlmaLinux/Rocky Linux:** 8, 9
- **Windows:** 10, 11, Server 2016, 2019, 2022

### Network Requirements
Ensure the following ports are open on the Wazuh Manager:
- **1514 (TCP/UDP):** Agent event communication.
- **1515 (TCP):** Agent enrollment.

---

## Wazuh Manager Configuration

### 1. Install Decoders & Rules
Manual configuration involves copying files to the manager's configuration directories:
```bash
# Copy decoders
sudo cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/

# Copy rules
sudo cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/

# Restart service
sudo systemctl restart wazuh-manager
```

### 2. Configure Active Response
Active response can trigger automated actions (like account lockout) when a honeypot is accessed.
```bash
sudo cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
sudo chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
sudo chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
```

---

## Wazuh Agent Configuration

### Linux Setup
High-fidelity detection on Linux requires `auditd` for "whodata" monitoring.

1. **Install auditd:** `sudo apt install auditd -y`
2. **Apply Audit Rules:**
   ```bash
   sudo cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
   sudo auditctl -R /etc/audit/rules.d/honeypot.rules
   ```
3. **Configure FIM:** Use the `honeypot-deployer wazuh-config` CLI command to generate a tailored `<syscheck>` configuration based on your manifest.

### Windows Setup
1. **Sysmon:** It is highly recommended to install Sysmon for process-level visibility.
2. **Permissions:** Ensure the Wazuh Agent is running with SYSTEM privileges (default).

---

## Browser Extension Path Mappings

The honeypot targets standard extension storage locations:

| Browser | OS | Path Mapping |
|---------|----|--------------|
| **Chrome** | Linux | `~/.config/google-chrome/Default/Local Extension Settings/` |
| **Chrome** | Windows | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\` |
| **Edge** | Windows | `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Local Extension Settings\` |
| **Brave** | Linux | `~/.config/BraveSoftware/Brave-Browser/Default/Local Extension Settings/` |
| **Firefox** | Linux | `~/.mozilla/firefox/*.default*/storage/default/` |

---

## Containerized Deployment (Docker)

To run a Wazuh agent in a container while maintaining high-fidelity monitoring:
1. **Capabilities:** Add `--cap-add=AUDIT_CONTROL`.
2. **PID Namespace:** Use `--pid=host` to allow the agent to see host processes.
3. **Volume Mounts:** Mount the host directories you wish to monitor into the container.

Example:
```bash
docker run -d --name wazuh-agent \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -e WAZUH_MANAGER='192.168.1.100' \
  -v /home:/home:ro \
  wazuh/wazuh-agent:latest
```

---

## Honeypot Artifact Generation

Use the CLI to generate artifacts:
```bash
honeypot-deployer generate --output ./test-dir --no-encrypt-manifest
```
Always verify the generation with:
```bash
honeypot-deployer health-check --manifest ./test-dir/manifest.json
```
