# Crypto Wallet Honeypot Deployer

A defensive crypto wallet honeypot system for detecting attackers targeting cryptocurrency assets. Designed for SMB environments running [Wazuh SIEM](https://wazuh.com/) on Raspberry Pi.

## Overview

This tool generates realistic-looking (but non-funded) cryptocurrency wallet artifacts and deploys them across monitored endpoints. When an attacker whether an infostealer, malware or a manual intruder, accesses these honeypot files, Wazuh detects the activity and fires high-fidelity alerts with zero false positives.

### Detection Layers

| Layer | Mechanism | What It Detects |
|-------|-----------|-----------------|
| **Layer 1** | Wazuh FIM (File Integrity Monitoring) | Any read/modify/delete of honeypot wallet files |
| **Layer 2** | Linux auditd / Windows Sysmon | Process-level access to wallet paths, filesystem enumeration |
| **Layer 3** | Network correlation | Exfiltration attempts (curl, scp, paste sites) after wallet access |
| **Layer 4** | On-chain monitoring | Attacker importing stolen keys and querying/using them on-chain |

### Supported Chains

- **Bitcoin (BTC)**  `wallet.dat` (Berkeley DB format)
- **Ethereum (ETH/EVM)**  Keystore files (UTC/JSON), `.env` private keys
- **Solana (SOL)**  `id.json` CLI keypair files
- **XRP (Ripple)**  Wallet export JSON
- **Cardano (ADA)**  `.skey` signing key (TextEnvelope format)
- **Canary Seed Phrases**  BIP-39 mnemonics in various file formats
- **Browser Extensions**  MetaMask, Phantom, Exodus, Electrum decoy data

## Installation

```bash
pip install -e .
```

For development:

```bash
pip install -e ".[dev]"
```

## Quick Start

### 1. Generate Honeypot Artifacts

```bash
# Generate artifacts for all supported chains
honeypot-deployer generate --output ./honeypot-artifacts

# Generate for specific chains only
honeypot-deployer generate --chains btc,eth,sol --output ./honeypot-artifacts

# Generate without seed phrases or browser decoys
honeypot-deployer generate --no-seed --no-browser --output ./honeypot-artifacts

# Generate with unencrypted manifest (not recommended for production)
honeypot-deployer generate --no-encrypt-manifest --output ./honeypot-artifacts
```

### 2. View Manifest

```bash
honeypot-deployer show --manifest ./honeypot-artifacts/manifest.json
```

### 3. Export Addresses for Chain Monitor

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./chain-monitor-addresses.json
```

### 4. Generate Wazuh Agent Config

```bash
honeypot-deployer wazuh-config \
  --manifest ./honeypot-artifacts/manifest.json \
  --os linux \
  --output ./wazuh-agent-config
```

### 5. Deploy Wazuh Rules

Copy the Wazuh configuration files to your Wazuh Manager:

```bash
# Custom decoders
cp wazuh/decoders/honeypot_decoder.xml /var/ossec/etc/decoders/

# Custom rules
cp wazuh/rules/honeypot_rules.xml /var/ossec/etc/rules/

# Active response script
cp wazuh/active-response/honeypot-forensic-snapshot.sh /var/ossec/active-response/bin/
chmod 750 /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh
chown root:wazuh /var/ossec/active-response/bin/honeypot-forensic-snapshot.sh

# Restart Wazuh Manager
systemctl restart wazuh-manager
```

### 6. Configure Wazuh Agents

On each monitored endpoint, add the FIM configuration to the agent's `ossec.conf`:

```bash
# Linux
# Add contents of wazuh/agent-config/ossec-honeypot-fim.conf to /var/ossec/etc/ossec.conf

# Install audit rules
cp wazuh/agent-config/honeypot-audit.rules /etc/audit/rules.d/honeypot.rules
auditctl -R /etc/audit/rules.d/honeypot.rules
```

### 7. Health Check

```bash
honeypot-deployer health-check --manifest ./honeypot-artifacts/manifest.json
```

## Project Structure

```
crypto-wallet-honeypot/
├── src/honeypot_deployer/       # Python CLI application
│   ├── cli.py                   # Click CLI entry point
│   ├── manifest.py              # Encrypted manifest management
│   └── generators/              # Chain-specific key & artifact generators
│       ├── btc.py               # Bitcoin wallet.dat
│       ├── eth.py               # Ethereum keystore + .env
│       ├── sol.py               # Solana id.json
│       ├── xrp.py               # XRP wallet export
│       ├── ada.py               # Cardano .skey
│       ├── seed.py              # BIP-39 canary seed phrases
│       └── browser.py           # Browser extension decoys
├── wazuh/                       # Wazuh SIEM configuration
│   ├── decoders/                # Custom log decoders
│   ├── rules/                   # Custom alert rules (15+ rules, 4 detection layers)
│   ├── agent-config/            # Agent FIM, audit, and Sysmon templates
│   └── active-response/         # Forensic snapshot script
├── pyproject.toml               # Python project configuration
└── README.md
```

## Wazuh Alert Rules

| Rule ID | Level | Description |
|---------|-------|-------------|
| 100501 | 12 | Wallet file accessed |
| 100502 | 14 | Wallet file modified |
| 100503 | 14 | Wallet file deleted |
| 100504 | 13 | Seed phrase file accessed |
| 100505 | 13 | Browser extension data accessed |
| 100510 | 10 | Audit rule triggered on honeypot path |
| 100511 | 14 | Rapid multi-file access (infostealer pattern) |
| 100520 | 14 | Network-capable process accessed honeypot |
| 100522 | 13 | Archive utility used after honeypot access |
| 100530 | 15 | On-chain activity on honeypot address |
| 100532 | 15 | Outbound transfer from honeypot address |
| 100540 | 15 | Correlated file + chain activity |

## MITRE ATT&CK Coverage

| Technique | Name | Detection Layer |
|-----------|------|-----------------|
| T1083 | File and Directory Discovery | Layer 1, 2 |
| T1005 | Data from Local System | Layer 1 |
| T1555 | Credentials from Password Stores | Layer 1 |
| T1555.003 | Credentials from Web Browsers | Layer 1 |
| T1560 | Archive Collected Data | Layer 2, 3 |
| T1041 | Exfiltration Over C2 Channel | Layer 3 |
| T1048 | Exfiltration Over Alternative Protocol | Layer 3 |
| T1657 | Financial Theft | Layer 4 |
| T1070 | Indicator Removal | Layer 1 |

## Security Notes

- Generated honeypot keys are **non-funded** by default. Never deposit real funds.
- The manifest can be AES-encrypted at rest with a user-provided password.
- Private keys exist only in the manifest and the deployed artifacts -- they are never transmitted.
- All detection relies on the principle that **legitimate users never access honeypot files**.

## Requirements

- Python 3.10+
- Wazuh 4.x (Manager + Agent)
- Linux `auditd` (for whodata FIM) or Windows Sysmon
- Raspberry Pi 4/5 (recommended for Wazuh Manager deployment)

## License

MIT
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
