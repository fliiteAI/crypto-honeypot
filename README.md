# Crypto Wallet Honeypot Deployer

A defensive crypto wallet honeypot system for detecting attackers targeting cryptocurrency assets. Designed for SMB environments running [Wazuh SIEM](https://wazuh.com/) on Raspberry Pi.

## Overview

This tool generates realistic-looking (but non-funded) cryptocurrency wallet artifacts and deploys them across monitored endpoints. When an attacker whether an infostealer, malware or a manual intruder, accesses these honeypot files, Wazuh detects the activity and fires high-fidelity alerts with zero false positives.

For a deep dive into how the system works and its detection strategy, see the [Architecture Overview](docs/ARCHITECTURE.md).

### Detection Layers

| Layer | Mechanism | What It Detects |
|-------|-----------|-----------------|
| **Layer 1** | Wazuh FIM (File Integrity Monitoring) | Any read/modify/delete of honeypot wallet files |
| **Layer 2** | Linux auditd / Windows Sysmon | Process-level access to wallet paths, filesystem enumeration |
| **Layer 3** | Network correlation | Exfiltration attempts (curl, scp, paste sites) after wallet access |
| **Layer 4** | [On-chain monitoring](docs/ON_CHAIN_MONITORING.md) | Attacker importing stolen keys and querying/using them on-chain |

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

Refer to the [Deployment Guide](docs/DEPLOYMENT.md) for detailed instructions on configuring the Wazuh Manager and Agents.

### 6. Health Check

```bash
honeypot-deployer health-check --manifest ./honeypot-artifacts/manifest.json
```

## Documentation

- [**Deployment Guide**](docs/DEPLOYMENT.md): Detailed installation and setup instructions, including OS-specific and container requirements.
- [**Architecture Overview**](docs/ARCHITECTURE.md): Technical details on detection layers and MITRE ATT&CK mapping.
- [**On-Chain Monitoring**](docs/ON_CHAIN_MONITORING.md): How to track honeypot addresses on block explorers.

## Requirements

- **Python:** 3.10+
- **Wazuh:** 4.x (Manager + Agent)
- **Linux:** `auditd` (required for high-fidelity `whodata` FIM)
- **Windows:** Sysmon (recommended for process-level visibility)
- **Hardware:** Raspberry Pi 4/5 (recommended for Wazuh Manager in SMB environments)

## License

MIT
