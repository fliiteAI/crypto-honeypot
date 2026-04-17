# On-Chain Monitoring Guide

This guide explains how to set up monitoring for the public addresses associated with your honeypot artifacts. This is Layer 4 of our detection strategy.

## Overview

When you generate honeypot artifacts, the `honeypot-deployer` also creates a manifest containing the public addresses. By adding these addresses to "Watchlists" on various block explorers, you can receive real-time notifications (via email, webhook, etc.) if an attacker ever interacts with them on-chain.

## Supported Chains and Explorers

We recommend using the following explorers for setting up watchlists:

| Chain | Recommended Explorer | Features |
|-------|----------------------|----------|
| **Bitcoin (BTC)** | [Mempool.space](https://mempool.space/) or [Blockchain.com](https://www.blockchain.com/explorer) | Address tracking, email alerts |
| **Ethereum (ETH)** | [Etherscan](https://etherscan.io/) | "Watch List" feature, Email/Webhook notifications |
| **Solana (SOL)** | [Solscan](https://solscan.io/) or [SolanaFM](https://solanafm.com/) | Address monitoring |
| **XRP (Ripple)** | [XRP Scan](https://xrpscan.com/) | Account monitoring |
| **Cardano (ADA)** | [Cardanoscan](https://cardanoscan.io/) | Address tracking |

## Step-by-Step Setup

### 1. Export Honeypot Addresses
Use the CLI to export all public addresses from your manifest into a convenient format:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./addresses-to-monitor.json
```

### 2. Create Accounts on Explorers
Most explorers require a free account to use their watchlist/notification features.

### 3. Add Addresses to Watchlists
Copy the addresses from `addresses-to-monitor.json` and add them to your explorer accounts.

#### Example: Etherscan
1. Log in to [Etherscan](https://etherscan.io/).
2. Go to **Account** -> **Watch List**.
3. Click **Add**.
4. Enter the Ethereum address from your manifest.
5. Select "Notify on Incoming & Outgoing Txns".
6. (Optional) Set up a Webhook for automated processing.

### 4. Configure Notifications
Ensure your notification settings (Email, Slack, Webhook) are correctly configured on the explorer's dashboard.

## Integrating with Wazuh (Advanced)

If you use webhooks from block explorers, you can ingest these notifications into Wazuh for centralized alerting.

1.  **Set up a Webhook Receiver:** Use a simple script or a tool like `n8n` or `Node-RED` to receive the block explorer's webhook.
2.  **Forward to Wazuh:** Have the receiver write the event to a log file monitored by the Wazuh agent, or send it directly to the Wazuh Manager's API/syslog port.
3.  **Custom Rules:** Create custom Wazuh rules (e.g., in the 100530+ range) to trigger alerts when these on-chain events are detected.

---

## Security Warning
**NEVER** deposit real funds into these addresses. These are "bait" addresses. Any activity on them should be treated as a security breach.
