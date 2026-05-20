# On-Chain Monitoring Guide

On-chain monitoring is the 4th layer of our detection strategy. It allows you to detect if an attacker has successfully exfiltrated honeypot keys and is now attempting to use them on the blockchain.

## Overview

When you generate honeypots using the `honeypot-deployer` CLI, it creates real (but empty) cryptocurrency addresses. By adding these addresses to "watchlists" on various block explorers or using automated monitoring tools, you get notified the moment any activity occurs on those addresses.

## Step 1: Export Honeypot Addresses

Use the CLI to export all public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./honeypot-watch-list.json
```

This will produce a JSON file containing the public addresses for BTC, ETH, SOL, XRP, and ADA honeypots.

## Step 2: Set Up Block Explorer Watchlists

The most straightforward way to monitor these addresses is by using the "Watchlist" or "Address Alert" features of popular block explorers.

### Ethereum & EVM (ETH, BSC, Polygon, etc.)
- **Tool:** [Etherscan](https://etherscan.io/) (or related explorers like BscScan, Polygonscan).
- **Setup:** Create a free account -> My Profile -> Watch List -> Add New Address.
- **Notification:** Enable Email Notifications for all outgoing and incoming transactions.

### Bitcoin (BTC)
- **Tool:** [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/).
- **Setup:** Many explorers offer API-based alerts or email notifications for specific addresses.

### Solana (SOL)
- **Tool:** [Solscan](https://solscan.io/) or [SolanaFM](https://solana.fm/).
- **Setup:** Use their account alert features to monitor for any transaction activity.

## Step 3: Automated Monitoring with Wazuh

If you have a custom script or service (the "Chain Monitor") that polls these explorers or uses webhooks, you can feed those events into Wazuh for centralized alerting.

1. **Chain Monitor Event Format:** Your monitor should output JSON logs to a file monitored by the Wazuh agent.
   ```json
   {"source": "chain-monitor", "event_type": "honeypot_chain_activity", "chain": "ethereum", "address": "0x123...", "activity_type": "outbound_transfer"}
   ```
2. **Wazuh Detection:** The pre-installed rules (ID 100530-100533) will automatically detect these logs and fire high-severity alerts.

## Why Monitor On-Chain?

- **Persistence:** Even if an attacker wipes the compromised machine, the on-chain alert will still fire.
- **Confirmation:** It provides 100% confirmation that the keys were stolen and are being used.
- **Attribution:** Sometimes the destination address of an attacker's transfer can provide clues for forensic investigation.

---
**Warning:** Never deposit real funds into honeypot addresses. These addresses are meant to stay at zero balance. Any activity (even a balance query in some cases) is a sign of compromise.
