# On-Chain Monitoring Guide

Once you have deployed honeypot artifacts, the final layer of defense is monitoring the blockchain for activity related to the generated private keys.

## Overview

The `honeypot-deployer` generates real cryptocurrency addresses but **never** funds them. If an attacker steals a honeypot wallet file, they will likely import the private key into their own wallet software (e.g., MetaMask, Trust Wallet) to check for a balance or attempt a transfer.

By monitoring these addresses on-chain, you can confirm that an exfiltration has occurred even if the attacker successfully evaded your host-based detections.

## 1. Exporting Addresses

First, use the CLI to export the public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses --manifest ./honeypot-artifacts/manifest.json --output monitored-addresses.json
```

This will create a JSON file containing the addresses for all chains (BTC, ETH, SOL, etc.).

## 2. Setting Up Watchlists

The easiest way to monitor these addresses is by using "Watchlist" features on popular block explorers. Most explorers allow you to receive email or webhook notifications when an address on your list shows activity.

### Ethereum & EVM (Etherscan / Polygonscan / etc.)
1. Create a free account on [Etherscan](https://etherscan.io/).
2. Navigate to **Account** -> **Watch List**.
3. Click **Add New Address**.
4. Paste the Ethereum address from your `monitored-addresses.json`.
5. Enable **Notify on Incoming & Outgoing Txns**.

### Bitcoin (Blockchain.com / Mempool.space)
1. Use a service like [Mempool.space](https://mempool.space/) or [Blockchain.com](https://www.blockchain.com/explorer).
2. Many explorers offer API-based monitoring or "Address Alerts" for a small fee or free account.

### Solana (Solscan)
1. Visit [Solscan](https://solscan.io/).
2. Use their "Track" or "Monitor" feature to receive alerts for activity on your Solana honeypot addresses.

## 3. Automated Monitoring (Advanced)

For professional security operations, you can integrate these addresses into your own monitoring stack:

- **Wazuh Integration:** Use the `chain-monitor` service (if available) to pull events from block explorers and feed them directly into Wazuh as JSON logs.
- **Custom Scripts:** Write a simple Python script using `web3.py` or `solana-py` to periodically check the balance and transaction history of your addresses.

## 4. Responding to On-Chain Alerts

If you receive an alert that a honeypot address has been queried or used:
1. **Assume full compromise:** The attacker has successfully exfiltrated your honeypot files.
2. **Identify the Source:** Look at your Wazuh alerts for the same timeframe to identify which endpoint was compromised.
3. **Forensic Analysis:** Use the process data from Layer 2 to identify the malware or user account responsible.
4. **Isolate:** Disconnect the affected endpoint from the network immediately.
