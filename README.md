# Crypto Wallet Honeypot Deployer

A defensive crypto wallet honeypot system for detecting attackers targeting cryptocurrency assets. Designed for SMB environments running [Wazuh SIEM](https://wazuh.com/) on Raspberry Pi.

## Overview

This tool generates realistic-looking (but non-funded) cryptocurrency wallet artifacts and deploys them across monitored endpoints. When an attacker whether an infostealer, malware or a manual intruder, accesses these honeypot files, Wazuh detects the activity and fires high-fidelity alerts with zero false positives.

For a deep dive into the system design, see the [Architecture Overview](docs/ARCHITECTURE.md).

### Detection Layers

| Layer | Mechanism | What It Detects |
|-------|-----------|-----------------|
| **Layer 1** | Wazuh FIM | Any read/modify/delete of honeypot wallet files |
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
```

### 2. Verify Manifest and Artifacts

```bash
# View the generated manifest
honeypot-deployer show --manifest ./honeypot-artifacts/manifest.json

# Run a health check to verify artifacts on disk
honeypot-deployer health-check --manifest ./honeypot-artifacts/manifest.json
```

### 3. Configure Wazuh

Follow the [Deployment Guide](docs/DEPLOYMENT.md) to set up your Wazuh Manager and Agents.

### 3. Monitor On-Chain

Learn how to track stolen keys on the blockchain in the [On-Chain Monitoring Guide](docs/ON_CHAIN_MONITORING.md).

## Project Structure

```
crypto-wallet-honeypot/
├── docs/                        # Detailed documentation
│   ├── ARCHITECTURE.md          # Multi-layer detection strategy
│   ├── DEPLOYMENT.md            # Step-by-step setup guide
│   └── ON_CHAIN_MONITORING.md   # Tracking stolen keys
├── src/honeypot_deployer/       # Python CLI application
├── wazuh/                       # Wazuh SIEM configuration
├── pyproject.toml               # Python project configuration
└── README.md
```

## MITRE ATT&CK Coverage

Our system provides coverage for several key techniques, including T1005 (Data from Local System), T1555 (Credentials from Password Stores), and T1657 (Financial Theft). See the [Architecture Overview](docs/ARCHITECTURE.md#mitre-attck-mapping) for the full mapping.

## Security Notes

- Generated honeypot keys are **non-funded** by default. Never deposit real funds.
- The manifest can be AES-encrypted at rest with a user-provided password.
- All detection relies on the principle that **legitimate users never access honeypot files**.

## Requirements

- **Python:** 3.10+
- **Wazuh:** 4.x (Manager + Agent)
- **Hardware:** Raspberry Pi 4/5 (recommended for Wazuh Manager)

## License

MIT
