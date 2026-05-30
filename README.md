# Crypto Wallet Honeypot Deployer

A defensive crypto wallet honeypot system for detecting attackers targeting cryptocurrency assets. Designed for SMB environments running [Wazuh SIEM](https://wazuh.com/) on Raspberry Pi.

## Overview

This tool generates realistic-looking (but non-funded) cryptocurrency wallet artifacts and deploys them across monitored endpoints. When an attacker accesses these honeypot files, Wazuh detects the activity and fires high-fidelity alerts with zero false positives.

For a detailed look at the system architecture and detection layers, see [Architecture Overview](docs/ARCHITECTURE.md).

### Detection Layers

| Layer | Mechanism | What It Detects |
|-------|-----------|-----------------|
| **Layer 1** | Wazuh FIM | Any read/modify/delete of honeypot wallet files |
| **Layer 2** | Linux auditd / Windows Sysmon | Process-level access and filesystem enumeration |
| **Layer 3** | Network correlation | Exfiltration attempts after wallet access |
| **Layer 4** | On-chain monitoring | Importing stolen keys and on-chain activity |

## Documentation Index

- [**Deployment Guide**](docs/DEPLOYMENT.md): System requirements, hardware recommendations, and step-by-step setup instructions.
- [**Architecture Overview**](docs/ARCHITECTURE.md): Multi-layered detection strategy and MITRE ATT&CK mapping.
- [**On-Chain Monitoring**](docs/ON_CHAIN_MONITORING.md): Setting up watchlists for honeypot addresses on block explorers.

## Supported Chains

- **Bitcoin (BTC)**: `wallet.dat` (Berkeley DB format)
- **Ethereum (ETH/EVM)**: Keystore files (UTC/JSON), `.env` private keys
- **Solana (SOL)**: `id.json` CLI keypair files
- **XRP (Ripple)**: Wallet export JSON
- **Cardano (ADA)**: `.skey` signing key (TextEnvelope format)
- **Canary Seed Phrases**: BIP-39 mnemonics in various file formats
- **Browser Extensions**: MetaMask, Phantom, Exodus, Electrum decoy data

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

# Generate with unencrypted manifest (not recommended for production)
honeypot-deployer generate --no-encrypt-manifest --output ./honeypot-artifacts
```

### 2. View Manifest

```bash
honeypot-deployer show --manifest ./honeypot-artifacts/manifest.json
```

### 3. Health Check

```bash
honeypot-deployer health-check --manifest ./honeypot-artifacts/manifest.json
```

## Wazuh Alert Rules

| Rule ID | Level | Description |
|---------|-------|-------------|
| 100501 | 12 | Wallet file accessed |
| 100502 | 14 | Wallet file modified |
| 100511 | 14 | Rapid multi-file access (infostealer pattern) |
| 100520 | 14 | Network-capable process accessed honeypot |
| 100530 | 15 | On-chain activity on honeypot address |

See [Architecture Overview](docs/ARCHITECTURE.md) for a full list of rules and MITRE mappings.

## Security Notes

- Generated honeypot keys are **non-funded**. Never deposit real funds.
- The manifest can be AES-encrypted at rest with a user-provided password.
- All detection relies on the principle that **legitimate users never access honeypot files**.

## License

MIT
