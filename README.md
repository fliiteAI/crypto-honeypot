# Crypto Wallet Honeypot for Wazuh SIEM

This project provides a simple yet effective crypto wallet honeypot designed to integrate with a Wazuh SIEM. It is tailored for the SMB marketplace, providing high-value security alerts with minimal overhead.

## Overview

The honeypot creates dummy cryptocurrency wallet files and browser extension data in standard locations that attackers often scan for during post-exploitation or when using automated "info-stealer" malware. Any interaction (access, modification, or deletion) with these files triggers a high-severity alert in the Wazuh SIEM.

### Monitored Wallets & Extensions
- **Core Wallets:** Bitcoin Core, Ethereum (Geth), Electrum, Exodus, Solana CLI.
- **Browser Extensions:** MetaMask, Phantom, TronLink, Coinbase Wallet, Binance Wallet.
- **Browsers Supported:** Chrome, Brave, Firefox (Linux/Windows), and Edge (Windows).

### Monitored Paths (Linux)
- Bitcoin: `~/.bitcoin/wallet.dat`
- Ethereum: `~/.ethereum/keystore/UTC--...`
- Solana: `~/.config/solana/id.json`
- Electrum: `~/.electrum/wallets/default_wallet`
- Exodus: `~/.config/Exodus/exodus.wallet/seed.secur`
- Extensions: `~/.config/[browser]/Default/Local Extension Settings/[extension_id]`
- Firefox Extensions: `~/.mozilla/firefox/*.default*/storage/default/moz-extension+++*`

### Monitored Paths (Windows)
- Bitcoin: `%APPDATA%\Bitcoin\wallet.dat`
- Ethereum: `%APPDATA%\Ethereum\keystore\UTC--...`
- Electrum: `%APPDATA%\Electrum\wallets\default_wallet`
- Exodus: `%APPDATA%\Exodus\exodus.wallet\seed.secur`
- Extensions: `%LOCALAPPDATA%\[browser]\User Data\Default\Local Extension Settings\[extension_id]`
- Firefox Extensions: `%APPDATA%\Mozilla\Firefox\Profiles\*.default*\storage\default\moz-extension+++*`

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

#### Enable Who-Data (Linux)
Ensure `auditd` is installed for user attribution in alerts:
```bash
sudo apt update && sudo apt install auditd -y
```

#### Detect Read-Access (Linux - Optional but Recommended)
To detect simple file reading (e.g., `cat` or `grep`) on Linux, you must add Auditd rules. Append the following to your `/etc/audit/rules.d/audit.rules` (or use `auditctl`):

```text
-w /root/.bitcoin/wallet.dat -p r -k crypto_honeypot
-w /home/ -p r -k crypto_honeypot
```
*(Adjust paths to be more specific as needed)*

Then, configure the Wazuh agent to read the audit log in `ossec.conf`:
```xml
<localfile>
  <log_format>audit</log_format>
  <location>/var/log/audit/audit.log</location>
</localfile>
```

#### Apply FIM Configuration
Add the configuration found in `wazuh/agent_config.xml` to the `<syscheck>` section of the agent's `ossec.conf`.

### 3. Configure Wazuh Manager Rules

Add the custom rules found in `wazuh/manager_rules.xml` to the Wazuh Manager's `local_rules.xml`.

Restart the Wazuh manager to apply the rules:
```bash
systemctl restart wazuh-manager
```

### 4. Enable Automated Remediation (Optional)

To automatically disable user accounts that interact with the honeypot, add the configuration found in `wazuh/active_response.xml` to your Wazuh Manager's `ossec.conf`.

This configuration will trigger the `disable-account` script for 30 minutes whenever a rule in the `crypto_honeypot` group is fired.

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

You should see an alert in your Wazuh dashboard with **Level 12** and a description matching the modified wallet. If Auditd rules are configured, simple read operations will also trigger alerts.

## SIEM Integration

The alerts are tagged with `crypto_honeypot` and mapped to MITRE ATT&CK technique `T1552.004` (Unsecured Credentials: Private Keys), ensuring high-fidelity detection for your SOC.
