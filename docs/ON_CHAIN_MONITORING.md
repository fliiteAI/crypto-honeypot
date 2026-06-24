# On-Chain Monitoring Guide

On-chain monitoring is the final layer of the Crypto Wallet Honeypot detection strategy. It allows you to detect when an attacker actually uses the stolen keys, even if they have already exfiltrated the data and left the compromised system.

## Setup Instructions

### 1. Export Honeypot Addresses
Use the `honeypot-deployer` CLI to export the public addresses of your generated honeypots:

```bash
honeypot-deployer export-addresses --manifest ./manifest.json --output ./addresses.json
```

### 2. Set Up Watchlists
Import the generated addresses into the watchlist feature of various block explorers:

- **Ethereum (EVM):** Use [Etherscan](https://etherscan.io/) watchlists.
- **Bitcoin:** Use [Blockchain.com](https://www.blockchain.com/) or similar explorers.
- **Solana:** Use [Solscan](https://solscan.io/).

### 3. Wazuh Integration
You can integrate block explorer alerts with Wazuh using custom decoders and rules. The `honeypot-deployer` provides a `source: chain-monitor` field in its logs that can be ingested by Wazuh.

## Monitoring for:
- **Balance Queries:** Attacker checking if the wallet has funds.
- **Outbound Transfers:** Attacker attempting to move "funds" (even if zero).
- **Token Approvals:** Attacker interacting with DeFi drainer contracts.
