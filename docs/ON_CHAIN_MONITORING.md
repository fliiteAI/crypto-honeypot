# On-Chain Monitoring Guide

Layer 4 of the Crypto Wallet Honeypot detection strategy involves monitoring the public blockchain for activity related to the generated honeypot addresses. This guide explains how to set up this monitoring.

## How It Works

When you generate honeypot artifacts using the `honeypot-deployer`, the tool creates valid (but empty) public/private key pairs for various blockchains (BTC, ETH, SOL, etc.).
- The **Private Keys** are placed inside the honeyfiles on your endpoints.
- The **Public Addresses** are stored in the `manifest.json`.

If an attacker steals a honeyfile and imports the private key into a wallet, they will likely check the balance or attempt a transaction. By monitoring the public addresses, we can detect this activity even after the data has left your network.

## 1. Exporting Honeypot Addresses

Use the CLI to export all public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./my-artifacts/manifest.json \
  --output ./honeypot-addresses.json
```

The output will be a JSON file containing addresses categorized by chain.

## 2. Setting Up Watchlists

You should import these addresses into "Watchlists" on major block explorers. Most explorers offer free alerts via email or webhook when an address in your watchlist shows activity.

### Recommended Explorers:
- **Ethereum / EVM:** [Etherscan](https://etherscan.io/) (and its variants like BscScan, Polygonscan)
- **Bitcoin:** [Blockchain.com](https://www.blockchain.com/explorer) or [BlockCypher](https://www.blockcypher.com/)
- **Solana:** [Solscan](https://solscan.io/) or [SolanaFM](https://solana.fm/)
- **XRP:** [XRPScan](https://xrpscan.com/)

### Setup Steps:
1. Create an account on the explorer (e.g., Etherscan).
2. Navigate to the **Watchlist** or **Address Watcher** section.
3. Add the public addresses exported in Step 1.
4. Enable **Email Notifications** for all incoming and outgoing transactions.

## 3. Integrating with Wazuh

To bring these on-chain alerts into your Wazuh dashboard:
1. Configure the block explorer's webhook (if supported) to send alerts to a listener script.
2. Alternatively, use a script to periodically poll the explorer APIs for the addresses in your `honeypot-addresses.json`.
3. Format the alerts as JSON and append them to a log file monitored by the Wazuh Agent (e.g., `/var/log/chain-monitor.log`).

**Example Log Format:**
```json
{"source": "chain-monitor", "event_type": "honeypot_chain_activity", "chain": "ethereum", "address": "0x123...", "activity_type": "balance_query"}
```

Wazuh Rule ID `100530` is pre-configured to trigger a Critical (Level 15) alert when it sees this log format.

## Security Warning
**NEVER deposit real funds into these honeypot addresses.** The private keys are deliberately placed in insecure locations as bait. Any funds deposited will be lost.
