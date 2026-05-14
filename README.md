# Crypto Wallet Honeypot Deployer

A defensive crypto wallet honeypot system for detecting attackers targeting cryptocurrency assets. Designed for SMB environments running [Wazuh SIEM](https://wazuh.com/) on Raspberry Pi.

## Overview

This tool generates realistic-looking (but non-funded) cryptocurrency wallet artifacts and deploys them across monitored endpoints. When an attacker—whether an infostealer, malware, or a manual intruder—accesses these honeypot files, Wazuh detects the activity and fires high-fidelity alerts with zero false positives.

For a deep dive into how the system works and how it maps to attacker techniques, see the [Architecture Overview](docs/ARCHITECTURE.md).

### Detection Layers

| Layer | Mechanism | What It Detects |
|-------|-----------|-----------------|
| **Layer 1** | Wazuh FIM (File Integrity Monitoring) | Any read/modify/delete of honeypot wallet files |
| **Layer 2** | Linux auditd / Windows Sysmon | Process-level access to wallet paths, filesystem enumeration |
| **Layer 3** | Network correlation | Exfiltration attempts (curl, scp, paste sites) after wallet access |
| **Layer 4** | On-Chain Monitoring | Attacker importing stolen keys and using them on-chain |

### Supported Chains

- **Bitcoin (BTC)** `wallet.dat` (Berkeley DB format)
- **Ethereum (ETH/EVM)** Keystore files (UTC/JSON), `.env` private keys
- **Solana (SOL)** `id.json` CLI keypair files
- **XRP (Ripple)** Wallet export JSON
- **Cardano (ADA)** `.skey` signing key (TextEnvelope format)
- **Canary Seed Phrases** BIP-39 mnemonics in various file formats
- **Browser Extensions** MetaMask, Phantom, Exodus, Electrum decoy data

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
```

### 2. View Manifest

```bash
honeypot-deployer show --manifest ./honeypot-artifacts/manifest.json
```

### 3. Setup On-Chain Monitoring

Export the addresses and add them to your preferred block explorer watchlists. See the [On-Chain Monitoring Guide](docs/ON_CHAIN_MONITORING.md) for details.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./chain-monitor-addresses.json
```

### 4. Deploy Wazuh Rules

Follow the [Deployment Guide](docs/DEPLOYMENT.md) to configure your Wazuh Manager and Agents.

```bash
# Example: Generate Wazuh Agent FIM configuration
honeypot-deployer wazuh-config \
  --manifest ./honeypot-artifacts/manifest.json \
  --os linux \
  --output ./wazuh-agent-config
```

### 5. Health Check

```bash
honeypot-deployer health-check --manifest ./honeypot-artifacts/manifest.json
```

## Documentation

-   [Architecture Overview](docs/ARCHITECTURE.md)
-   [Deployment Guide](docs/DEPLOYMENT.md)
-   [On-Chain Monitoring Guide](docs/ON_CHAIN_MONITORING.md)

## Security Notes

- Generated honeypot keys are **non-funded** by default. Never deposit real funds.
- The manifest is AES-encrypted at rest by default.
- All detection relies on the principle that **legitimate users never access honeypot files**.

## License

MIT
