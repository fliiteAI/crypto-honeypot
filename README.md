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

For a detailed look at the system design, see the [Architecture Overview](docs/ARCHITECTURE.md).

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

On each monitored endpoint, add the FIM configuration to the agent's `ossec.conf`. For detailed OS-specific setup, see the [Deployment Guide](docs/DEPLOYMENT.md).

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
├── docs/                        # Project documentation
│   ├── ARCHITECTURE.md          # Detection layers and MITRE mapping
│   ├── DEPLOYMENT.md            # Hardware & OS requirements, setup guide
│   └── ON_CHAIN_MONITORING.md   # Tracking stolen keys on-chain
├── src/honeypot_deployer/       # Python CLI application
│   ├── cli.py                   # Click CLI entry point
│   ├── manifest.py              # Encrypted manifest management
│   └── generators/              # Chain-specific key & artifact generators
├── wazuh/                       # Wazuh SIEM configuration
│   ├── decoders/                # Custom log decoders
│   ├── rules/                   # Custom alert rules
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

For more information on on-chain tracking, see the [On-Chain Monitoring Guide](docs/ON_CHAIN_MONITORING.md).

## MITRE ATT&CK Coverage

See [Architecture Overview](docs/ARCHITECTURE.md) for full mapping.

## Security Notes

- Generated honeypot keys are **non-funded** by default. Never deposit real funds.
- The manifest can be AES-encrypted at rest with a user-provided password.
- Private keys exist only in the manifest and the deployed artifacts.

## Requirements

- **Python:** 3.10+
- **Wazuh:** 4.x (Manager + Agent)
- **Linux:** `auditd` (required for high-fidelity `whodata` FIM)
- **Windows:** Sysmon (recommended for process-level visibility)
- **Hardware:** Raspberry Pi 4/5 (recommended for Wazuh Manager)

## License

MIT
