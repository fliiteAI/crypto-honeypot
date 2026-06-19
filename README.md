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

Detailed architectural information can be found in the [Architecture Overview](docs/ARCHITECTURE.md).

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

### 4. Health Check

```bash
honeypot-deployer health-check --manifest ./honeypot-artifacts/manifest.json
```

## Documentation

For comprehensive setup and configuration instructions, please refer to our documentation:

- [**Deployment Guide**](docs/DEPLOYMENT.md) - System requirements, Wazuh configuration, and OS-specific setup.
- [**Architecture Overview**](docs/ARCHITECTURE.md) - Understanding the 4-layer detection strategy and MITRE ATT&CK mapping.
- [**On-Chain Monitoring**](docs/ON_CHAIN_MONITORING.md) - Instructions for setting up block explorer watchlists for honeypot addresses.

## Project Structure

```
crypto-wallet-honeypot/
├── docs/                        # Project documentation
├── src/honeypot_deployer/       # Python CLI application
├── wazuh/                       # Wazuh SIEM configuration
├── pyproject.toml               # Python project configuration
└── README.md
```

## Security Notes

- Generated honeypot keys are **non-funded** by default. Never deposit real funds.
- The manifest can be AES-encrypted at rest with a user-provided password.
- All detection relies on the principle that **legitimate users never access honeypot files**.

## Requirements

- **Python:** 3.10+
- **Wazuh:** 4.x (Manager + Agent)
- **Linux:** `auditd` (required for high-fidelity `whodata` FIM)
- **Windows:** Sysmon (recommended)
- **Hardware:** Raspberry Pi 4/5 (recommended for Wazuh Manager)

## License

MIT
