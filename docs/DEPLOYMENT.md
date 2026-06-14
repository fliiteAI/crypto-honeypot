# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system.

## System Requirements

### Hardware Recommendations
For SMB environments, we recommend deploying the Wazuh Manager on a dedicated appliance:
- **Recommended:** Raspberry Pi 4 (8GB) or Raspberry Pi 5.
- **Storage:** High-endurance microSD card (minimum 32GB) or, preferably, a USB 3.0 SSD for improved performance and reliability.

### Supported Operating Systems
- **Linux:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
- **Windows:** Windows 10/11, Windows Server 2016+.
- **macOS:** Monterey (12.x) and newer (Artifact generation and basic FIM supported).

### Network Requirements
Ensure the following ports are open on the Wazuh Manager:
- **1514 (TCP/UDP):** Agent event communication.
- **1515 (TCP):** Agent enrollment.

---

## Wazuh Manager Configuration

The Wazuh Manager must be configured with custom decoders and rules to process honeypot events.

### 1. Manual Configuration
Copy the provided configuration files to the manager:

```bash
# Copy Decoders
sudo cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/

# Copy Rules
sudo cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/

# Copy Active Response script (Optional)
sudo cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
sudo chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
sudo chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh

# Restart Manager
sudo systemctl restart wazuh-manager
```

---

## Wazuh Agent Configuration

### Automated Configuration (Recommended)
Use the `honeypot-deployer` CLI to generate a tailored Wazuh configuration based on your deployed artifacts:

```bash
honeypot-deployer wazuh-config \
  --manifest ./manifest.json \
  --os linux \
  --output ./wazuh-agent-config
```

### Linux Agent Setup
1. **Install Auditd:** Required for high-fidelity `whodata` monitoring.
   ```bash
   sudo apt install auditd -y  # Ubuntu/Debian
   sudo yum install auditd -y  # RHEL/CentOS
   ```
2. **Apply Audit Rules:**
   ```bash
   sudo cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/
   sudo auditctl -R /etc/audit/rules.d/honeypot-audit.rules
   ```
3. **Configure FIM:** Add the generated configuration to `/var/ossec/etc/ossec.conf`.

### Windows Agent Setup
1. **Install Sysmon:** Recommended for process-level visibility.
2. **Configure FIM:** Add the honeypot paths to `C:\Program Files (x86)\ossec-agent\ossec.conf`.

---

## Browser Extension Decoys

The honeypot targets the following browser extensions across multiple browsers:

| Extension | ID |
|-----------|----|
| MetaMask | `nkbihfbeogaeaoehlefnkodbefgpgknn` |
| Phantom | `bfnaelmomeimhlpmgjnjophhpkkoljpa` |
| TronLink | `ibnejdfjmmkpcnlpebklmnkoeoihofec` |
| Coinbase Wallet | `hnfanknocfeofbddgcijnmhnfnkdnaad` |
| Binance Wallet | `cadiboklkpojfamcoggejbbdjcoiljjk` |

### Path Mappings
Decoys are placed in the following standard locations:

- **Chrome (Linux):** `~/.config/google-chrome/Default/Local Extension Settings/`
- **Chrome (Windows):** `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\`
- **Edge (Windows):** `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Local Extension Settings\`
- **Brave (Linux):** `~/.config/BraveSoftware/Brave-Browser/Default/Local Extension Settings/`
- **Firefox (Linux):** `~/.mozilla/firefox/*.default*/storage/default/` (using `moz-extension+++` naming)

---

## Containerized Deployment (Docker)

To run a Wazuh Agent in a container while monitoring honeypot artifacts:

```bash
docker run -d \
  --name wazuh-agent \
  -e WAZUH_MANAGER="192.168.1.100" \
  -e NODE_NAME="honeypot-node-01" \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -v /path/to/honeypot/artifacts:/mnt/honeypot:ro \
  wazuh/wazuh-agent:latest
```

**Note:** `--cap-add=AUDIT_CONTROL` and `--pid=host` are required for the agent to interact with the host's `auditd` for `whodata` FIM.
