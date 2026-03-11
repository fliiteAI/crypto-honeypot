# Crypto Wallet Honeypot for Wazuh SIEM

This project provides a simple yet effective crypto wallet honeypot designed to integrate with a Wazuh SIEM. It is tailored for the SMB marketplace, providing high-value security alerts with minimal overhead.

## Overview

The honeypot creates dummy cryptocurrency wallet files in standard locations that attackers often scan for during post-exploitation or when using automated "info-stealer" malware. Any access, modification, or deletion of these files triggers a high-severity alert in the Wazuh SIEM.

### Monitored Paths
- Bitcoin: `~/.bitcoin/wallet.dat`
- Ethereum: `~/.ethereum/keystore/UTC--...`
- Solana: `~/.config/solana/id.json`
- Electrum: `~/.electrum/wallets/default_wallet`

## Deployment Instructions

### 1. Deploy Honeyfiles on Endpoints

Run the provided `deploy.sh` script on the Linux endpoints you wish to monitor. This script creates the necessary directory structures and dummy wallet files with appropriate restricted permissions.

```bash
chmod +x deploy.sh
./deploy.sh
```

### 2. Configure Wazuh Agent

**Prerequisite:** Ensure `auditd` is installed on the Linux endpoint for `whodata` support:
```bash
sudo apt update && sudo apt install auditd -y
```

Add the following configuration to the `ossec.conf` file on the monitored agent (usually located at `/var/ossec/etc/ossec.conf`). You can find a snippet in `wazuh/agent_config.xml`.

```xml
<syscheck>
  <directories realtime="yes" whodata="yes" check_all="yes" report_changes="yes">/root/.bitcoin</directories>
  <directories realtime="yes" whodata="yes" check_all="yes" report_changes="yes">/root/.ethereum/keystore</directories>
  <directories realtime="yes" whodata="yes" check_all="yes" report_changes="yes">/root/.config/solana</directories>
  <directories realtime="yes" whodata="yes" check_all="yes" report_changes="yes">/root/.electrum/wallets</directories>
</syscheck>
```
*Note: If you deployed the honeyfiles to a user's home directory instead of root, adjust the paths accordingly.*

Restart the Wazuh agent to apply changes:
```bash
systemctl restart wazuh-agent
```

### 3. Configure Wazuh Manager Rules

Add the custom rules to the Wazuh Manager's `local_rules.xml` (usually located at `/var/ossec/etc/rules/local_rules.xml`). You can find these in `wazuh/manager_rules.xml`.

These rules detect events from the default FIM rules (550, 553, 554) and elevate the alert level for the specific honeypot paths.

Restart the Wazuh manager to apply the rules:
```bash
systemctl restart wazuh-manager
```

## Testing the Honeypot

To test the integration, attempt to modify or delete one of the honeyfiles:

```bash
echo "tamper" >> ~/.bitcoin/wallet.dat
```
Or:
```bash
rm ~/.bitcoin/wallet.dat
```

You should see an alert in your Wazuh dashboard with Level 12 and the description: `Crypto Honeypot: Access or modification detected in Bitcoin wallet.dat`.

*Note: While `whodata="yes"` is enabled, standard FIM rules (550, 553, 554) trigger on file integrity changes (modification, creation, deletion), not simple read access (`cat`). To detect read access, additional Auditd rules must be configured.*

## SIEM Integration

The alerts are tagged with `crypto_honeypot` and mapped to MITRE ATT&CK technique `T1552.004` (Unsecured Credentials: Private Keys), making it easy to filter and report on these high-fidelity events in your SOC.
