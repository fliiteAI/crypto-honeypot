# Crypto Wallet Honeypot Deployer

A defensive crypto wallet honeypot system for detecting attackers targeting cryptocurrency assets. Designed for SMB environments running [Wazuh SIEM](https://wazuh.com/) on Raspberry Pi.

## Overview

This tool generates realistic-looking (but non-funded) cryptocurrency wallet artifacts and deploys them across monitored endpoints. When an attacker whether an infostealer, malware or a manual intruder, accesses these honeypot files, Wazuh detects the activity and fires high-fidelity alerts with zero false positives.

### Detection Layers

The system employs a 4-layer detection strategy to provide defense-in-depth and high-fidelity alerts. For a detailed breakdown of the detection mechanisms and MITRE ATT&CK mapping, see the [Architecture Overview](docs/ARCHITECTURE.md).

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
├── docs/                        # Detailed documentation
│   ├── ARCHITECTURE.md          # 4-layer detection strategy & MITRE mapping
│   ├── DEPLOYMENT.md            # Installation & setup guide
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

## Security Notes

- Generated honeypot keys are **non-funded** by default. Never deposit real funds.
- The manifest can be AES-encrypted at rest with a user-provided password.
- Private keys exist only in the manifest and the deployed artifacts -- they are never transmitted.
- All detection relies on the principle that **legitimate users never access honeypot files**.

## Documentation

Detailed documentation is available in the `docs/` directory:

- **[Deployment Guide](docs/DEPLOYMENT.md):** Installation, hardware recommendations, and Wazuh configuration.
- **[Architecture Overview](docs/ARCHITECTURE.md):** Detailed breakdown of detection layers and MITRE ATT&CK mapping.
- **[On-Chain Monitoring](docs/ON_CHAIN_MONITORING.md):** How to track stolen honeypot keys on various blockchains.

## Requirements

- **Python:** 3.10+
- **Wazuh:** 4.x (Manager + Agent)
- **Linux:** `auditd` (required for high-fidelity `whodata` FIM)
- **Windows:** Sysmon (recommended for process-level visibility)
- **Hardware:** Raspberry Pi 4/5 (recommended for Wazuh Manager in SMB environments)

## License

MIT
