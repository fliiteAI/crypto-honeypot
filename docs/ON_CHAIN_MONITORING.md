# On-Chain Monitoring Guide

On-chain monitoring is the final layer of detection, allowing you to track if an attacker has successfully stolen and imported the generated honeypot keys.

## Overview

When you generate honeypot artifacts, the system also creates unique public addresses for various blockchains. By monitoring these addresses, you can detect when an attacker:
1. Imports the stolen key into a wallet.
2. Queries the balance of the address.
3. Attempts to transfer funds from the address.

## Exporting Honeypot Addresses

Use the `honeypot-deployer` CLI to export the public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./path/to/manifest.json \
  --output ./chain-monitor-addresses.json
```

## Setting Up Watchlists

Once you have the addresses, you can add them to watchlists on popular block explorers and monitoring services.

### Recommended Services
- **Ethereum (and EVM):** [Etherscan](https://etherscan.io/) Watchlist
- **Bitcoin:** [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
- **Solana:** [Solscan](https://solscan.io/)
- **Generic:** [WalletEye](https://walleteye.io/) or custom monitoring scripts.

## Integration with Wazuh

The `honeypot-deployer` system is designed to ingest events from an external "Chain Monitor" service. If you build or use a service that monitors these addresses and can output JSON logs, you can feed them into Wazuh.

The custom Wazuh rules (IDs 100530-100539) are pre-configured to handle events with `source: chain-monitor`.

### Example Log Format
```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "ethereum",
  "address": "0x1234...",
  "activity_type": "outbound_transfer",
  "details": "Transfer of 0.0 ETH to 0xabcd..."
}
```
