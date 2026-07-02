# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system with Wazuh SIEM integration.

## 1. System Requirements

### Hardware Recommendations
- **Wazuh Manager:** Raspberry Pi 4 (8GB) or 5 with a high-endurance microSD card or USB 3.0 SSD (preferred for SMB environments).
- **Storage:** Minimum 32GB for the manager; minimal impact on agent endpoints.

### OS Compatibility
- **Linux:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
- **Windows:** Windows 10/11, Windows Server 2016/2019/2022.
- **macOS:** Monterey (12.x) and newer.

### Network Requirements
Ensure the following ports are open on the Wazuh Manager:
- **1514 (TCP/UDP):** Agent event communication.
- **1515 (TCP):** Agent enrollment.
- **55000 (TCP):** Wazuh API.

---

## 2. Wazuh Manager Configuration

### 1. Install Decoders & Rules
Copy the custom configurations to your Wazuh Manager (requires root):
```bash
sudo cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/
sudo cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/
```

### 2. Configure Active Response
To automatically capture forensic data when a honeypot is accessed:
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

## 3. Wazuh Agent Configuration

### Linux Setup
1. **Install auditd:** Required for `whodata` monitoring.
   ```bash
   sudo apt update && sudo apt install auditd -y
   ```
2. **Apply Audit Rules:**
   ```bash
   sudo cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
   sudo auditctl -R /etc/audit/rules.d/honeypot.rules
   ```
3. **Configure FIM:** Use the `honeypot-deployer wazuh-config` command to generate the specific paths for your manifest and add them to `/var/ossec/etc/ossec.conf`.

### Windows Setup
1. **Install Sysmon:** We recommend using [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon) with the provided `wazuh/agent-config/honeypot-sysmon.xml` config.
2. **Configure FIM:** Add generated paths to `C:\Program Files (x86)\ossec-agent\ossec.conf`.

---

## 4. Browser Extension Path Mappings

The honeypot generator creates decoys for multiple browsers. Ensure your FIM config includes these paths:

| Browser | OS | Path Template |
|---------|----|---------------|
| **Chrome** | Linux | `~/.config/google-chrome/Default/Local Extension Settings/` |
| **Chrome** | Windows | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\` |
| **Edge** | Windows | `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Local Extension Settings\` |
| **Brave** | Linux | `~/.config/BraveSoftware/Brave-Browser/Default/Local Extension Settings/` |
| **Firefox** | Linux | `~/.mozilla/firefox/*.default*/storage/default/moz-extension+++*/` |

---

## 5. Containerized Deployment (Docker)

To run the Wazuh Agent in a container while monitoring honeypots:

```yaml
services:
  wazuh-agent:
    image: wazuh/wazuh-agent:4.x
    environment:
      - WAZUH_MANAGER=192.168.1.100
      - NODE_NAME=honeypot-endpoint-01
    cap_add:
      - AUDIT_CONTROL
    pid: host
    volumes:
      - ./honeypot-artifacts:/opt/honeypot:ro
      - /var/run/docker.sock:/var/run/docker.sock
```
*Note: `--cap-add=AUDIT_CONTROL` and `pid: host` are required if you want the containerized agent to use the host's auditd for whodata.*

---

## 6. Verification

1. **Health Check:** `honeypot-deployer health-check --manifest ./manifest.json`
2. **Test Trigger:** `cat ~/.bitcoin/wallet.dat` (Linux) or `type %APPDATA%\Bitcoin\wallet.dat` (Windows).
3. **Alert Confirmation:** Check the Wazuh Dashboard for Rule ID `100501`.
