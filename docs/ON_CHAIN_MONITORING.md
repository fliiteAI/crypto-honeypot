# On-Chain Monitoring Guide

This guide explains how to monitor the generated honeypot public addresses for activity on various blockchains. This represents **Layer 4** of our detection strategy.

## Overview

When you generate honeypot artifacts, the system creates unique public/private key pairs. While the private keys are deployed as "bait," the public addresses can be monitored using external services. Any activity on these addresses (even if they have zero balance) indicates that an attacker has imported the stolen keys into a wallet and is actively investigating or attempting to use them.

## 1. Export Public Addresses

First, use the CLI to export the public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./artifacts/manifest.json \
  --output ./honeypot-addresses.json
```

The output will be a JSON file containing the addresses categorized by chain (BTC, ETH, SOL, etc.).

## 2. Set Up Watchlists

We recommend using free block explorer watchlist services to receive automated notifications (email, webhook, or Telegram) when an address is active.

### Bitcoin (BTC)
- **Service:** [Blockchain.com](https://www.blockchain.com/explorer) or [BlockCypher](https://www.blockcypher.com/).
- **Setup:** Create an account and add the exported BTC addresses to your "Watchlist" or "Address Notifications."

### Ethereum & EVM (ETH, BSC, Polygon, etc.)
- **Service:** [Etherscan](https://etherscan.io/) (and its sister sites like BscScan, PolygonScan).
- **Setup:**
  1. Create an Etherscan account.
  2. Go to **My Profile** -> **Watch List**.
  3. Click **Add** and enter the honeypot address.
  4. Enable "Notify on Incoming & Outgoing Txns."

### Solana (SOL)
- **Service:** [Solscan](https://solscan.io/) or [Helius](https://www.helius.dev/).
- **Setup:** Solscan provides a "Watchlist" feature for registered users. Helius offers robust webhooks for developers.

### XRP (Ripple)
- **Service:** [XRP Scan](https://xrpscan.com/).
- **Setup:** Use the "Track Address" feature or set up alerts via third-party XRP ledger monitoring tools.

## 3. Integrating with Wazuh

For advanced users, you can use the `chain-monitor` integration. This involves a script that periodically checks the addresses and sends logs to Wazuh.

1. **Configure Custom Decoder:** Ensure `wazuh/decoders/honeypot_decoder.xml` is installed.
2. **Configure Custom Rules:** Ensure `wazuh/rules/honeypot_rules.xml` is installed (specifically rules 100530-100533).
3. **Log Ingestion:** Send JSON logs from your monitoring script to the Wazuh Manager's log collector.

Example JSON log format expected by the rules:
```json
{
  "source": "chain-monitor",
  "event_type": "honeypot_chain_activity",
  "chain": "ethereum",
  "address": "0x1234...",
  "activity_type": "balance_query",
  "timestamp": "2023-10-27T10:00:00Z"
}
```

## Security Warning

**NEVER deposit real funds into these honeypot addresses.** The purpose of these addresses is to act as a tripwire. Any movement of funds, even dust, should be treated as a confirmed security breach.
