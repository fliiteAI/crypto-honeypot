# Deployment Guide: Crypto Wallet Honeypot

Detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system.

## 1. System Requirements

### Hardware Recommendations (Wazuh Manager)
For SMB environments, the Wazuh Manager can be hosted on dedicated hardware to ensure performance:
- **Recommended:** Raspberry Pi 4 (8GB) or Raspberry Pi 5.
- **Storage:** High-endurance microSD card or, preferably, a USB 3.0 SSD.
- **Network:** Wired Ethernet connection.

### Supported Operating Systems (Agents)
The honeypot artifacts and monitoring scripts are tested on:
- **Linux:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
- **Windows:** Windows 10, 11, and Windows Server 2016+.

---

## 2. OS-Specific Requirements

### Linux Setup
- **Python:** 3.10 or higher.
- **Auditd:** Required for `whodata` FIM support.
  ```bash
  sudo apt update && sudo apt install auditd -y
  ```
- **Capabilities:** If running the Wazuh agent in a **Docker container**, you must provide the following flags to allow `auditd` monitoring:
  ```bash
  docker run -d --name wazuh-agent \
    --cap-add=AUDIT_CONTROL \
    --pid=host \
    -e WAZUH_MANAGER="192.168.1.100" \
    wazuh/wazuh-agent:latest
  ```

### Windows Setup
- **Permissions:** Administrator privileges are required to deploy artifacts to `%APPDATA%` and modify Wazuh config.
- **Sysmon:** Highly recommended for Layer 2 visibility. Install with a configuration that monitors for file access to the honeypot paths.

---

## 3. Browser Extension Path Mappings

The honeypot mimics popular browser extensions. For the best results, ensure artifacts are placed in the correct directories for the browsers used in your environment.

| Browser | OS | Base Path |
|---------|----|-----------|
| **Chrome** | Linux | `~/.config/google-chrome/Default/Local Extension Settings/` |
| **Chrome** | Windows | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\` |
| **Edge** | Windows | `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Local Extension Settings\` |
| **Brave** | Linux | `~/.config/BraveSoftware/Brave-Browser/Default/Local Extension Settings/` |
| **Firefox** | Linux | `~/.mozilla/firefox/*.default-release/storage/default/` |

**Note for Firefox:** Firefox uses a different storage mechanism. The honeypot generator creates folders with the `moz-extension+++` prefix to match Firefox's internal naming convention.

---

## 4. Wazuh Manager Configuration

The Wazuh Manager must be configured with custom decoders and rules to recognize honeypot events.

1. **Install Decoders:**
   ```bash
   cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/
   ```

2. **Install Rules:**
   ```bash
   cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/
   ```

3. **Restart Manager:**
   ```bash
   systemctl restart wazuh-manager
   ```

---

## 5. Wazuh Agent Configuration

### Automated Configuration (Recommended)
The CLI can generate a tailored FIM configuration based on the artifacts you've actually generated:
```bash
honeypot-deployer wazuh-config --manifest ./my-artifacts/manifest.json --os linux --output ./wazuh-config
```
Copy the contents of the generated `honeypot-fim.conf` into the `<syscheck>` section of your agent's `ossec.conf`.

### Manual Configuration
Templates are provided in the `wazuh/agent-config/` directory:
1. `ossec-honeypot-fim.conf`: FIM monitoring blocks.
2. `honeypot-audit.rules`: Linux `auditd` rules.
3. `honeypot-sysmon.xml`: Windows Sysmon event filtering.

---

## 6. Deployment Verification

After deployment, always verify that the system is active:

1. **Health Check:**
   ```bash
   honeypot-deployer health-check --manifest ./manifest.json
   ```
2. **Connectivity:** Ensure the agent is connected to the manager (Port 1514 TCP/UDP and 1515 TCP must be open).
3. **Simulation:** Perform a "read" on a honeyfile (e.g., `cat ~/.bitcoin/wallet.dat`) and verify that a Level 12 alert appears in the Wazuh dashboard within seconds.
