# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## System Requirements

### Hardware Recommendations
For SMB environments, the **Raspberry Pi 4 (8GB) or Raspberry Pi 5** is the recommended hardware platform for the Wazuh Manager.
- **Storage:** High-endurance microSD card or USB 3.0 SSD (preferred).
- **Network:** Wired Ethernet connection.

### Supported Operating Systems
The `honeypot-deployer` and Wazuh agents are supported on the following distributions:
- **Ubuntu:** 20.04, 22.04 LTS
- **Debian:** 11, 12
- **RHEL/AlmaLinux/Rocky Linux:** 8, 9
- **Windows:** 10, 11, Server 2016, 2019, 2022

### Wazuh Connectivity
Ensure the following ports are open on the Wazuh Manager:
- **1514 (TCP/UDP):** Agent event communication.
- **1515 (TCP):** Agent enrollment.

---

## Wazuh Manager Configuration

1. **Decoders:** Copy `wazuh/decoders/honeypot_decoder.xml` to `/var/ossec/etc/decoders/`.
2. **Rules:** Copy `wazuh/rules/honeypot_rules.xml` to `/var/ossec/etc/rules/`.
3. **Active Response:**
   - Copy `wazuh/active-response/honeypot-forensic-snapshot.sh` to `/var/ossec/active-response/bin/`.
   - `chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh`
   - `chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh`
4. **Restart:** `systemctl restart wazuh-manager`.

---

## Wazuh Agent Configuration

### Linux Setup
1. **Install auditd:** `sudo apt install auditd -y`.
2. **Configure FIM:** Use `honeypot-deployer wazuh-config --os linux` to generate the snippet for `ossec.conf`.
3. **Audit Rules:** Deploy `wazuh/agent-config/honeypot-audit.rules` to `/etc/audit/rules.d/`.

### Windows Setup
1. **Sysmon:** Install Sysmon with the rules provided in `wazuh/agent-config/honeypot-sysmon.xml`.
2. **Configure FIM:** Use `honeypot-deployer wazuh-config --os windows` to generate the snippet for `ossec.conf`.

---

## Browser Extension Path Mappings

The honeypot decoys should be placed in the following directories to be discovered by info-stealer malware:

| Browser | OS | Path |
|---------|----|------|
| **Chrome** | Linux | `~/.config/google-chrome/Default/Local Extension Settings/` |
| | Windows | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\` |
| **Brave** | Linux | `~/.config/BraveSoftware/Brave-Browser/Default/Local Extension Settings/` |
| | Windows | `%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Local Extension Settings\` |
| **Edge** | Windows | `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Local Extension Settings\` |
| **Firefox** | Linux | `~/.mozilla/firefox/*.default*/storage/default/` |
| | Windows | `%APPDATA%\Mozilla\Firefox\Profiles\*.default*\storage\default\` |

*Note: For Firefox, the directory naming convention for extensions is `moz-extension+++[UUID]`.*

---

## Containerized Deployment (Docker)

To run the Wazuh agent in a containerized environment while monitoring honeypot artifacts:

```yaml
version: '3.8'
services:
  wazuh-agent:
    image: wazuh/wazuh-agent:latest
    environment:
      - WAZUH_MANAGER=wazuh.example.com
      - NODE_NAME=honeypot-container
    volumes:
      - ./honeypot-artifacts:/etc/honeypot:ro
      - /var/run/docker.sock:/var/run/docker.sock
    cap_add:
      - SYS_PTRACE
      - AUDIT_CONTROL # Required for whodata if auditd is used on host
    pid: "host" # Required for high-fidelity process auditing
```

---

## Verification

After deployment, verify the health of the artifacts:
```bash
honeypot-deployer health-check --manifest ./manifest.json
```
Test the detection by reading one of the honeyfiles and confirming the alert in the Wazuh dashboard.
