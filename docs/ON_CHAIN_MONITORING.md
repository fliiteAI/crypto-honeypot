# On-Chain Monitoring Guide

The fourth and final layer of detection in the Crypto Wallet Honeypot system is On-Chain Monitoring. This involves tracking the public addresses of your honeypots on their respective blockchains to detect when an attacker imports the keys and attempts to use them.

## Overview

Even if an attacker manages to bypass local endpoint security and exfiltrate the honeypot keys without being detected, they will eventually "reveal" themselves when they attempt to interact with the blockchain using those keys.

## 1. Export Honeypot Addresses

After generating your honeypot artifacts, use the `honeypot-deployer` CLI to export the public addresses:

```bash
honeypot-deployer export-addresses \
  --manifest ./honeypot-artifacts/manifest.json \
  --output ./honeypot-addresses.json
```

This will create a JSON file containing the public addresses for all supported chains (BTC, ETH, SOL, XRP, ADA).

## 2. Set Up Watchlists

You should add these addresses to "Address Watchlists" on popular block explorers. Most explorers offer free services that will send you an email or webhook notification whenever an address in your watchlist shows any activity.

### Recommended Explorers

-   **Ethereum (and EVM chains):** [Etherscan](https://etherscan.io/) (Watchlist feature)
-   **Bitcoin:** [Blockchain.com](https://www.blockchain.com/explorer) or [Mempool.space](https://mempool.space/)
-   **Solana:** [Solscan](https://solscan.io/) or [Solana Explorer](https://explorer.solana.com/)
-   **XRP:** [Bithomp](https://bithomp.com/) or [XRPScan](https://xrpscan.com/)
-   **Cardano:** [Cardanoscan](https://cardanoscan.io/)

### Configuration Steps

1.  Create an account on the chosen block explorer.
2.  Navigate to the "Watchlist" or "Address Tracking" section.
3.  Add the addresses from your `honeypot-addresses.json`.
4.  Enable notifications (Email, Webhook, or Telegram).
5.  Set the notification to trigger on **all activity** (both incoming and outgoing).

## 3. Integrating with Wazuh

For advanced users, you can integrate these on-chain alerts back into Wazuh.

### Using Webhooks
If the block explorer supports webhooks, you can point them to a middleware script that translates the explorer's notification into a local log file monitored by a Wazuh Agent.

### Custom API Monitoring
You can write a simple Python script that periodically polls the block explorer APIs for the addresses in your manifest and logs any new transactions.

```python
# Example pseudo-code for polling
import requests

addresses = ["0x123...", "0xabc..."]
for addr in addresses:
    response = requests.get(f"https://api.etherscan.io/api?module=account&action=txlist&address={addr}&apikey=YOUR_API_KEY")
    if response.json()["result"]:
        # Log this activity to a file monitored by Wazuh
        print(f"ON_CHAIN_ALERT: Activity detected on {addr}")
```

## Security Warning

**NEVER deposit real funds into these honeypot addresses.** The private keys are stored in your `manifest.json` and deployed on multiple endpoints. They are intended solely for detection purposes.
