# Crypto Wallet Honeypot Deployer

A defensive crypto wallet honeypot system for detecting attackers targeting cryptocurrency assets. Designed for SMB environments running [Wazuh SIEM](https://wazuh.com/) on Raspberry Pi.

## Overview

This tool generates realistic-looking (but non-funded) cryptocurrency wallet artifacts and deploys them across monitored endpoints. When an attacker accesses these honeypot files, Wazuh detects the activity and fires high-fidelity alerts with zero false positives.

### Documentation Links

- [**Architecture Overview**](docs/ARCHITECTURE.md): Learn about the 4-layer detection strategy and MITRE ATT&CK mapping.
- [**Deployment Guide**](docs/DEPLOYMENT.md): Detailed installation instructions, system requirements, and Wazuh configuration.
- [**On-Chain Monitoring**](docs/ON_CHAIN_MONITORING.md): Guide for setting up watchlists for honeypot addresses.

### Supported Chains

- **Bitcoin (BTC)**: `wallet.dat` (Berkeley DB format)
- **Ethereum (ETH/EVM)**: Keystore files (UTC/JSON), `.env` private keys
- **Solana (SOL)**: `id.json` CLI keypair files
- **XRP (Ripple)**: Wallet export JSON
- **Cardano (ADA)**: `.skey` signing key (TextEnvelope format)
- **Canary Seed Phrases**: BIP-39 mnemonics in various file formats
- **Browser Extensions**: MetaMask, Phantom, Exodus, Electrum decoy data

## Quick Start

### 1. Installation

```bash
pip install -e .
```

### 2. Generate Honeypot Artifacts

```bash
# Generate artifacts for all supported chains
honeypot-deployer generate --output ./honeypot-artifacts
```

### 3. Generate Wazuh Agent Config

```bash
honeypot-deployer wazuh-config \
  --manifest ./honeypot-artifacts/manifest.json \
  --os linux \
  --output ./wazuh-agent-config
```

### 4. Health Check

```bash
honeypot-deployer health-check --manifest ./honeypot-artifacts/manifest.json
```

## Project Structure

```
crypto-wallet-honeypot/
├── docs/                        # Detailed documentation
├── src/honeypot_deployer/       # Python CLI application
├── wazuh/                       # Wazuh SIEM configuration (decoders, rules, agents)
├── pyproject.toml               # Python project configuration
└── README.md
```

## Security Notes

- Generated honeypot keys are **non-funded** by default. Never deposit real funds.
- The manifest can be AES-encrypted at rest with a user-provided password.
- All detection relies on the principle that **legitimate users never access honeypot files**.

## License

MIT
