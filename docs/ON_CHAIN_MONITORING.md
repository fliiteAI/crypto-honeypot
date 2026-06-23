# On-Chain Monitoring Guide

This guide explains how to monitor the generated honeypot addresses on various blockchains to detect when an attacker imports and uses stolen keys.

## Overview

The fourth layer of our detection strategy is on-chain monitoring. This ensures that even if an attacker manages to exfiltrate keys without triggering host-level alerts, their subsequent actions on the blockchain will be detected.

## 1. Exporting Addresses

Once you have generated your honeypot artifacts, you need to export the public addresses to track them.

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./watch-list.json
```

This will produce a JSON file containing the public addresses for all deployed chains (BTC, ETH, SOL, etc.).

## 2. Setting Up Watchlists

We recommend importing these addresses into popular block explorer "Watchlist" services. These services provide email or webhook notifications for any activity.

### Ethereum & EVM (Etherscan, Polygonscan, etc.)
1. Create an account on [Etherscan](https://etherscan.io/).
2. Navigate to **My Dashboard** > **Watch List**.
3. Add the exported ETH addresses.
4. Enable "Notify on Incoming & Outgoing Txns".

### Bitcoin (Blockchain.com, BlockCypher)
1. Use services like [Blockchain.com](https://www.blockchain.com/explorer) or [BlockCypher](https://www.blockcypher.com/) to monitor address balances.
2. Many explorers allow you to set up alerts for specific XPubs or individual addresses.

### Solana (Solscan)
1. Use [Solscan](https://solscan.io/).
2. Use their "Monitor" or "Alert" features to track activity on the generated SOL addresses.

## 3. Automated Monitoring with Wazuh

For a more integrated approach, you can use the custom Wazuh rules (Layer 4) to ingest logs from a chain-monitoring script.

1. **Chain-Monitor Script:** Use a script (not included in the core deployer) to periodically check the balance of exported addresses via RPC nodes (e.g., Infura, Alchemy, or your own node).
2. **Logging:** Have the script output JSON logs when activity is detected.
3. **Wazuh Ingestion:** Configure the Wazuh agent to monitor the script's log file.

### Example Log Format for Wazuh
```json
{"source": "chain-monitor", "event_type": "honeypot_chain_activity", "chain": "eth", "address": "0x...", "activity_type": "outbound_transfer"}
```

This will trigger **Rule ID 100530** or higher in Wazuh, providing a centralized alert.

## Security Warning

**NEVER deposit real funds into honeypot addresses.** These addresses are for detection purposes only. Any funds deposited will be accessible to anyone who obtains the honeypot keys.
