# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system.

## System Requirements

### Infrastructure Recommendations
- **Wazuh Manager:** version 4.x+.
- **Hardware:** For SMB environments, a **Raspberry Pi 4 (8GB) or 5** is highly recommended.
- **Storage:** Use a high-endurance microSD card or, preferably, a **USB 3.0 SSD** for improved database performance.

### OS Requirements
#### Linux
- **Python:** 3.10+
- **Auditd:** Essential for "whodata" FIM support and user attribution.
- **Distributions:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.

#### Windows
- **Operating System:** Windows 10/11 or Windows Server 2016+.
- **Sysmon:** Highly recommended for process-level visibility and DNS query logging.

---

## Browser Extension Path Mappings

The honeypot targets the local storage directories of popular browser wallet extensions.

### Chrome / Chromium / Brave / Edge (Chromium-based)
Paths follow the pattern: `[User Data Path]\[Profile]\Local Extension Settings\[Extension ID]`

| Browser | OS | Path Template |
|---------|----|---------------|
| **Chrome** | Linux | `~/.config/google-chrome/Default/Local Extension Settings/` |
| **Chrome** | Windows | `%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings\` |
| **Brave** | Linux | `~/.config/BraveSoftware/Brave-Browser/Default/Local Extension Settings/` |
| **Brave** | Windows | `%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data\Default\Local Extension Settings\` |
| **Edge** | Windows | `%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Local Extension Settings\` |

### Firefox
Firefox uses IndexedDB for extension storage.
- **Linux:** `~/.mozilla/firefox/*.default*/storage/default/moz-extension+++[UUID]^userContextId=[ID]`
- **Windows:** `%APPDATA%\Mozilla\Firefox\Profiles\*.default*\storage\default\moz-extension+++[UUID]^userContextId=[ID]`

### Extension IDs to Monitor
- **MetaMask:** `nkbihfbeogaeaoehlefnkodbefgpgknn`
- **Phantom:** `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- **TronLink:** `ibnejdfjmmkpcnlpebklmnkoeoihofec`
- **Coinbase Wallet:** `hnfanknocfeofbddgcijnmhnfnkdnaad`
- **Binance Wallet:** `cadiboklkpojfamcoggejbbdjcoiljjk`

---

## Containerized Deployment

To deploy the Wazuh agent and honeypots within a Docker container while maintaining high-fidelity monitoring:

1. **Auditd Support:** The container must have access to the host's audit logs or be able to run `auditd`.
2. **Docker Run Configuration:**
```bash
docker run -d \
  --name wazuh-agent \
  --cap-add=AUDIT_CONTROL \
  --pid=host \
  -e WAZUH_MANAGER="YOUR_MANAGER_IP" \
  -e NODE_NAME="Honeypot-Container" \
  wazuh/wazuh-agent:latest
```
*Note: `--cap-add=AUDIT_CONTROL` and `--pid=host` are required for the agent to monitor host-level process events via whodata.*

---

## Deployment Steps

1. **Install Wazuh Manager:** Configure with the custom rules and decoders provided in the `wazuh/` directory.
2. **Generate Artifacts:** Use `honeypot-deployer generate --output ./artifacts`.
3. **Deploy Artifacts:** Copy the generated files to the target paths on monitored endpoints.
4. **Configure Agents:** Use `honeypot-deployer wazuh-config` to generate the FIM configuration and add it to `ossec.conf`.
5. **Verify:** Perform a health check and trigger a test access to verify alerting.
