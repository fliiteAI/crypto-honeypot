# Deployment Guide: Crypto Wallet Honeypot

This document provides detailed requirements and step-by-step instructions for deploying the Crypto Wallet Honeypot system.

## System Requirements

### Hardware Recommendations
For SMB environments, we recommend running the Wazuh Manager on:
- **Raspberry Pi 4 (8GB)** or **Raspberry Pi 5**.
- **Storage:** High-endurance microSD card or, preferably, a **USB 3.0 SSD** for improved reliability and performance.

### OS Support
- **Linux:** Ubuntu 20.04+, Debian 11+, RHEL/AlmaLinux 8+.
- **Windows:** Windows 10/11 or Windows Server 2016+.

### Software Dependencies
- **Python:** 3.10+ (required for the `honeypot-deployer` CLI).
- **Wazuh:** 4.x (Manager and Agent).
- **Auditd (Linux):** Required for high-fidelity `whodata` FIM.
- **Sysmon (Windows):** Recommended for enhanced process visibility.

---

## Wazuh Manager Configuration

### 1. Connectivity
Ensure the following ports are open on the Wazuh Manager:
- **1514 (TCP/UDP):** Agent event communication.
- **1515 (TCP):** Agent enrollment.

### 2. Custom Decoders and Rules
Copy the configuration files from the `wazuh/` directory to your Wazuh Manager:
```bash
# Decoders
sudo cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/

# Rules
sudo cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/

# Active Response (Optional)
sudo cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
sudo chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
sudo chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
```

### 3. Restart Manager
```bash
sudo systemctl restart wazuh-manager
```

---

## Wazuh Agent Configuration

### Linux Setup
1. **Install Auditd:**
   ```bash
   sudo apt update && sudo apt install auditd -y
   ```
2. **Configure FIM:** Use `honeypot-deployer wazuh-config` to generate the snippet for your `ossec.conf`.
3. **Install Audit Rules:**
   ```bash
   sudo cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
   sudo auditctl -R /etc/audit/rules.d/honeypot.rules
   ```

### Windows Setup
1. **Install Sysmon:** Use the configuration provided in `wazuh/agent-config/honeypot-sysmon.xml`.
2. **Configure FIM:** Add generated paths to `C:\Program Files (x86)\ossec-agent\ossec.conf`.

### Containerized Deployment (Docker)
When running a Wazuh Agent in a container:
- Pass the `NODE_NAME` environment variable to identify the agent.
- Mount necessary volumes for artifact storage.
- **Critical:** For `whodata` monitoring (via `auditd`) to work, the container must run with:
  ```bash
  docker run --cap-add=AUDIT_CONTROL --pid=host ...
  ```

---

## Wallet and Extension Path Mappings

The honeypot deploys artifacts to standard locations where infostealers expect to find them.

### Standard Wallet Paths
| Chain | Linux Path | Windows Path |
|-------|------------|--------------|
| Bitcoin | `~/.bitcoin/wallet.dat` | `%APPDATA%\Bitcoin\wallet.dat` |
| Ethereum | `~/.ethereum/keystore/` | `%APPDATA%\Ethereum\keystore\` |
| Solana | `~/.config/solana/id.json` | `%USERPROFILE%\.config\solana\id.json` |
| Electrum | `~/.electrum/wallets/` | `%APPDATA%\Electrum\wallets\` |
| Exodus | `~/.config/Exodus/` | `%APPDATA%\Exodus\exodus.wallet\` |

### Browser Extension Decoys
Decoys are placed in the profile storage of Chrome, Edge, Brave, and Firefox.

**Common Extension IDs Monitored:**
- **MetaMask:** `nkbihfbeogaeaoehlefnkodbefgpgknn`
- **Phantom:** `bfnaelmomeimhlpmgjnjophhpkkoljpa`
- **TronLink:** `ibnejdfjmmkpcnlpebklmnkoeoihofec`
- **Coinbase Wallet:** `hnfanknocfeofbddgcijnmhnfnkdnaad`
- **Binance Wallet:** `cadiboklkpojfamcoggejbbdjcoiljjk`

---

## Artifact Generation

Use the `honeypot-deployer` CLI to generate randomized artifacts:
```bash
honeypot-deployer generate --output ./artifacts
```
**Security Note:** Always keep the `manifest.json` secure. Use the `--encrypt-manifest` flag (on by default) to protect it with a password.
