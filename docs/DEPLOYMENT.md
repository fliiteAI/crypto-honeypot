# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system.

## System Requirements

### Hardware Recommendations
For SMB environments, we recommend running the Wazuh Manager on a **Raspberry Pi 4 (8GB)** or **Raspberry Pi 5**. Use a high-endurance microSD card or, preferably, a USB 3.0 SSD for improved performance and reliability.

### OS Support
- **Ubuntu:** 20.04, 22.04 LTS
- **Debian:** 11, 12
- **RHEL/AlmaLinux:** 8, 9
- **Windows:** 10, 11, Server 2016+

### Network Connectivity
The following ports must be open on the Wazuh Manager:
- **1514 (TCP/UDP):** Agent event communication.
- **1515 (TCP):** Agent enrollment.

---

## Wazuh Manager Configuration

### 1. Decoders and Rules
Copy the custom configuration files to the Wazuh Manager:
```bash
# Custom decoders
sudo cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/

# Custom rules
sudo cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/
```

### 2. Active Response
To enable automated forensic snapshots:
```bash
sudo cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
sudo chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
sudo chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
```
Add the active response configuration to `/var/ossec/etc/ossec.conf` on the manager.

### 3. Restart Service
```bash
sudo systemctl restart wazuh-manager
```

---

## Wazuh Agent Configuration

### Linux Setup (Auditd)
High-fidelity detection on Linux requires `auditd`.
1. **Install:** `sudo apt install auditd -y`
2. **Apply Rules:**
   ```bash
   sudo cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/
   sudo auditctl -R /etc/audit/rules.d/honeypot-audit.rules
   ```

### Windows Setup (Sysmon)
Enhanced process auditing on Windows is achieved via Sysmon.
1. Download [Sysmon](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon).
2. Install with the provided config: `sysmon.exe -i wazuh/agent-config/honeypot-sysmon.xml`

### Configuring File Integrity Monitoring (FIM)
The most critical step is telling the Wazuh Agent which directories to monitor. This must be added to the `<syscheck>` section of the agent's `ossec.conf` file.

#### Option A: Automated Configuration (Recommended)
Use the CLI to generate the exact configuration block based on your deployment manifest:
```bash
honeypot-deployer wazuh-config --manifest ./path/to/manifest.json --os linux
```

#### Option B: Manual Configuration
You can use the template at `wazuh/agent-config/ossec-honeypot-fim.conf` as a starting point. Ensure you replace `/home/USER` with the actual username.

---

## Honeypot Artifact Generation

Once the environment is prepared, you must generate the honeyfiles using the CLI.

```bash
# 1. Install the tool
pip install .

# 2. Generate artifacts
# This creates the randomized keys and files that attackers will find.
honeypot-deployer generate --output ./my-artifacts

# 3. View the generated manifest
# This file tracks all your honeypots and should be kept secure.
honeypot-deployer show --manifest ./my-artifacts/manifest.json
```

---

## Browser Extension Path Mappings

The honeypot targets the following extension IDs:
- **MetaMask:** `nkbihfbeogaeaoehlefnkodbefgpgknn`
- **Phantom:** `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- **Coinbase Wallet:** `hnfanknocfeofbddgcijnmhnfnkdnaad`

### Default Paths by Browser/OS

| Browser | OS | Path |
|---|---|---|
| **Chrome** | Linux | `~/.config/google-chrome/Default/Local Extension Settings/` |
| **Chrome** | Windows | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\` |
| **Brave** | Linux | `~/.config/BraveSoftware/Brave-Browser/Default/Local Extension Settings/` |
| **Edge** | Windows | `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Local Extension Settings\` |
| **Firefox** | Linux | `~/.mozilla/firefox/*.default-release/storage/default/` |

---

## Containerized Deployment (Docker)

To run the Wazuh Agent in a container while maintaining high-fidelity monitoring:
```bash
docker run -d \
  --name wazuh-agent-honeypot \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -e WAZUH_MANAGER='your.manager.ip' \
  -v /home:/home:ro \
  wazuh/wazuh-agent:latest
```
*Note: `--cap-add=AUDIT_CONTROL` and `--pid=host` are required for `auditd` monitoring within the container.*
