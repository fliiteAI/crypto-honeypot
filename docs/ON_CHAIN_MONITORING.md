# On-Chain Monitoring Guide

On-chain monitoring is the final layer of detection in the Crypto Wallet Honeypot system. It confirms when an attacker has successfully extracted a private key and is attempting to use it on a live blockchain.

## Overview
When you generate honeypot artifacts, the `honeypot-deployer` CLI tracks the corresponding public addresses in the `manifest.json`. By monitoring these addresses on-chain, you can detect:
1. **Balance Queries:** When an attacker imports the key and checks if there are funds.
2. **Outbound Transfers:** When an attacker tries to move "funds" (bait) out of the wallet.
3. **Token Approvals:** When an attacker uses a DeFi drainer to seek permissions for tokens.

## Setup Instructions

### 1. Export Public Addresses
First, export the public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./my-honeypot-addresses.json
```

### 2. Configure Watchlists
Import the generated addresses into block explorer watchlist services. Most major explorers offer free API-based or email notifications for address activity.

#### Ethereum / EVM (Etherscan, Polygonscan, etc.)
- Use the **Watch List** feature on Etherscan.
- Enable "Notify on Incoming & Outgoing Txns".

#### Solana (Solscan, Solana.fm)
- Set up alerts via Solscan's tracking features.

#### Bitcoin (Blockchain.com, BlockCypher)
- Use address monitoring APIs to track `wallet.dat` addresses.

### 3. Integrate with Wazuh (Optional but Recommended)
For a centralized security view, you can feed on-chain alerts back into Wazuh.

1. **Chain-Monitor Script:** Create a simple script that polls block explorer APIs for the exported addresses.
2. **Log to Wazuh:** Have the script output JSON logs to a file monitored by the Wazuh agent:
   ```json
   {"source": "chain-monitor", "event_type": "honeypot_chain_activity", "chain": "eth", "address": "0x...", "activity_type": "outbound_transfer"}
   ```
3. **Custom Rules:** The system already includes rules (100530-100533) to parse these logs and fire Level 15 alerts.

## Best Practices
- **Do not deposit real funds:** The goal is to detect access, not to lose money. If you want to track active theft, you can deposit a negligible amount of "bait" (e.g., $1 worth of a native token) if the chain's gas fees allow.
- **Monitor Multiple Chains:** Infostealers often extract keys for multiple chains simultaneously.
- **Secure your Manifest:** The `manifest.json` contains the private keys. While the public addresses are needed for monitoring, the private keys must remain protected.
