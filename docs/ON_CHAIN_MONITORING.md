# On-Chain Monitoring Guide

On-chain monitoring (Layer 4) is the final stage of detection, providing confirmation that an attacker has successfully exfiltrated and attempted to use the stolen honeypot keys.

## Overview

The `honeypot-deployer` generates valid public-private key pairs. While the private keys are deployed as bait, the public addresses can be added to "watchlists" on various block explorers. These explorers will then send notifications (email, webhook, Telegram) when any activity occurs on those addresses.

## Step-by-Step Setup

### 1. Export Honeypot Addresses
Use the CLI to export all public addresses from your deployment manifest:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./my-watchlist.json
```

### 2. Choose a Monitoring Service
Different chains require different explorers. Recommended services include:

- **Ethereum/EVM (ETH, BSC, Polygon):** [Etherscan](https://etherscan.io/) (Watchlist feature)
- **Bitcoin (BTC):** [Blockchain.com](https://www.blockchain.com/) or [Mempool.space](https://mempool.space/)
- **Solana (SOL):** [Solscan](https://solscan.io/)
- **XRP:** [XRPScan](https://xrpscan.com/)

### 3. Import Addresses
1.  Create an account on the chosen block explorer.
2.  Navigate to the "Watchlist" or "Address Tracking" section.
3.  Add the addresses from your `my-watchlist.json`.
4.  Configure notification settings (e.g., "Notify on all incoming and outgoing transactions").

## Advanced: Automated Webhooks

For a more integrated SOC experience, you can use services like **Alchemy** or **QuickNode** to set up "Notify" webhooks.

1.  **Create a Webhook:** In the Alchemy dashboard, create a new "Address Activity" webhook.
2.  **Add Addresses:** Paste the addresses from your export.
3.  **Point to Wazuh:** Point the webhook URL to a custom API endpoint or a middleware script that forwards the alert to your Wazuh Manager's custom logs, triggering Rule **100530**.

## Safety Warning

**NEVER deposit real funds into these addresses.** These are honeypot addresses; the private keys are intentionally "leaked" on your monitored endpoints. Any funds sent to these addresses should be considered lost or compromised.
