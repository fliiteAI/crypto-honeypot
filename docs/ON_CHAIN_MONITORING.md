# On-Chain Monitoring Guide

On-chain monitoring (Layer 4) provides critical detection of an attacker's activity after they have successfully exfiltrated honeypot keys and imported them into their own wallet software.

## Overview

Even if an attacker evades endpoint-level detection, their actions on the blockchain are public and permanent. By monitoring the public addresses associated with your honeypot artifacts, you can detect:
1. **Wallet Initialization:** When an attacker queries the balance of a stolen address.
2. **Transfer Attempts:** When an attacker tries to send "funds" (which will fail if the wallet is empty).
3. **Smart Contract Interaction:** When an attacker uses a "drainer" script to approve tokens.

## Setup Instructions

### 1. Export Honeypot Addresses
Use the `honeypot-deployer` CLI to export all generated public addresses to a JSON file.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./monitored-addresses.json
```

### 2. Configure Block Explorer Watchlists
The simplest way to monitor addresses without running your own node is to use "Watchlist" features on popular block explorers. Most explorers allow you to receive email or webhook notifications for any transaction involving a specific address.

#### Supported Chains & Recommended Explorers:
- **Ethereum (ETH/EVM):** [Etherscan](https://etherscan.io/)
- **Bitcoin (BTC):** [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Solana (SOL):** [Solscan](https://solscan.io/)
- **XRP (Ripple):** [XRPScan](https://xrpscan.com/)
- **Cardano (ADA):** [Cardanoscan](https://cardanoscan.io/)

### 3. Integrate with Wazuh
To pull on-chain events into your Wazuh SIEM, you can use a custom script or a dedicated "Chain Monitor" service that polls block explorer APIs and forwards events to the Wazuh Manager as JSON logs.

#### Log Format Requirement
The `honeypot_rules.xml` expect on-chain events in the following JSON format:

```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "eth",
  "address": "0x1234...",
  "activity_type": "balance_query",
  "timestamp": "2025-06-20T12:00:00Z"
}
```

## Security Warning
**NEVER deposit real cryptocurrency into honeypot addresses.** The private keys are stored in your deployment manifest and on the monitored endpoints. Any funds deposited will be at extreme risk of theft. The purpose of these addresses is solely to serve as bait.
