# Crypto Wallet Honeypot for Wazuh SIEM

This project provides a simple yet effective crypto wallet honeypot designed to integrate with a Wazuh SIEM. It is tailored for the SMB marketplace, providing high-value security alerts with minimal overhead.

## Overview

The honeypot creates dummy cryptocurrency wallet files and browser extension data in standard locations that attackers often scan for during post-exploitation or when using automated "info-stealer" malware. Any access, modification, or deletion of these files triggers a high-severity alert in the Wazuh SIEM.

### Monitored Wallets & Extensions
- **Core Wallets:** Bitcoin Core, Ethereum (Geth), Electrum, Exodus, Solana CLI.
- **Browser Extensions:** MetaMask, Phantom, TronLink, Coinbase Wallet, Binance Wallet.
- **Browsers Supported:** Chrome, Brave (Linux/Windows), and Edge (Windows).

### Monitored Paths (Linux)
- Bitcoin: `~/.bitcoin/wallet.dat`
- Ethereum: `~/.ethereum/keystore/UTC--...`
- Solana: `~/.config/solana/id.json`
- Electrum: `~/.electrum/wallets/default_wallet`
- Exodus: `~/.config/Exodus/exodus.wallet/seed.secur`
- Extensions: `~/.config/[browser]/Default/Local Extension Settings/[extension_id]`

### Monitored Paths (Windows)
- Bitcoin: `%APPDATA%\Bitcoin\wallet.dat`
- Ethereum: `%APPDATA%\Ethereum\keystore\UTC--...`
- Electrum: `%APPDATA%\Electrum\wallets\default_wallet`
- Exodus: `%APPDATA%\Exodus\exodus.wallet\seed.secur`
- Extensions: `%LOCALAPPDATA%\[browser]\User Data\Default\Local Extension Settings\[extension_id]`

## Deployment Instructions

### 1. Deploy Honeyfiles on Endpoints

#### Linux
Run the provided `deploy.sh` script on the Linux endpoints you wish to monitor.

```bash
chmod +x deploy.sh
./deploy.sh
```

#### Windows
Run the provided `deploy.ps1` PowerShell script on the Windows endpoints you wish to monitor.

```powershell
.\deploy.ps1
```

### 2. Configure Wazuh Agent

**Prerequisite (Linux):** Ensure `auditd` is installed on the Linux endpoint for `whodata` support:
```bash
sudo apt update && sudo apt install auditd -y
```

Add the configuration found in `wazuh/agent_config.xml` to the `ossec.conf` file on the monitored agent.

### 3. Configure Wazuh Manager Rules

Add the custom rules found in `wazuh/manager_rules.xml` to the Wazuh Manager's `local_rules.xml`.

Restart the Wazuh manager to apply the rules:
```bash
systemctl restart wazuh-manager
```

## Testing the Honeypot

To test the integration, attempt to modify or delete one of the honeyfiles:

### Linux
```bash
echo "tamper" >> ~/.bitcoin/wallet.dat
```

### Windows
```powershell
Add-Content -Path "$env:APPDATA\Bitcoin\wallet.dat" -Value "tamper"
```

You should see an alert in your Wazuh dashboard with Level 12 and a description matching the modified wallet.

*Note: While `whodata="yes"` is enabled on Linux, standard FIM rules (550, 553, 554) trigger on file integrity changes, not simple read access. For Windows, `whodata` can be enabled if the system supports it, but the provided config uses `realtime`.*

## SIEM Integration

The alerts are tagged with `crypto_honeypot` and mapped to MITRE ATT&CK technique `T1552.004` (Unsecured Credentials: Private Keys).
